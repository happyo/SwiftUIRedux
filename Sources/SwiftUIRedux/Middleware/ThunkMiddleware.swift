//
//  Created by belyenochi on 2024/05/16.
//

import Foundation

public class ThunkMiddleware<T: Feature>: Middleware {
    public init() {}

    public func process(store: Store<T>, action: ReduxAction<T.Action>, next: @escaping Dispatch<ReduxAction<T.Action>>) {
        switch action {
        case .normal(let action):
            next(.normal(action))
        case .effect(let effect):
            if let effectAction = effect as? ThunkEffectAction<T.State, T.Action> {
                effectAction.execute(dispatch: { next(.normal($0)) }, getState: { store.state })
            } else {
                next(.effect(effect))
            }
        }
    }
}

public protocol ThunkEffectActionProtocol: EffectAction {
    associatedtype State
    associatedtype Action

    func execute(dispatch: @escaping (Action) -> Void, getState: @escaping () -> State)
}

public struct ThunkEffectAction<State, Action>: ThunkEffectActionProtocol {
    private let _execute: (@escaping (Action) -> Void, @escaping () -> State) -> Void

    public init(execute: @escaping (@escaping (Action) -> Void, @escaping () -> State) -> Void) {
        self._execute = execute
    }

    public func execute(dispatch: @escaping (Action) -> Void, getState: @escaping () -> State) {
        _execute(dispatch, getState)
    }
}
