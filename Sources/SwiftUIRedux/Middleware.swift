//
//  Created by belyenochi on 2024/05/16.
//

import Foundation

@MainActor
public protocol Middleware {
    associatedtype T: Feature

    func process(store: Store<T>, action: ReduxAction<T.Action>) async
}

public typealias Dispatch<Action> = @Sendable (Action) -> Void

@MainActor
public struct AnyMiddleware<T: Feature>: Middleware {
    private let _process: (Store<T>, ReduxAction<T.Action>) async -> Void

    public init<M: Middleware>(_ middleware: M) where M.T == T {
        self._process = middleware.process
    }

    public func process(store: Store<T>, action: ReduxAction<T.Action>) async {
        await _process(store, action)
    }
}
