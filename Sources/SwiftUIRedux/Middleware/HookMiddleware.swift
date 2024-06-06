//
//  Created by belyenochi on 2024/06/06.
//

import Foundation

public class HookMiddleware<T: Feature>: Middleware {
    public typealias Hook = (ReduxAction<T.Action>, T.State) -> Void

    private var beforeSendHooks: [Hook] = []
    private var afterSendHooks: [Hook] = []

    public init() {}

    public func addBeforeSendHook(_ hook: @escaping Hook) {
        beforeSendHooks.append(hook)
    }

    public func addAfterSendHook(_ hook: @escaping Hook) {
        afterSendHooks.append(hook)
    }

    public func process(store: Store<T>, action: ReduxAction<T.Action>, next: @escaping Dispatch<ReduxAction<T.Action>>) {
        beforeSendHooks.forEach { $0(action, store.state) }

        next(action)

        afterSendHooks.forEach { $0(action, store.state) }
    }
}
