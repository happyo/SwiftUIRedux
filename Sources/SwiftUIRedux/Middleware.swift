//
//  Created by belyenochi on 2024/05/16.
//

import Foundation

public protocol Middleware {
    associatedtype T: Feature
    
    func process(store: Store<T>, action: ReduxAction<T.Action>, next: @escaping Dispatch<ReduxAction<T.Action>>)
}

public typealias Dispatch<Action> = (Action) -> Void

public struct AnyMiddleware<T: Feature>: Middleware {
    private let _process: (Store<T>, ReduxAction<T.Action>, @escaping Dispatch<ReduxAction<T.Action>>) -> Void

    public init<M: Middleware>(_ middleware: M) where M.T == T {
        self._process = middleware.process
    }

    public func process(store: Store<T>, action: ReduxAction<T.Action>, next: @escaping Dispatch<ReduxAction<T.Action>>) {
        _process(store, action, next)
    }
}

public class LoggingMiddleware<T: Feature>: Middleware {
    public func process(store: Store<T>, action: ReduxAction<T.Action>, next: @escaping Dispatch<ReduxAction<T.Action>>) {
        switch action {
        case .normal(let action):
            print("Dispatching normal action: \(action)")
        case .effect(let effect):
            print("Dispatching effect action: \(effect)")
        }
        next(action)
        print("State after action: \(store.state)")
    }
}

