import SwiftUI
import SwiftUIRedux

struct AnimatedCounterView: View {
    @StateObject private var store: Store<AnimatedCounterFeature> = StoreFactory.createStore()
    var body: some View {
        VStack(spacing: 30) {
            Text("\(store.state.count)")
                .font(.system(size: 60, weight: .bold))
                .scaleEffect(store.state.scale)
                .animation(.spring(response: 0.3, dampingFraction: 0.2), value: store.state.scale)

            HStack(spacing: 20) {
                Button(action: { store.send(.decrement) }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 40))
                }

                Button(action: { store.send(.increment) }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 40))
                }
            }
            .foregroundColor(.blue)

            Button("Random Number") {
                store.send(.random)
            }
            .buttonStyle(BorderedButtonStyle(tint: .green))
        }
        .navigationTitle("Animated Counter")
    }
}

struct AnimatedCounterFeature: Feature {
    struct State: Equatable {
        var count = 0
        var scale: CGFloat = 1.0
    }

    enum Action: Equatable {
        case increment
        case decrement
        case random
        case adjustScale(CGFloat)
    }

    struct Reducer: ReducerProtocol {
        func reduce(oldState: State, action: Action) -> State {
            var state = oldState
            switch action {
            case .increment:
                state.count += 1
                state.scale = 1.2
            case .decrement:
                state.count -= 1
                state.scale = 0.8
            case .random:
                state.count = Int.random(in: -50...50)
                state.scale = state.count % 2 == 0 ? 1.3 : 0.7
            case .adjustScale(let scale):
                state.scale = scale
            }
            return state
        }
    }

    static func initialState() -> State { State() }
    static func createReducer() -> Reducer { Reducer() }
}
