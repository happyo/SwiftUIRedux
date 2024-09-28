//
//  Created by belyenochi on 2024/06/06.
//

import Foundation

@MainActor
public class LoggingMiddleware<T: Feature>: Middleware {
    public var next: AnyMiddleware<T>?

    public init() {}

    public func process(store: Store<T>, action: ReduxAction<T.Action>) {
        next?.process(store: store, action: action)
    }
    
    public func beforeProcess(store: Store<T>, action: ReduxAction<T.Action>) {
        switch action {
        case .normal(let action):
            print("Dispatching normal action: \(action)")
        case .effect(let effect):
            print("Dispatching effect action: \(effect)")
        }
    }
    
    public func afterProcess(store: Store<T>, action: ReduxAction<T.Action>) {
        print("State after action: \(store.state)")
    }
}
