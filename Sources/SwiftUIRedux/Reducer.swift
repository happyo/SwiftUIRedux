//
//  Created by belyenochi on 2024/05/16.
//
import Foundation

public protocol ReducerProtocol<State, Action> {
    associatedtype State
    associatedtype Action
    
    func reduce(oldState: State, action: Action) -> State
}
