# SwiftUIRedux 状态管理库

[![Swift 6.0](https://img.shields.io/badge/Swift-6.0+-orange.svg)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Build Status](https://img.shields.io/github/actions/workflow/status/happyo/SwiftUIRedux/ci.yml?branch=main)](https://github.com/happyo/SwiftUIRedux/actions)

[English](README.md) | 中文版

**SwiftUIRedux** 是专为 SwiftUI 设计的现代化状态管理库，完美结合 Redux 核心模式与 Swift 的类型安全特性。灵感来源于 [Redux] 和 [swift-composable-architecture](https://github.com/pointfreeco/swift-composable-architecture)，提供比同类框架更轻量高效的解决方案，覆盖 90% 的 SwiftUI 状态管理场景。

## 🌟 核心特性

### 基础架构
- 🚀 **严格单向数据流**：强制遵循 Action → Reducer → State 的闭环管理
- 🛡️ **类型安全**：从 Action 定义到 State 变更的完整类型推导

### 状态管理
- 🔄 **双向绑定**：原生支持 `store.property` 的 SwiftUI 双向绑定
- 🎭 **混合状态**：
  1. **Published State** - 驱动视图更新的核心状态
  2. **Internal State** - 用于临时存储的非响应式状态（例如监听scrollView的offset来用于判断，如果将其存入@State中会影响页面计算导致性能问题）
  
### 中间件生态
- ⏳ **ThunkMiddleware**：处理异步任务和副作用
- 📡 **ActionPublisherMiddleware**：全局 Action 监听管道
- 🔍 **LoggingMiddleware**：开发调试日志追踪
- 🪝 **HookMiddleware**：自定义生命周期钩子

## 🚀 快速入门

### 安装
```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/happyo/SwiftUIRedux.git", from: "1.0.7")
]
```

### 基础示例（5分钟上手）
```swift
import SwiftUI
import SwiftUIRedux

struct BasicCounterView: View {
    @StateObject private var store: Store<BasicCounterFeature> = StoreFactory.createStore()

    var body: some View {
        VStack(spacing: 20) {
            Text("Current Count: \(store.state.count)")
                .font(.largeTitle)
            
            Text("Input string: \(store.state.inputString)")

            HStack(spacing: 20) {
                Button("−") { store.send(.decrement) }
                    .buttonStyle(CircleButtonStyle(color: .red))

                Button("+") { store.send(.increment) }
                    .buttonStyle(CircleButtonStyle(color: .green))
            }
            
            TextField("Please input something", text: store.inputString)
                .padding()
        }
        .navigationTitle("Basic Counter")
    }
}

struct BasicCounterFeature: Feature {
    struct State: Equatable {
        var count = 0
        var inputString: String = ""
    }

    enum Action: Equatable {
        case increment
        case decrement
    }

    struct Reducer: ReducerProtocol {
        func reduce(oldState: State, action: Action) -> State {
            var state = oldState
            switch action {
            case .increment:
                state.count += 1
            case .decrement:
                state.count -= 1
            }
            return state
        }
    }

    static func initialState() -> State { State() }
    static func createReducer() -> Reducer { Reducer() }
}
```

## 🔥 核心功能详解

### 状态绑定

使用store.inputString可以直接获取Binging类型，相当与@State的$inputString。因为有的控件需要Binding参数，如果使用Action方式的话就非常麻烦。虽然这样可能会破坏一些Redux的思想，但是在实际中很方便。

```swift

struct BasicCounterView: View {
    @StateObject private var store: Store<BasicCounterFeature> = StoreFactory.createStore()

    var body: some View {
        // ...
        Text("Input string: \(store.state.inputString)")

        // ...
        TextField("Please input something", text: store.inputString)
            .padding()
    }
}

struct BasicCounterFeature: Feature {
    struct State: Equatable {
                // ...
        var inputString: String = ""
    }

    enum Action: Equatable {
            // ...
    }
            // ...
}
```

### 异步处理

一般使用store send和dispatch是同步的，并且修改状态会自动在主线程中完成，所以可以在Task中直接调用store.send和dispatch，这样不需要用户自己再返回主线程调用。要处理异步的话需要借助ThunkMiddleware和ThunkEffectAction来完成，具体用法如下：

```swift
import SwiftUI
import SwiftUIRedux

struct EffectCounterView: View {
    @StateObject private var store: Store<EffectCounterFeature> = StoreFactory.createStore()

    var body: some View {
        VStack(spacing: 20) {
            if store.state.isLoading {
                ProgressView()
                    .scaleEffect(2.0)
            } else {
                Text("Random Number: \(store.state.randomNumber)")
                    .font(.largeTitle)
                    .transition(.scale.combined(with: .opacity))
            }

            Button("Get Random Number") {
                store.send(EffectCounterFeature.createFetchAsyncRandomNumberAction())
            }
            .disabled(store.state.isLoading)
        }
    }
}

struct EffectCounterFeature: Feature {
    struct State: Equatable {
        var randomNumber = 0
        var isLoading = false
        var lastUpdated = Date()
    }

    enum Action {
        case startLoading
        case endLoading
        case setNumber(Int)
    }

    struct Reducer: ReducerProtocol {
        func reduce(oldState: State, action: Action) -> State {
            var state = oldState
            switch action {
            case .startLoading:
                state.isLoading = true
            case .endLoading:
                state.isLoading = false
                state.lastUpdated = Date()
            case .setNumber(let number):
                state.randomNumber = number
            case .reset:
                state = Self.initialState()
            }
            return state
        }
    }

    static func initialState() -> State { State() }
    static func createReducer() -> Reducer { Reducer() }
    
    // Important, using async must add ThunkMiddleware
    static func middlewares() -> [AnyMiddleware<EffectCounterFeature>] {
        let thunkMiddleware = ThunkMiddleware<EffectCounterFeature>()
        
        return [AnyMiddleware(thunkMiddleware)]
    }

    static func createFetchAsyncRandomNumberAction() -> ThunkEffectAction<State, Action> {
        ThunkEffectAction<State, Action> { dispatch, getState in
            let state = getState()
            
            print("Current random number: \(state.randomNumber)")
            
            Task {
                dispatch(.startLoading)
                
                try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
                let randomNumber = Int.random(in: 1...100)
                dispatch(.setNumber(randomNumber))
                
                dispatch(.endLoading)
            }
        }
    }
}

```

### 不需要刷新页面的状态

现在store里面存储的state是影响页面刷新的，然后我们有时候会遇到一些不需要刷新页面但是需要临时存下来用于某些判断的值，例如scrollView的offset等等。这个时候就可以使用store的InternalState来进行存储，具体用法如下：

```swift
import SwiftUI
import SwiftUIRedux

struct InternalStateExampleView: View {
    // 初始化的时候需要创建一个InternalState给store，因为这个属性是optional的。
    @StateObject private var store: Store<MixedStateFeature> = StoreFactory.createStore(internalState: MixedStateFeature.InternalState())

    var body: some View {
        VStack(spacing: 20) {
            Text("Published State: \(store.state.publishedCount)")
                .font(.title)

            // 直接修改notPublishedCount不会触发页面刷新
            Text("Not published State: \(store.internalState?.notPublishedCount ?? 0)")
                .font(.title)
                .foregroundColor(.secondary)

            HStack(spacing: 20) {
                Button("Published +1") { store.send(.incrementPublished) }

                Button("Published -1") { store.send(.decrementPublished) }
            }

            Divider().padding()

            // 这里修改状态不会影响页面显示的数据
            HStack(spacing: 20) {
                Button("Not published +1") { store.internalState?.notPublishedCount += 1 }
                Button("Not published -1") { store.internalState?.notPublishedCount -= 1 }
            }

            Button("Reset All") {
                store.send(.reset)
                store.internalState?.notPublishedCount = 0
            }
        }
        .navigationTitle("Combined State Example")
    }
}

struct MixedStateFeature: Feature {
    struct State {
        var publishedCount = 0
    }
    
    // 创建InternalState
    struct InternalState {
        var notPublishedCount = 0
    }

    // ...
}

```

### 中间件系统

对于一些额外的需求，例如打印Action和State的各种信息，需要在某个Action进行其他的一些操作。这样就需要借助Middleware来完成，库里默认提供了几种Middleware，下面展示其一些基本用法：

```swift
import SwiftUI
import SwiftUIRedux

struct MiddlewareView: View {
    @StateObject private var store: Store<MiddlewareFeature> = StoreFactory.createStore()
    let actionPublishedMiddleware: ActionPublisherMiddleware<MiddlewareFeature>
    
    init() {
        let actionPublishedMiddleware = ActionPublisherMiddleware<MiddlewareFeature>()
        
        let middlewares = [AnyMiddleware(actionPublishedMiddleware)]
        // 这里可以添加需要获取实例的Middleware
        let store = StoreFactory.createStore(otherMiddlewares: middlewares)
        self._store = StateObject(wrappedValue: store)
        
        self.actionPublishedMiddleware = actionPublishedMiddleware
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Current Count: \(store.state.count)")
                .font(.largeTitle)

            HStack(spacing: 20) {
                Button("−") { store.send(.decrement) }
                    .buttonStyle(CircleButtonStyle(color: .red))

                Button("+") { store.send(.increment) }
                    .buttonStyle(CircleButtonStyle(color: .green))
            }
        }
        .navigationTitle("Basic Counter")
        .onReceive(actionPublishedMiddleware.actionPublisher) { action in
            print(action)
            switch action {
            case .increment:
                print("do something")
            default:
                break
            }
        }
    }
}

struct MiddlewareFeature: Feature {
    struct State: Equatable {
        var count = 0
    }

    enum Action: Equatable {
        case increment
        case decrement
    }

    struct Reducer: ReducerProtocol {
        func reduce(oldState: State, action: Action) -> State {
            var state = oldState
            switch action {
            case .increment:
                state.count += 1
            case .decrement:
                state.count -= 1
            }
            return state
        }
    }

    static func initialState() -> State { State() }
    static func createReducer() -> Reducer { Reducer() }
    
    // 这里可以添加一些静态的Middleware
    static func middlewares() -> [AnyMiddleware<MiddlewareFeature>] {
        let loggingMiddleware = LoggingMiddleware<MiddlewareFeature>()
        
        return [AnyMiddleware(loggingMiddleware)]
    }
}
```

## 🏗 架构最佳实践

### 状态设计原则
1. **不可变状态** - 始终通过 reducer 返回新状态
2. **最小化状态** - 只存储必要数据
3. **Store的标记** - 单个View初始化的Store必须要用@StateObject标记，这样可以防止store重复创建造成问题。

### 状态类型指南
| 状态类型         | 使用场景                          | 更新机制         |
|------------------|---------------------------------|------------------|
| Published State  | 需要驱动视图更新的数据            | 通过 Action 修改 |
| Internal State   | 临时存储/中间计算状态             | 直接修改         |
