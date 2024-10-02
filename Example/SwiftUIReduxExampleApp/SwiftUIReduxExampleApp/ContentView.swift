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
    @StateObject var countStore: Store<CountReduxFeature>
    let actionPublisherMiddleware: ActionPublisherMiddleware<CountReduxFeature>
    let hookMiddleware: HookMiddleware<CountReduxFeature>

    init() {
        let middleware = ActionPublisherMiddleware<CountReduxFeature>()
        self.actionPublisherMiddleware = middleware
        
        let hookMiddleware = HookMiddleware<CountReduxFeature>()
        hookMiddleware.addAfterSendHook { action, state in
            print("hook action \(action)")
        }
        self.hookMiddleware = hookMiddleware

        // 在属性声明时使用闭包初始化 @StateObject
        self._countStore = StateObject(wrappedValue: StoreFactory.createStore(
            initialState: CountReduxFeature.State(count: 10),
            otherMiddlewares: [AnyMiddleware(middleware), AnyMiddleware(hookMiddleware)]
        ))
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
            dispatch(.start)  // Dispatch success action
            let someModel = SomeModel(a: 2)
//
//            // 模拟延迟 2 秒
            Task {
                try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
                let data = 4
                dispatch(.success(data))  // Dispatch success action
                dispatch(.passSomeModel(someModel))
            }
//
//            // 模拟获取数据
            
        }
        countStore.send(.effect(fetchDataAction))
//        countStore.send(.normal(.start))
    }
}
