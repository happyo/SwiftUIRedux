# SwiftUIRedux

[中文版](README.zh.md) | [English](README.md)

**SwiftUIRedux** is a modern state management library for SwiftUI applications that combines Redux principles with Swift's type safety. Inspired by [Redux] and [swift-composable-architecture](https://github.com/pointfreeco/swift-composable-architecture). It provides a type-safe, testable approach to state management, particularly suited for medium to large-scale complex applications.

## Core Features

- **Unidirectional Data Flow**: Strict Action -> Reducer -> State flow ensures traceable state changes
- **Type-Safe Design**: Full utilization of Swift's type system with compile-time checks for all actions and states
- **Modular Architecture**: Support feature decomposition and composition for large-scale applications
- **Efficient Rendering**: Fine-grained state observation based on SwiftUI for optimal view updates
- **Middleware Ecosystem**:
  - `ThunkMiddleware`: Handle async operations and side effects
  - `LoggingMiddleware`: Complete state change history tracking
  - `ActionPublisherMiddleware`: Cross-feature communication
  - `HookMiddleware`: Custom logic extension
- **Time Travel Debugging**: State history回溯 with developer tools
- **Zero Dependencies**: Pure Swift implementation with no third-party dependencies

## Table of Contents
- [Quick Start](#quick-start)
- [Core Concepts](#core-concepts)
  - [State](#state)
  - [Action](#action)
  - [Reducer](#reducer)
  - [Store](#store)
  - [Middleware](#middleware)
- [Best Practices](#best-practices)
- [Example App](#example-app)
- [Contributing](#contributing)

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
