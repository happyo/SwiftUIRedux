//
//  Created by belyenochi on 2024/06/06.
//
import SwiftUI
import Combine

public class ActionPublisherMiddleware<T: Feature>: Middleware {
    // 使用 PassthroughSubject 来发布 Action
    public let actionPublisher = PassthroughSubject<T.Action, Never>()
    
    public init() {}

    public func process(store: Store<T>, action: ReduxAction<T.Action>, next: @escaping Dispatch<ReduxAction<T.Action>>) {
        // 将 action 发送到订阅者
        if case let .normal(action) = action {
            actionPublisher.send(action)
        }
        
        // 确保 action 继续向下传递到其他中间件或 reducer
        next(action)
    }
}
