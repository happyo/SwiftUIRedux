//
//  Created by belyenochi on 2024/06/06.
//

import Foundation

@MainActor
public class HookMiddleware<T: Feature>: Middleware {
    public typealias Hook = (ReduxAction<T.Action>, T.State) -> Void
    public var next: AnyMiddleware<T>?

    private var beforeSendHooks: [Hook] = []
    private var afterSendHooks: [Hook] = []

    public init() {}

    public func addBeforeSendHook(_ hook: @escaping Hook) {
        beforeSendHooks.append(hook)
    }

    public func addAfterSendHook(_ hook: @escaping Hook) {
        afterSendHooks.append(hook)
    }

    public func process(store: Store<T>, action: ReduxAction<T.Action>) {
        next?.process(store: store, action: action)
    }
    
    public func beforeProcess(store: Store<T>, action: ReduxAction<T.Action>) {
        beforeSendHooks.forEach { $0(action, store.state) }
    }
    
    public func afterProcess(store: Store<T>, action: ReduxAction<T.Action>) {
        afterSendHooks.forEach { $0(action, store.state) }
    }
}
