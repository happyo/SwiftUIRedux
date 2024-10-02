//
//  Created by belyenochi on 2024/05/16.
//

import Foundation

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
