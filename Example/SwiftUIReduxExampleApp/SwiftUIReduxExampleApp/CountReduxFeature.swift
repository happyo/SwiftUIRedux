//
//  CountReduxFeature.swift
//  SwiftUIReduxExampleApp
//
//  Created by belyenochi on 2024/5/16.
//

import SwiftUIRedux

struct SomeModel {
    var a: Int
}

struct MyInternalState {
    var analyticsData: [String: Any] = [:]
}

struct CountReduxFeature: Feature {
    typealias InternalState = MyInternalState
    
    static func createInternalState() -> MyInternalState {
        return MyInternalState()
    }
    
    struct State {
        var count: Int = 0
        var isLoading: Bool = false
        var text: String = ""
        var someModel: SomeModel = SomeModel(a: 1)
    }
    
    enum Action {
        
        case increase
        case decrease
        
        case start
        case success(Int)
        case error(String)
        case passSomeModel(SomeModel)
    }
    
    struct Reducer: ReducerProtocol {
        func reduce(oldState: State, action: Action) -> State {
            var newState = oldState
            switch action {
            case .increase:
                newState.count += 1
            case .decrease:
                newState.count -= 1
                
            case .start:
                newState.isLoading = true
            case .success(let count):
                newState.isLoading = false
                newState.count = count
            case .error(_):
                newState.isLoading = false
            case .passSomeModel(let model):
                newState.someModel = model
            }
            
            return newState
        }
    }
    
    static func initialState() -> State {
        return State()
    }
    
    static func createReducer() -> Reducer {
        return Reducer()
    }
    
    static func middlewares() -> [AnyMiddleware<Self>] {
        let thunkMiddleware = ThunkMiddleware<CountReduxFeature>()
        let loggingMiddleware = LoggingMiddleware<CountReduxFeature>()
        
        return [AnyMiddleware(thunkMiddleware), AnyMiddleware(loggingMiddleware)]
//        return []
    }
}
