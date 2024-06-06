//
//  Created by belyenochi on 2024/06/06.
//

import Foundation

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

