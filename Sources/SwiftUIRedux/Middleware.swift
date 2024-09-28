//
//  Created by belyenochi on 2024/05/16.
//

import Foundation

@MainActor
public protocol Middleware {
    associatedtype T: Feature

    var next: AnyMiddleware<T>? { get set }
    func process(store: Store<T>, action: ReduxAction<T.Action>)
    
    func beforeProcess(store: Store<T>, action: ReduxAction<T.Action>)

    func afterProcess(store: Store<T>, action: ReduxAction<T.Action>)
}


public extension Middleware {
    func beforeProcess(store: Store<T>, action: ReduxAction<T.Action>) {
        
    }

    func afterProcess(store: Store<T>, action: ReduxAction<T.Action>) {
        
    }
}

public typealias Dispatch<Action> = @Sendable (Action) -> Void

@MainActor
public class AnyMiddleware<T: Feature>: Middleware {
    private let _process: (Store<T>, ReduxAction<T.Action>) -> Void
    private let _beforeProcess: (Store<T>, ReduxAction<T.Action>) -> Void
    private let _afterProcess: (Store<T>, ReduxAction<T.Action>) -> Void
    
    public var next: AnyMiddleware<T>?

    public init<M: Middleware>(_ middleware: M) where M.T == T {
        self._process = middleware.process
        self._beforeProcess = middleware.beforeProcess
        self._afterProcess = middleware.afterProcess
    }

    public func process(store: Store<T>, action: ReduxAction<T.Action>) {
        _process(store, action)
        next?.process(store: store, action: action)
    }
    
    public func beforeProcess(store: Store<T>, action: ReduxAction<T.Action>) {
        _beforeProcess(store, action)
    }
    
    public func afterProcess(store: Store<T>, action: ReduxAction<T.Action>) {
        _afterProcess(store, action)
    }
}

