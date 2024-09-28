//
//  Created by belyenochi on 2024/06/06.
//

import Foundation

@MainActor
public class LoggingMiddleware<T: Feature>: Middleware {
    public init() {}

    public func process(store: Store<T>, action: ReduxAction<T.Action>) async {
        switch action {
        case .normal(let action):
            print("Dispatching normal action: \(action)")
        case .effect(let effect):
            print("Dispatching effect action: \(effect)")
        }
        // 中间件链会自动继续，无需调用 next
        // 在所有中间件和 reducer 处理完毕后，打印状态
        print("State after action: \(store.state)")
    }
}
