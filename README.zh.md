# SwiftUIRedux 状态管理库

[English](README.md) | [中文版](README.zh.md)

**SwiftUIRedux** 是一个专为 SwiftUI 应用程序设计的现代化状态管理库，结合 Redux 核心思想与 Swift 语言的类型安全特性。灵感来源于 [Redux] 和 [swift-composable-architecture](https://github.com/pointfreeco/swift-composable-architecture)。提供比同类框架更轻量的实现，同时覆盖 90% 的常见状态管理场景。

## 🌟 核心特性

### 基础架构
- 🚀 **严格单向数据流**：强制遵循 Action → Reducer → State 的闭环管理
- 🛡️ **类型安全**：从 Action 定义到 State 变更的完整类型推导
- ⚡️ **高效渲染**：基于 SwiftUI 的精准差分更新机制

### 状态管理
- 🔄 **双向绑定**：原生支持 `store.binding(for:)` 的 SwiftUI 双向绑定
- 🎭 **混合状态**：
  - **Published State** - 驱动视图更新的核心状态
  - **Internal State** - 用于临时存储的非响应式状态（如滚动偏移量）
  
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
    @StateObject private var store = StoreFactory.createStore(feature: BasicCounterFeature.self)
    
    var body: some View {
        VStack(spacing: 20) {
            CounterDisplay(store: store)
            CounterButtons(store: store)
            InputField(store: store)
        }
        .navigationTitle("基础计数器")
    }
}

private struct CounterDisplay: View {
    let store: Store<BasicCounterFeature>
    
    var body: some View {
        VStack {
            Text("当前计数: \(store.state.count)")
                .font(.largeTitle)
            Text("输入内容: \(store.state.inputString)")
                .foregroundStyle(.secondary)
        }
    }
}

private struct CounterButtons: View {
    let store: Store<BasicCounterFeature>
    
    var body: some View {
        HStack(spacing: 20) {
            Button("−") { store.send(.decrement) }
                .buttonStyle(CircleButtonStyle(color: .red))
            
            Button("+") { store.send(.increment) }
                .buttonStyle(CircleButtonStyle(color: .green))
        }
    }
}

private struct InputField: View {
    let store: Store<BasicCounterFeature>
    
    var body: some View {
        TextField("请输入内容", text: store.binding(for: \.inputString, action: .updateInput))
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal)
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

### 异步处理（优化示例）
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
        .animation(.spring(), value: store.state.isLoading)
        .navigationTitle("Async Effect Example")
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

### 中间件系统（新增配置示例）
```swift
import SwiftUI
import SwiftUIRedux

struct MiddlewareView: View {
    @StateObject private var store: Store<MiddlewareFeature> = StoreFactory.createStore()
    let actionPublishedMiddleware: ActionPublisherMiddleware<MiddlewareFeature>
    
    init() {
        let actionPublishedMiddleware = ActionPublisherMiddleware<MiddlewareFeature>()
        
        let middlewares = [AnyMiddleware(actionPublishedMiddleware)]
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
    static func middlewares() -> [AnyMiddleware<MiddlewareFeature>] {
        let loggingMiddleware = LoggingMiddleware<MiddlewareFeature>()
        
        return [AnyMiddleware(loggingMiddleware)]
    }
}
```

### 状态设计原则
1. **最小化状态**：只存储必要数据
2. **不可变性**：始终通过 reducer 返回新状态
3. **本地优先**：组件私有状态使用 @State
4. **组合式设计**：复杂状态分解为子状态
