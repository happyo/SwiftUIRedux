# SwiftUIRedux 状态管理库

[English](README.md) | [中文版](README.zh.md)

**SwiftUIRedux** 是一个专为 SwiftUI 应用程序设计的状态管理库，灵感来源于 Redux 和 [swift-composable-architecture](https://github.com/pointfreeco/swift-composable-architecture)。它提供了一种简洁而强大的方式来管理和共享应用程序状态，使状态管理更加可预测、可维护和易于理解。

## 功能特点

- **不可变状态**: 使用不可变数据结构确保状态可预测性，避免不可控的副作用
- **纯函数Reducer**: 使用纯函数reducer描述状态变化，保持代码可测试性和可维护性
- **中间件支持**: 通过中间件扩展功能，轻松处理异步操作和其他副作用
- **无缝SwiftUI集成**: 专为SwiftUI设计，确保与SwiftUI的视图和数据绑定机制完美配合

## 安装

### Swift Package Manager

1. 在 Xcode 中选择 File > Add Packages...
2. 输入仓库URL: `https://github.com/yourusername/SwiftUIRedux.git`
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
