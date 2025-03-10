//
//  ContentView.swift
//  SwiftUIReduxExampleApp
//
//  Created by belyenochi on 2024/5/16.
//

import Combine
import SwiftUI
import SwiftUIRedux

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Basic Counter Example", destination: BasicCounterView())
                NavigationLink("Async Effect Example", destination: EffectCounterView())
                NavigationLink("Combined State Example", destination: InternalStateExampleView())
                NavigationLink("Animated Counter Example", destination: AnimatedCounterView())
            }
            .navigationTitle("Redux Examples")
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
