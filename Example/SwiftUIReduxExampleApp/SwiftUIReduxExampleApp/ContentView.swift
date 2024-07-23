//
//  ContentView.swift
//  SwiftUIReduxExampleApp
//
//  Created by belyenochi on 2024/5/16.
//

import SwiftUI
import SwiftUIRedux
import Combine

struct ContentView: View {
    @ObservedObject var countStore: Store<CountReduxFeature>
    let actionPublisherMiddleware: ActionPublisherMiddleware<CountReduxFeature>

    init() {
        actionPublisherMiddleware =  ActionPublisherMiddleware<CountReduxFeature>()
        countStore =  StoreFactory.createStore(initialState: CountReduxFeature.State(count: 10), otherMiddlewares: [AnyMiddleware(actionPublisherMiddleware)])
    }
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea(.all)
            
            VStack {
                if countStore.state.isLoading {
                    ProgressView()
                        .frame(width: 100, height: 100)
                }
                
                Text("Counter: \(countStore.state.count)")
                Button("increase") {
                    countStore.send(.normal(.increase))
                }
                Button("decrease") {
                    countStore.send(.normal(.decrease))
                }
                
                Button("Change") {
                    fetchCount()
                }
                
                TextField("Enter text", text: countStore.text)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()

                Text("You entered: \(countStore.state.text)")
                                .padding()
            }
            
        }
        .onAppear {


            
        }
        .onDisappear {
        }
        .onReceive(actionPublisherMiddleware.actionPublisher) { action in
            switch action {
            case .decrease:
                print("decrease")
            default:
                break
            }
        }
    }
    
    func fetchCount() {
        // 发送异步 EffectAction
        let fetchDataAction = ThunkEffectAction<CountReduxFeature.State, CountReduxFeature.Action> { dispatch, getState in
            DispatchQueue.main.async {
                dispatch(.start)  // Dispatch success action
            }
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 2, execute: {
                // Simulate fetching data
                let data = 4
                DispatchQueue.main.async {
                    dispatch(.success(data))  // Dispatch success action
                }
            })
        }
        countStore.send(.effect(fetchDataAction))
//        countStore.send(.normal(.start))
    }
}
