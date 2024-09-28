//
//  Created by belyenochi on 2024/06/06.
//

import Combine
import SwiftUI

@MainActor
public class ActionPublisherMiddleware<T: Feature>: Middleware {
    public func process(store: Store<T>, action: ReduxAction<T.Action>) {
        if case let .normal(action) = action {
            self.actionPublisher.send(action)
        }
        
        next?.process(store: store, action: action)
    }
    
    public var next: AnyMiddleware<T>?
    public let actionPublisher = PassthroughSubject<T.Action, Never>()

    public init() {}
}
