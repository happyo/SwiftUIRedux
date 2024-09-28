//
//  Created by belyenochi on 2024/06/06.
//

import Combine
import SwiftUI

@MainActor
public class ActionPublisherMiddleware<T: Feature>: Middleware {
    public let actionPublisher = PassthroughSubject<T.Action, Never>()

    public init() {}

    public func process(store: Store<T>, action: ReduxAction<T.Action>) async {
        if case let .normal(action) = action {
            self.actionPublisher.send(action)
        }
    }
}
