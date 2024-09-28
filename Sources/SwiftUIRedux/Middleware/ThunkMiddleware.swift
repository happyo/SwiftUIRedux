//
//  Created by belyenochi on 2024/05/16.
//

import Foundation

@MainActor
public class ThunkMiddleware<T: Feature>: Middleware {
    public init() {}

    public func process(store: Store<T>, action: ReduxAction<T.Action>) async {
        switch action {
        case .normal:
            break
        case .effect(let effect):
            if let effectAction = effect as? ThunkEffectAction<T.State, T.Action> {
                await effectAction.execute(
                    dispatch: { action in
                        await store.send(.normal(action))
                    },
                    getState: {
                        await store.state
                    }
                )
            }
        }
    }
}

public protocol ThunkEffectActionProtocol: EffectAction {
    associatedtype State: Sendable
    associatedtype Action: Sendable

    func execute(
        dispatch: @escaping @Sendable (Action) async -> Void,
        getState: @escaping @Sendable () async -> State
    ) async
}

public struct ThunkEffectAction<State: Sendable, Action: Sendable>: ThunkEffectActionProtocol,
    Sendable
{
    private let _execute:
        @Sendable (
            @escaping @Sendable (Action) async -> Void, @escaping @Sendable () async -> State
        ) async -> Void

    public init(
        execute: @escaping @Sendable (
            @escaping @Sendable (Action) async -> Void, @escaping @Sendable () async -> State
        ) async -> Void
    ) {
        self._execute = execute
    }

    public func execute(
        dispatch: @escaping @Sendable (Action) async -> Void,
        getState: @escaping @Sendable () async -> State
    ) async {
        await _execute(dispatch, getState)
    }
}
