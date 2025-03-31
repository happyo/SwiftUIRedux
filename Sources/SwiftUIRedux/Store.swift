//
//  Created by belyenochi on 2024/05/16.
//

import SwiftUI

public protocol EffectAction {

}

public enum ReduxAction<Action> {
    case normal(Action)
    case effect(EffectAction)
}

@MainActor
public protocol StoreProtocol {
    associatedtype State
    associatedtype Action
    var state: State { get }
    func send(_ action: ReduxAction<Action>)
}

@MainActor
@dynamicMemberLookup
public class Store<T: Feature>: ObservableObject, StoreProtocol {

    @Published private(set) public var state: T.State
    public var internalState: T.InternalState?
    private var reducer: T.Reducer
    private var middlewareChain: MiddlewareChain<T>

    public init(
        initialState: T.State, reducer: T.Reducer, middlewares: [AnyMiddleware<T>] = [],
        internalState: T.InternalState? = nil
    ) {
        self.state = initialState
        if T.InternalState.self != Void.self {
            self.internalState = internalState
        } else {
            self.internalState = nil
        }
        self.reducer = reducer
        self.middlewareChain = MiddlewareChain(middlewares: middlewares)
    }

    public func withInternalState<R>(_ transform: (inout T.InternalState) -> R) -> R? {
        if var state = internalState {
            return transform(&state)
        }
        return nil
    }

    public func send(_ action: ReduxAction<T.Action>) {
        middlewareChain.process(store: self, action: action)
    }
    
    public func send(_ action: T.Action) {
        middlewareChain.process(store: self, action: .normal(action))
    }
    
    public func send(_ effectAction: EffectAction) {
        middlewareChain.process(store: self, action: .effect(effectAction))
    }
    
    @MainActor
    public func send(_ effectAction: EffectAction) async {
        await withCheckedContinuation { continuation in
            middlewareChain.process(store: self, action: .effect(effectAction))
            continuation.resume()
        }
    }

    public func send(_ action: ReduxAction<T.Action>, animation: Animation?) {
        middlewareChain.process(store: self, action: action, animation: animation)
    }

    public func send(_ action: T.Action, animation: Animation?) {
        middlewareChain.process(store: self, action: .normal(action), animation: animation)
    }

    public func send(_ effectAction: EffectAction, animation: Animation?) {
        middlewareChain.process(store: self, action: .effect(effectAction), animation: animation)
    }
    
    @MainActor
    public func send(_ effectAction: EffectAction, animation: Animation?) async {
        await withCheckedContinuation { continuation in
            middlewareChain.process(store: self, action: .effect(effectAction), animation: animation)
            continuation.resume()
        }
    }

    public func send(_ action: ReduxAction<T.Action>, transaction: Transaction?) {
        middlewareChain.process(store: self, action: action, transaction: transaction)
    }

    public func send(_ action: T.Action, transaction: Transaction?) {
        middlewareChain.process(store: self, action: .normal(action), transaction: transaction)
    }

    public func send(_ effectAction: EffectAction, transaction: Transaction?) {
        middlewareChain.process(store: self, action: .effect(effectAction), transaction: transaction)
    }
    
    @MainActor
    public func send(_ effectAction: EffectAction, transaction: Transaction?) async {
        await withCheckedContinuation { continuation in
            middlewareChain.process(store: self, action: .effect(effectAction), transaction: transaction)
            continuation.resume()
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

    fileprivate func reduce(action: T.Action, animation: Animation? = nil) {
        if let animation = animation {
            withAnimation(animation) {
                self.state = self.reducer.reduce(oldState: self.state, action: action)
            }
        } else {
            self.state = self.reducer.reduce(oldState: self.state, action: action)
        }
    }

    fileprivate func reduce(action: T.Action, transaction: Transaction? = nil) {
        if let t = transaction {
            withTransaction(t) {
                self.state = self.reducer.reduce(oldState: self.state, action: action)
            }
        } else {
            self.state = self.reducer.reduce(oldState: self.state, action: action)
        }
    }
}

@MainActor
public class MiddlewareChain<T: Feature> {
    private var head: AnyMiddleware<T>?

    public init(middlewares: [AnyMiddleware<T>] = []) {
        if !middlewares.isEmpty {
            head = middlewares.first
            var current = head
            for i in 1..<middlewares.count {
                current?.next = middlewares[i]
                current = middlewares[i]
            }
        }
    }

    public func addMiddleware(_ middleware: AnyMiddleware<T>) {
        if head == nil {
            head = middleware
        } else {
            var current = head
            while current?.next != nil {
                current = current?.next
            }
            current?.next = middleware
        }
    }

    public func process(store: Store<T>, action: ReduxAction<T.Action>, animation: Animation? = nil)
    {
        executeBeforeProcessHooks(store: store, action: action)

        head?.process(store: store, action: action)

        if case .normal(let normalAction) = action {
            store.reduce(action: normalAction, animation: animation)
        }

        executeAfterProcessHooks(store: store, action: action)
    }

    public func process(store: Store<T>, action: ReduxAction<T.Action>, transaction: Transaction?) {
        executeBeforeProcessHooks(store: store, action: action)

        head?.process(store: store, action: action)

        if case .normal(let normalAction) = action {
            store.reduce(action: normalAction, transaction: transaction)
        }

        executeAfterProcessHooks(store: store, action: action)
    }

    private func executeBeforeProcessHooks(store: Store<T>, action: ReduxAction<T.Action>) {
        var current = head
        while current != nil {
            current?.beforeProcess(store: store, action: action)
            current = current?.next
        }
    }

    private func executeAfterProcessHooks(store: Store<T>, action: ReduxAction<T.Action>) {
        var current = head
        while current != nil {
            current?.afterProcess(store: store, action: action)
            current = current?.next
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

    @MainActor
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
