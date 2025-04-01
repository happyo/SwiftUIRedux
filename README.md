# SwiftUIRedux State Management Library

[![Swift 6.0](https://img.shields.io/badge/Swift-6.0+-orange.svg)](https://swift.org)  
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)  
[![Build Status](https://img.shields.io/github/actions/workflow/status/happyo/SwiftUIRedux/ci.yml?branch=main)](https://github.com/happyo/SwiftUIRedux/actions)  

**SwiftUIRedux** is a modern state management library designed specifically for SwiftUI, seamlessly combining Redux core patterns with Swift's type safety. Inspired by [Redux] and [swift-composable-architecture](https://github.com/pointfreeco/swift-composable-architecture), it provides a more lightweight and efficient solution than similar frameworks, covering 90% of SwiftUI state management scenarios.

## 🌟 Core Features

### Architecture Foundation
- 🚀 **Strict Unidirectional Data Flow**: Enforces Action → Reducer → State closed-loop management
- 🛡️ **Type Safety**: Full type inference from Action definitions to State mutations

### State Management
- 🔄 **Two-way Binding**: Native SwiftUI two-way binding support for `store.property`
- 🎭 **Hybrid State**:
  1. **Published State** - Core state driving view updates
  2. **Internal State** - Non-reactive state for temporary storage (e.g., storing scrollView offset values without affecting performance)

### Middleware Ecosystem
- ⏳ **ThunkMiddleware**: Handles async tasks and side effects
- 📡 **ActionPublisherMiddleware**: Global Action monitoring pipeline
- 🔍 **LoggingMiddleware**: Development debugging with action tracing
- 🪝 **HookMiddleware**: Custom lifecycle hooks

## 🚀 Quick Start

### Installation
```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/happyo/SwiftUIRedux.git", from: "1.0.9")
]
```

### Basic Example (5-Minute Setup)
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

## 🔥 Core Functionality Deep Dive

### State Binding

Use `store.inputString` to directly obtain Binding type, equivalent to `@State`'s `$inputString`. While this approach may slightly deviate from pure Redux philosophy, it significantly simplifies real-world usage.

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
```

### Async Processing

Synchronous state updates automatically occur on the main thread. For async operations, use ThunkMiddleware and ThunkEffectAction, or use AsyncEffectAction to await:

```swift
struct EffectCounterFeature: Feature {
    // ... (State and Action definitions)

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

    static func createFetchAsyncRandomNumberActionWithAsyncEffect() -> AsyncEffectAction<State, Action> {
        AsyncEffectAction<State, Action> { dispatch, getState in
            let state = getState()
            print("Current random number (Async): \(state.randomNumber)")
            
            
            try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
            let randomNumber = Int.random(in: 1...100)
            dispatch(.setNumber(randomNumber))
        }
    }
    
    static func createFetchAsyncRandomNumberActionWithAsyncEffectAnimation() -> AsyncAnimationEffectAction<State, Action> {
        AsyncAnimationEffectAction<State, Action> { dispatch, getState in
            let state = getState()
            print("Current random number (Async): \(state.randomNumber)")
            
            dispatch(.startLoading, .default)

            try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
            let randomNumber = Int.random(in: 1...100)
            dispatch(.setNumber(randomNumber), .default)
            
            dispatch(.endLoading, .default)
        }
    }
}
```

### Non-Published State

Store temporary values that don't trigger view updates using InternalState:

```swift
struct MixedStateFeature: Feature {
    struct State {
        var publishedCount = 0
    }
    
    struct InternalState {
        var notPublishedCount = 0
    }

    // ... (Other feature components)
}
```

### Middleware System

Extend functionality with middleware components:

```swift
struct MiddlewareFeature: Feature {
    // ... (State and Action definitions)
    
    static func middlewares() -> [AnyMiddleware<MiddlewareFeature>] {
        let loggingMiddleware = LoggingMiddleware<MiddlewareFeature>()
        return [AnyMiddleware(loggingMiddleware)]
    }
}
```

## 🏗 Architectural Best Practices

### State Design Principles
1. **Immutable State** - Always return new state through reducers
2. **Minimal State** - Only store essential data
3. **Store Ownership** - Mark View-owned stores with `@StateObject` to prevent recreation issues

### State Type Guidelines
| State Type         | Usage Scenario                   | Update Mechanism       |
|--------------------|----------------------------------|------------------------|
| Published State    | Data requiring view updates      | Modified via Actions   |
| Internal State     | Temporary storage/intermediate   | Direct modification    |
