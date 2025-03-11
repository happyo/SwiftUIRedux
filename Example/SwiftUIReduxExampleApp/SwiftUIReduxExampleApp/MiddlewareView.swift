//
//  MiddlewareView.swift
//  SwiftUIReduxExampleApp
//
//  Created by happyo on 2025/3/11.
//

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
