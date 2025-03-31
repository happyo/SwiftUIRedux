//
//  Created by belyenochi on 2024/05/16.
//

import SwiftUI

@MainActor
public class ThunkMiddleware<T: Feature>: Middleware {
    private func handleAsyncEffect(_ effect: EffectAction, store: Store<T>) async {
        if let asyncEffect = effect as? any AsyncEffectAction {
            await asyncEffect.executeAsync(
                dispatch: { action in
                    if let action = action as? T.Action {
                        store.send(.normal(action))
                    }
                },
                getState: { store.state }
            )
        }
    }
    public var next: AnyMiddleware<T>?

    public init() {}

    public func process(store: Store<T>, action: ReduxAction<T.Action>) {
        switch action {
        case .normal:
            break
        case .effect(let effect):
            if let effectAction = effect as? ThunkEffectAction<T.State, T.Action> {
                effectAction.execute(
                    dispatch: { action in
                        store.send(.normal(action))
                    },
                    getState: {
                        store.state
                    }
                )
            } else if let animationEffectAction = effect as? ThunkAnimationEffectAction<T.State, T.Action> {
                animationEffectAction.execute { action, animation in
                    store.send(.normal(action), animation: animation)
                } getState: {
                    store.state
                }
            } else if let transactionEffectAction = effect as? ThunkTransactionEffectAction<T.State, T.Action> {
                transactionEffectAction.execute { action, transaction in
                    store.send(.normal(action), transaction: transaction)
                } getState: {
                    store.state
                }
            }
        }
    }
    
    public func processAsync(store: Store<T>, action: ReduxAction<T.Action>) async {
        switch action {
        case .normal:
            break
        case .effect(let effect):
            if let effectAction = effect as? ThunkEffectAction<T.State, T.Action> {
                await effectAction.executeAsync(
                    dispatch: { action in
                        store.send(.normal(action))
                    },
                    getState: {
                        store.state
                    }
                )
            } else if let animationEffectAction = effect as? ThunkAnimationEffectAction<T.State, T.Action> {
                await animationEffectAction.executeAsync { action, animation in
                    store.send(.normal(action), animation: animation)
                } getState: {
                    store.state
                }
            } else if let transactionEffectAction = effect as? ThunkTransactionEffectAction<T.State, T.Action> {
                await transactionEffectAction.executeAsync { action, transaction in
                    store.send(.normal(action), transaction: transaction)
                } getState: {
                    store.state
                }
            }
        }
    }
}

@MainActor
public struct ThunkEffectAction<State, Action>: EffectAction {
    private let _execute:
        (
            @escaping (Action) -> Void, @escaping () -> State
        ) -> Void

    public init(
        execute: @escaping (
            @escaping (Action) -> Void, @escaping () -> State
        ) -> Void
    ) {
        self._execute = execute
    }

    public func execute(
        dispatch: @escaping (Action) -> Void,
        getState: @escaping () -> State
    ) {
        _execute(dispatch, getState)
    }
}

@MainActor
public struct ThunkAnimationEffectAction<State, Action>: EffectAction {
    private let _execute:
        (
            @escaping (Action, Animation?) -> Void, @escaping () -> State
        ) -> Void

    public init(
        execute: @escaping (
            @escaping (Action, Animation?) -> Void, @escaping () -> State
        ) -> Void
    ) {
        self._execute = execute
    }

    public func execute(
        dispatch: @escaping (Action, Animation?) -> Void,
        getState: @escaping () -> State
    ) {
        _execute(dispatch, getState)
    }
}

@MainActor
public struct ThunkAsyncAction<State, Action>: AsyncEffectAction {
    private let _execute: (
        @escaping @Sendable @MainActor (Action) -> Void,
        @escaping @Sendable () -> State
    ) async -> Void
    
    public init(
        execute: @escaping (
            @escaping @Sendable @MainActor (Action) -> Void,
            @escaping @Sendable () -> State
        ) async -> Void
    ) {
        self._execute = execute
    }
    
    public func executeAsync(
        dispatch: @escaping @Sendable @MainActor (Any) -> Void,
        getState: @escaping @Sendable () -> Any
    ) async {
        await _execute(
            { action in dispatch(action) },
            { getState() as! State }
        )
    }
}

@MainActor
public struct ThunkTransactionEffectAction<State, Action>: EffectAction {
    private let _execute:
        (
            @escaping (Action, Transaction?) -> Void, @escaping () -> State
        ) -> Void

    public init(
        execute: @escaping (
            @escaping (Action, Transaction?) -> Void, @escaping () -> State
        ) -> Void
    ) {
        self._execute = execute
    }

    public func execute(
        dispatch: @escaping (Action, Transaction?) -> Void,
        getState: @escaping () -> State
    ) {
        _execute(dispatch, getState)
    }
}
