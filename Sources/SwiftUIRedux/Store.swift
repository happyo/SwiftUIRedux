//
//  Created by belyenochi on 2024/05/16.
//

import SwiftUI

public protocol EffectAction: Sendable {

}

public enum ReduxAction<Action: Sendable>: Sendable {
    case normal(Action)
    case effect(EffectAction)
}

@MainActor
public protocol StoreProtocol {
    associatedtype State: Sendable
    associatedtype Action: Sendable
    var state: State { get }
    func send(_ action: ReduxAction<Action>)
}

@MainActor
@dynamicMemberLookup
public class Store<T: Feature>: ObservableObject, StoreProtocol {

    @Published private(set) public var state: T.State
    private var reducer: T.Reducer
    private var middlewareChain: MiddlewareChain<T>

    public init(initialState: T.State, reducer: T.Reducer, middlewares: [AnyMiddleware<T>] = []) {
        self.state = initialState
        self.reducer = reducer
        self.middlewareChain = MiddlewareChain(middlewares: middlewares)
    }

    public func send(_ action: ReduxAction<T.Action>) {
        Task {
            await middlewareChain.process(store: self, action: action)
        }
    }

    public func addMiddleware(_ middleware: AnyMiddleware<T>) {
        middlewareChain.addMiddleware(middleware)
    }

    // MARK: - DynamicMemberLookup
    public subscript<U>(dynamicMember keyPath: WritableKeyPath<T.State, U>) -> Binding<U> {
        Binding(
            get: { self.state[keyPath: keyPath] },
            set: { newValue in
                var newState = self.state
                newState[keyPath: keyPath] = newValue
                self.state = newState
            }
        )
    }

    fileprivate func reduce(action: T.Action) {
        self.state = self.reducer.reduce(oldState: self.state, action: action)
    }
}

@MainActor
public class MiddlewareChain<T: Feature> {
    private var middlewares: [AnyMiddleware<T>] = []

    public init(middlewares: [AnyMiddleware<T>] = []) {
        self.middlewares = middlewares
    }

    public func addMiddleware(_ middleware: AnyMiddleware<T>) {
        middlewares.append(middleware)
    }

    public func process(store: Store<T>, action: ReduxAction<T.Action>) async {
        for middleware in middlewares {
            await middleware.process(store: store, action: action)
        }

        // 所有中间件处理完毕，调用 reducer
        if case .normal(let normalAction) = action {
            store.reduce(action: normalAction)
        }
    }
}

public struct AnyStore<T: Feature>: StoreProtocol {
    private var _state: () -> T.State
    private var _send: (ReduxAction<T.Action>) -> Void

    init<StoreType: StoreProtocol>(_ store: StoreType)
    where StoreType.State == T.State, StoreType.Action == T.Action {
        _state = { store.state }
        _send = store.send
    }

    public var state: T.State {
        _state()
    }

    public func send(_ action: ReduxAction<T.Action>) {
        _send(action)
    }
}

public class TestStore<FeatureType: Feature> where FeatureType.Action: Equatable {
    private var reducer: FeatureType.Reducer
    private var state: FeatureType.State
    private var receivedActions: [FeatureType.Action] = []

    public init(reducer: FeatureType.Reducer, initialState: FeatureType.Reducer.State) {
        self.reducer = reducer
        self.state = initialState
    }

    public func send(
        _ action: FeatureType.Action, expectedStateChanges: (FeatureType.State) -> Bool
    ) {
        receivedActions.append(action)
        state = reducer.reduce(oldState: state, action: action)
        let changeIsValid = expectedStateChanges(state)

        assert(
            changeIsValid, "Expected state change for action \(action) did not occur as expected.")
    }

    public func verifyActions(_ expectedActions: [FeatureType.Action]) {
        assert(
            receivedActions == expectedActions,
            "Actions received by the store do not match the expected actions.")
    }
}
