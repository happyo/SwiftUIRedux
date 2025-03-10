import SwiftUI
import SwiftUIRedux

struct InternalStateExampleView: View {
    @StateObject private var store: Store<MixedStateFeature> = StoreFactory.createStore()
    @State private var localCounter = 0

    var body: some View {
        VStack(spacing: 20) {
            Text("Global State: \(store.state.globalCount)")
                .font(.title)

            Text("Local State: \(localCounter)")
                .font(.title)
                .foregroundColor(.secondary)

            HStack(spacing: 20) {
                Button("Global +1") { store.send(.incrementGlobal) }
                Button("Global -1") { store.send(.decrementGlobal) }
            }
            .buttonStyle(CircleButtonStyle(color: .purple))

            Divider().padding()

            HStack(spacing: 20) {
                Button("Local +1") { localCounter += 1 }
                Button("Local -1") { localCounter -= 1 }
            }
            .buttonStyle(CircleButtonStyle(color: .orange))

            Button("Reset All") {
                store.send(.reset)
                localCounter = 0
            }
            .buttonStyle(BorderedButtonStyle(tint: .red))
        }
        .navigationTitle("Combined State Example")
    }
}

struct MixedStateFeature: Feature {
    struct State: Equatable {
        var globalCount = 0
    }

    enum Action: Equatable {
        case incrementGlobal
        case decrementGlobal
        case reset
    }

    struct Reducer: ReducerProtocol {
        func reduce(oldState: State, action: Action) -> State {
            var state = oldState
            switch action {
            case .incrementGlobal: state.globalCount += 1
            case .decrementGlobal: state.globalCount -= 1
            case .reset: state.globalCount = 0
            }
            return state
        }
    }

    static func initialState() -> State { State() }
    static func createReducer() -> Reducer { Reducer() }
}
