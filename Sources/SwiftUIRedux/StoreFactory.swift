//
//  Created by belyenochi on 2024/07/02.
//

import SwiftUI

public class StoreFactory {
    @MainActor
    public static func createStore<FeatureType: Feature>(
        initialState: FeatureType.State? = nil, defaultReducer: FeatureType.Reducer? = nil,
        otherMiddlewares: [AnyMiddleware<FeatureType>] = []
    ) -> Store<FeatureType> {
        return Store(
            initialState: initialState ?? FeatureType.initialState(),
            reducer: defaultReducer ?? FeatureType.createReducer(),
            middlewares: FeatureType.middlewares() + otherMiddlewares
        )
    }
}
