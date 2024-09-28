//
//  Created by belyenochi on 2024/05/16.
//

import Foundation

@MainActor
public protocol Feature {
    associatedtype State: Sendable
    associatedtype Action: Sendable
    associatedtype Reducer: ReducerProtocol where Reducer.State == State, Reducer.Action == Action

    static func initialState() -> State
    static func createReducer() -> Reducer
    static func middlewares() -> [AnyMiddleware<Self>]
}
