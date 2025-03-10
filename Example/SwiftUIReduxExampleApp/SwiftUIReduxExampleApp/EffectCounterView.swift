import SwiftUI
import SwiftUIRedux

struct EffectCounterView: View {
    @StateObject private var store: Store<EffectCounterFeature> = StoreFactory.createStore()

    var body: some View {
        VStack(spacing: 20) {
            if store.state.isLoading {
                ProgressView()
                    .scaleEffect(2.0)
            } else {
                Text("Random Number: \(store.state.randomNumber)")
                    .font(.largeTitle)
                    .transition(.scale.combined(with: .opacity))
            }

            Button("Get Random Number") {
            }
            .disabled(store.state.isLoading)
            .buttonStyle(BorderedButtonStyle(tint: .blue))
        }
        .animation(.spring(), value: store.state.isLoading)
        .navigationTitle("Async Effect Example")
    }

    // func fetchCount() {
    //     let fetchDataAction = ThunkAnimationEffectAction<
    //         CountReduxFeature.State, CountReduxFeature.Action
    //     > { dispatch, getState in
    //         dispatch(.start, nil)  // Dispatch success action

    //         Task {
    //             try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
    //             let data = 4
    //             dispatch(.success(data), .easeInOut(duration: 2))  // Dispatch success action
    //             dispatch(.passSomeModel(someModel), nil)
    //         }

    //     }
    //     countStore.send(.effect(fetchDataAction))
    //     countStore.send(.normal(.start))
    // }
}

struct EffectCounterFeature: Feature {
    struct State: Equatable {
        var randomNumber = 0
        var isLoading = false
    }

    enum Action: Equatable {
        case setLoading(Bool)
        case setNumber(Int)
    }

    struct Reducer: ReducerProtocol {
        func reduce(oldState: State, action: Action) -> State {
            var state = oldState
            switch action {
            case .setLoading(let loading):
                state.isLoading = loading
            case .setNumber(let number):
                state.randomNumber = number
                state.isLoading = false
            }
            return state
        }
    }

    static func initialState() -> State { State() }
    static func createReducer() -> Reducer { Reducer() }

    //    struct ThunkMiddleware: MiddlewareProtocol {
    //        func process(store: StoreProxy<EffectCounterFeature>, action: Action) {
    //            guard case .fetchRandomNumber = action else { return }
    //
    //            store.dispatch(.setLoading(true))
    //
    //            DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
    //                let random = Int.random(in: 1...100)
    //                store.dispatch(.setNumber(random))
    //            }
    //        }
    //    }
}

struct BorderedButtonStyle: ButtonStyle {
    var tint: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(tint.opacity(configuration.isPressed ? 0.5 : 0.2))
            .foregroundColor(tint)
            .clipShape(Capsule())
    }
}
