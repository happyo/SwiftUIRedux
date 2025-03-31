//
//  Created by belyenochi on 2024/05/16.
//

import SwiftUI

@MainActor
public class ThunkMiddleware<T: Feature>: Middleware {
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
    
    public func processAsync(store: Store<T>, action: EffectAction) async {
        if let asyncAction = action as? AsyncEffectAction<T.State, T.Action> {
            await asyncAction.executeAsync(
                dispatch: { action in
                    store.send(.normal(action))
                },
                getState: {
                    store.state
                }
            )
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
public struct AsyncEffectAction<State, Action>: EffectAction {
    private let _execute: (
        @escaping @Sendable @MainActor (Action) -> Void,
        @escaping @Sendable @MainActor () -> State
    ) async -> Void
    
    public init(
        execute: @escaping (
            @escaping @Sendable @MainActor (Action) -> Void,
            @escaping @Sendable @MainActor () -> State
        ) async -> Void
    ) {
        self._execute = execute
    }
    
    public func executeAsync(
        dispatch: @escaping @Sendable @MainActor (Action) -> Void,
        getState: @escaping @Sendable @MainActor () -> State
    ) async {
        await _execute(dispatch, getState)
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
