//
//  Created by belyenochi on 2024/07/02.
//

import SwiftUI

public class StoreFactory {
    public static func createStore<FeatureType: Feature>(
        initialState: FeatureType.State? = nil, defaultReducer: FeatureType.Reducer? = nil
    ) -> Store<FeatureType> {
        return Store(
            initialState: initialState ?? FeatureType.initialState(),
            reducer: defaultReducer ?? FeatureType.createReducer(),
            middlewares: FeatureType.middlewares()
        )
    }

    public static func createStore<FeatureType: Feature>(
        otherMiddlewares: [AnyMiddleware<FeatureType>]
    ) -> Store<FeatureType> {
        return Store(
            initialState: FeatureType.initialState(),
            reducer: FeatureType.createReducer(),
            middlewares: FeatureType.middlewares() + otherMiddlewares
        )
    }
}
