# SwiftUIRedux 状态管理库

[English](README.md) | [中文版](README.zh.md)

**SwiftUIRedux** 是一个专为 SwiftUI 应用程序设计的现代化状态管理库，结合了 Redux 的核心思想与 Swift 语言的类型安全特性。灵感来源于 [Redux] 和 [swift-composable-architecture](https://github.com/pointfreeco/swift-composable-architecture)。它提供了一种类型安全、可测试的方式来管理应用状态，特别适合中大型复杂应用开发。相对于swift-composable-architecture，这个更轻量，代码更少，但是能覆盖绝大部分的需求。

## 核心特性

- **单向数据流**：严格的 Action -> Reducer -> State 数据流确保状态变更可追溯
- **支持一些Binding需求**：因为有些控件需要提供Binging属性，所以这个时候用Action来触发就比较麻烦，所以就在store层支持了Binding。例如store的state有一个inputString属性，获取这个值就调用store.state.inputString，想要使用Binding的时候就直接store.inputstring。
- **类型安全设计**：全面使用 Swift 的强类型系统，从 Action 到 State 都提供编译期检查
- **组合式架构**：支持功能模块的分解与组合，便于大型应用开发
- **高效渲染机制**：基于 SwiftUI 的精细状态观察，实现高效视图更新
- **中间件生态系统**：
  - `ThunkMiddleware`：处理异步操作和副作用
  - `LoggingMiddleware`：完整记录状态变更历史
  - `ActionPublisherMiddleware`：实现Action监听，方便在某个Action后进行其他操作。
- **时间旅行调试**：配合开发者工具可回溯状态历史
- **零依赖**：纯 Swift 实现，不依赖任何第三方库

## 目录
- [快速开始](#快速开始)
- [核心概念](#核心概念)
  - [状态（State）](#状态state)
  - [操作（Action）](#操作action)
  - [Reducer](#reducer)
  - [Store](#store)
  - [中间件（Middleware）](#中间件middleware)
- [最佳实践](#最佳实践)
- [示例应用](#示例应用)
- [贡献指南](#贡献指南)

## 安装

### Swift Package Manager

1. 在 Xcode 中选择 File > Add Packages...
2. 输入仓库URL: `https://github.com/happyo/SwiftUIRedux.git`
3. 选择版本规则
4. 点击 Add Package

## 示例：计数器功能

### 功能定义

```swift
struct CountReduxFeature: Feature {
    struct State: Equatable {
        var count: Int = 0
        var isLoading: Bool = false
    }
    
    enum Action: Equatable {
        case increase
        case decrease
        case start
        case success(Int)
        case error(String)
        
        func isStartAction() -> Bool {
            return self == .start
        }
    }
    
    struct Reducer: ReducerProtocol {
        func reduce(oldState: State, action: Action) -> State {
            var newState = oldState
            switch action {
            case .increase:
                newState.count += 1
            case .decrease:
                newState.count -= 1
            case .start:
                newState.isLoading = true
            case .success(let count):
                newState.isLoading = false
                newState.count = count
            case .error(_):
                newState.isLoading = false
            }
            return newState
        }
    }
    
    static func initialState() -> State {
        return State()
    }
    
    static func createReducer() -> Reducer {
        return Reducer()
    }
    
    static func middlewares() -> [AnyMiddleware<Self>] {
        let thunkMiddleware = ThunkMiddleware<CountReduxFeature>()
        return [AnyMiddleware(thunkMiddleware)]
    }
}
```

### 视图实现

```swift
import SwiftUI

struct ContentView: View {
    @ObservedObject var countStore: Store<CountReduxFeature> = StoreFactory.createStore()
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea(.all)
            
            VStack {
                if countStore.state.isLoading {
                    ProgressView()
                        .frame(width: 100, height: 100)
                }
                
                Text("Counter: \(countStore.state.count)")
                Button("Increase") {
                    countStore.send(.normal(.increase))
                }
                Button("Decrease") {
                    countStore.send(.normal(.decrease))
                }
                
                Button("Change") {
                    fetchCount()
                }
            }
        }
    }
    
    func fetchCount() {
        let fetchDataAction = ThunkEffectAction<CountReduxFeature.State, CountReduxFeature.Action> { dispatch, getState in
            DispatchQueue.main.async {
                dispatch(.start)
            }
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                let data = 4
                DispatchQueue.main.async {
                    dispatch(.success(data))
                }
            }
        }
        countStore.send(.effect(fetchDataAction))
    }
}
```

## 贡献

欢迎提交问题和拉取请求！请确保遵循我们的贡献指南。

## 许可证

SwiftUIRedux 采用 MIT 许可证 - 详情请见 LICENSE 文件。
