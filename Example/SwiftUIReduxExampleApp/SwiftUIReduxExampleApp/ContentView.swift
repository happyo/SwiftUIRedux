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
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("基础计数器示例", destination: BasicCounterView())
                NavigationLink("异步效果示例", destination: EffectCounterView())
                NavigationLink("混合状态示例", destination: InternalStateExampleView())
                NavigationLink("动画计数器示例", destination: AnimatedCounterView())
            }
            .navigationTitle("Redux 示例集")
        }
    }
//        
//    func fetchCount() {
//        // 发送异步 EffectAction
//        let fetchDataAction = ThunkAnimationEffectAction<CountReduxFeature.State, CountReduxFeature.Action> { dispatch, getState in
//            dispatch(.start, nil)  // Dispatch success action
//            let someModel = SomeModel(a: 2)
////
////            // 模拟延迟 2 秒
//            Task {
//                try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
//                let data = 4
//                dispatch(.success(data), .easeInOut(duration: 2))  // Dispatch success action
//                dispatch(.passSomeModel(someModel), nil)
//            }
////
////            // 模拟获取数据
//            
//        }
//        countStore.send(.effect(fetchDataAction))
////        countStore.send(.normal(.start))
//    }
}
