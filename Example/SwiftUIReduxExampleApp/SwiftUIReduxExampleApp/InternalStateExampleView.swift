import SwiftUI
import SwiftUIRedux

struct InternalStateExampleView: View {
    @StateObject private var store: Store<MixedStateFeature> = StoreFactory.createStore(internalState: MixedStateFeature.InternalState())

    var body: some View {
        VStack(spacing: 20) {
            Text("Published State: \(store.state.publishedCount)")
                .font(.title)

            Text("Not published State: \(store.internalState?.notPublishedCount ?? 0)")
                .font(.title)
                .foregroundColor(.secondary)

            HStack(spacing: 20) {
                Button("Published +1") { store.send(.incrementPublished) }

                Button("Published -1") { store.send(.decrementPublished) }
            }

            Divider().padding()

            HStack(spacing: 20) {
                Button("Not published +1") { store.internalState?.notPublishedCount += 1 }
                Button("Not published -1") { store.internalState?.notPublishedCount -= 1 }
            }

            Button("Reset All") {
                store.send(.reset)
                store.internalState?.notPublishedCount = 0
            }
            .buttonStyle(BorderedButtonStyle(tint: .red))
        }
        .navigationTitle("Combined State Example")
    }
}

struct MixedStateFeature: Feature {
    struct State {
        var publishedCount = 0
    }
    
    struct InternalState {
        var notPublishedCount = 0
    }

    enum Action {
        case incrementPublished
        case decrementPublished
        case reset
    }

    struct Reducer: ReducerProtocol {
        func reduce(oldState: State, action: Action) -> State {
            var state = oldState
            switch action {
            case .incrementPublished:
                state.publishedCount += 1
            case .decrementPublished:
                state.publishedCount -= 1
            case .reset:
                state.publishedCount = 0
            }
            return state
        }
    }

    static func initialState() -> State { State() }
    static func createReducer() -> Reducer { Reducer() }
}
