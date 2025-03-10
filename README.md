# SwiftUIRedux

[中文版](README.zh.md) | [English](README.md)

**SwiftUIRedux** is a state management library designed for SwiftUI applications, inspired by Redux and [swift-composable-architecture](https://github.com/pointfreeco/swift-composable-architecture). It offers a clean and powerful way to manage and share application state, making state management more predictable, maintainable, and understandable.

## Features

- **Immutable State**: Ensure state predictability with immutable data structures, avoiding uncontrolled side effects.
- **Pure Function Reducers**: Use pure function reducers to describe state changes, maintaining testability and code maintainability.
- **Middleware Support**: Extend functionality with middleware, easily handling asynchronous operations and other side effects.
- **Seamless SwiftUI Integration**: Designed specifically for SwiftUI, ensuring perfect harmony with SwiftUI's view and data binding mechanisms.

## Installation

### Swift Package Manager

1. In Xcode, select File > Add Packages...
2. Enter repository URL: `https://github.com/happyo/SwiftUIRedux.git`
3. Choose version rules
4. Click Add Package

## Example: Counter Feature

### Feature Definition

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

### View Implementation

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

## Contributing

We welcome issues and pull requests! Please make sure to follow our contributing guidelines.

## License

SwiftUIRedux is released under the MIT license. See LICENSE for details.
