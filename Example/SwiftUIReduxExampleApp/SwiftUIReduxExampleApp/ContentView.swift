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
}
