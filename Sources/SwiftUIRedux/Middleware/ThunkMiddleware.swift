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
            } else if let animationEffectAction = effect
                as? ThunkAnimationEffectAction<T.State, T.Action>
            {
                animationEffectAction.execute { action, animation in
                    store.send(.normal(action), animation: animation)
                } getState: {
                    store.state
                }
            } else if let transactionEffectAction = effect
                as? ThunkTransactionEffectAction<T.State, T.Action>
            {
                transactionEffectAction.execute { action, transaction in
                    store.send(.normal(action), transaction: transaction)
                } getState: {
                    store.state
                }
            } else if let effectInternalStateAction = effect as? ThunkEffectWithInternalStateAction<T.State, T.Action, T.InternalState> {
                effectInternalStateAction.execute(
                    dispatch: { action in
                        store.send(.normal(action))
                    },
                    getState: {
                        store.state
                    },
                    getInternalState: {
                        store.internalState
                    },
                    setInternalState: { internalState in
                        store.internalState = internalState
                    }
                )
            } else {
                Task {
                    await processAsync(store: store, action: effect)
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
        } else if let asyncAnimationAction = action
            as? AsyncAnimationEffectAction<T.State, T.Action>
        {
            await asyncAnimationAction.executeAsync(
                dispatch: { action, animation in
                    store.send(.normal(action), animation: animation)
                },
                getState: {
                    store.state
                }
            )
        } else if let asyncTransactionAction = action
            as? AsyncTransactionEffectAction<T.State, T.Action>
        {
            await asyncTransactionAction.executeAsync(
                dispatch: { action, transaction in
                    store.send(.normal(action), transaction: transaction)
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
public struct ThunkEffectWithInternalStateAction<State, Action, InternalState>: EffectAction {
    private let _execute:
        (
            @escaping (Action) -> Void, @escaping () -> State, @escaping () -> InternalState?,
            @escaping (InternalState) -> Void
        ) -> Void

    public init(
        execute: @escaping (
            @escaping (Action) -> Void, @escaping () -> State, @escaping () -> InternalState?,
            @escaping (InternalState) -> Void
        ) -> Void
    ) {
        self._execute = execute
    }

    public func execute(
        dispatch: @escaping (Action) -> Void,
        getState: @escaping () -> State,
        getInternalState: @escaping () -> InternalState?,
        setInternalState: @escaping (InternalState) -> Void
    ) {
        _execute(dispatch, getState, getInternalState, setInternalState)
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
    private let _execute:
        (
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

@MainActor
public struct AsyncAnimationEffectAction<State, Action>: EffectAction {
    private let _execute:
        (
            @escaping @Sendable @MainActor (Action, Animation?) -> Void,
            @escaping @Sendable @MainActor () -> State
        ) async -> Void

    public init(
        execute: @escaping (
            @escaping @Sendable @MainActor (Action, Animation?) -> Void,
            @escaping @Sendable @MainActor () -> State
        ) async -> Void
    ) {
        self._execute = execute
    }

    public func executeAsync(
        dispatch: @escaping @Sendable @MainActor (Action, Animation?) -> Void,
        getState: @escaping @Sendable @MainActor () -> State
    ) async {
        await _execute(dispatch, getState)
    }
}

@MainActor
public struct AsyncTransactionEffectAction<State, Action>: EffectAction {
    private let _execute:
        (
            @escaping @Sendable @MainActor (Action, Transaction?) -> Void,
            @escaping @Sendable @MainActor () -> State
        ) async -> Void

    public init(
        execute: @escaping (
            @escaping @Sendable @MainActor (Action, Transaction?) -> Void,
            @escaping @Sendable @MainActor () -> State
        ) async -> Void
    ) {
        self._execute = execute
    }

    public func executeAsync(
        dispatch: @escaping @Sendable @MainActor (Action, Transaction?) -> Void,
        getState: @escaping @Sendable @MainActor () -> State
    ) async {
        await _execute(dispatch, getState)
    }
}
