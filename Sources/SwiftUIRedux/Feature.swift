//
//  Created by belyenochi on 2024/05/16.
//

import Foundation

@MainActor
public protocol Feature {
    associatedtype State
    associatedtype Action
    associatedtype Reducer: ReducerProtocol where Reducer.State == State, Reducer.Action == Action
    associatedtype InternalState = Void

    static func initialState() -> State
    static func createReducer() -> Reducer
    static func middlewares() -> [AnyMiddleware<Self>]
    static func createInternalState() -> InternalState
}
