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
                store.send(EffectCounterFeature.createFetchAsyncRandomNumberAction())
            }
            .disabled(store.state.isLoading)
            .buttonStyle(BorderedButtonStyle(tint: .blue))
        }
        .animation(.spring(), value: store.state.isLoading)
        .navigationTitle("Async Effect Example")
    }
}

struct EffectCounterFeature: Feature {
    struct State {
        var randomNumber = 0
        var isLoading = false
    }

    enum Action {
        case startLoading
        case endLoading
        case setNumber(Int)
    }

    struct Reducer: ReducerProtocol {
        func reduce(oldState: State, action: Action) -> State {
            var state = oldState
            switch action {
            case .startLoading:
                state.isLoading = true
            case .endLoading:
                state.isLoading = false
            case .setNumber(let number):
                state.randomNumber = number
            }
            return state
        }
    }

    static func initialState() -> State { State() }
    static func createReducer() -> Reducer { Reducer() }
    
    // Important, using async must add ThunkMiddleware
    static func middlewares() -> [AnyMiddleware<EffectCounterFeature>] {
        let thunkMiddleware = ThunkMiddleware<EffectCounterFeature>()
        
        return [AnyMiddleware(thunkMiddleware)]
    }

    static func createFetchAsyncRandomNumberAction() -> ThunkEffectAction<State, Action> {
        ThunkEffectAction<State, Action> { dispatch, getState in
            let state = getState()
            
            print("Current random number: \(state.randomNumber)")
            
            Task {
                dispatch(.startLoading)
                
                try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
                let randomNumber = Int.random(in: 1...100)
                dispatch(.setNumber(randomNumber))
                
                dispatch(.endLoading)
            }
        }
    }
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
