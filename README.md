# SwiftUIRedux State Management Library

[English](README.md) | [中文版](README.zh.md)

**SwiftUIRedux** is a modern state management library designed for SwiftUI applications, combining Redux core concepts with Swift's type safety. Inspired by [Redux] and [swift-composable-architecture](https://github.com/pointfreeco/swift-composable-architecture). Offers a lighter-weight implementation than similar frameworks while covering 90% of common state management scenarios.

## 🌟 Core Features

### Foundation
• **Strict Unidirectional Flow**: Action → Reducer → State closed-loop management
• **Type-Safe Architecture**: Full type inference from Action to State
• **Efficient View Rendering**: Precise state subscription mechanism based on SwiftUI

### Advanced Capabilities
• **Two-Way Binding Support**: Native SwiftUI binding via `store.property`
• **Hybrid State Management**:
  • `Published State`: Observable state triggered by Actions
  • `Not Published State`: Non-rendering state storage (e.g., scrollView real-time offset tracking)
• **Middleware Ecosystem**:
  • `ThunkMiddleware`: Async operation handling
  • `ActionPublisherMiddleware`: Global Action monitoring for side effects

## 🚀 Quick Start

### Installation
```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/happyo/SwiftUIRedux.git", from: "1.0.7")
]
```

### 5-Minute Tutorial
```swift
import SwiftUI
import SwiftUIRedux

struct BasicCounterView: View {
    @StateObject private var store: Store<BasicCounterFeature> = StoreFactory.createStore()

    var body: some View {
        VStack(spacing: 20) {
            Text("Current Count: \(store.state.count)")
                .font(.largeTitle)
            
            TextField("Input", text: store.inputString)
                .padding()
            
            ControlButtons(store: store)
        }
        .navigationTitle("Basic Counter")
    }
}

struct BasicCounterFeature: Feature {
    struct State: Equatable {
        var count = 0
        var inputString = ""
    }

    enum Action: Equatable {
        case increment
        case decrement
    }

    struct Reducer: ReducerProtocol {
        func reduce(oldState: State, action: Action) -> State {
            var state = oldState
            switch action {
            case .increment: state.count += 1
            case .decrement: state.count -= 1
            }
            return state
        }
    }

    static func initialState() -> State { State() }
    static func createReducer() -> Reducer { Reducer() }
}
```

## 🔥 Core Features Deep Dive

### State Binding (Enhanced)
```swift
// Native SwiftUI binding integration
TextField("Input", text: store.inputString)

// Reducer handling
Reducer { oldState, action in
    guard case .updateInput(let text) = action else { return oldState }
    var state = oldState
    state.inputString = text
    return state
}
```

### Async Handling (Optimized)
```swift
struct EffectCounterFeature: Feature {
    // State and Action declarations
    
    static func createFetchAsyncAction() -> ThunkEffectAction<State, Action> {
        ThunkEffectAction { dispatch, getState in
            dispatch(.startLoading)
            
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            let number = Int.random(in: 1...100)
            dispatch(.setNumber(number))
            
            dispatch(.endLoading)
        }
    }
    
    static func middlewares() -> [AnyMiddleware<Self>] {
        [AnyMiddleware(ThunkMiddleware())]
    }
}
```

### Middleware System (Configuration Example)
```swift
struct MiddlewareFeature: Feature {
    static func middlewares() -> [AnyMiddleware<Self>] {
        let logger = LoggingMiddleware<MiddlewareFeature>()
        let actionPublisher = ActionPublisherMiddleware<MiddlewareFeature>()
        
        return [AnyMiddleware(logger), AnyMiddleware(actionPublisher)]
    }
}

// Usage in View
.onReceive(middleware.actionPublisher) { action in
    analytics.track(action)
}
```

## 🧠 State Design Principles
1. **Minimal State**: Store only essential data
2. **Immutability**: Always return new state instances in reducers
3. **Local First**: Use `@State` for component-private state
4. **Composition**: Break complex states into sub-features

