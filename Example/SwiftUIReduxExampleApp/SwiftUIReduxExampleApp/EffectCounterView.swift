import SwiftUI
import SwiftUIRedux

struct EffectCounterView: View {
    @StateObject private var store: Store<EffectCounterFeature> = StoreFactory.createStore()

    var body: some View {
        VStack {
            if store.state.isLoading {
                ProgressView()
                    .id(1)
            } else {
                Text("Random Number: \(store.state.randomNumber)")
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity)
                    .transition(.scale.combined(with: .opacity))
            }
            
            List {
                Section {
                    Button("Get Random Number (Thunk)") {
                        store.send(EffectCounterFeature.createFetchAsyncRandomNumberAction())
                    }
                    .disabled(store.state.isLoading)
                    .buttonStyle(BorderedButtonStyle(tint: .blue))
                    
                    Button("Get Random Number (Async)") {
                        store.send(.effect(EffectCounterFeature.createFetchAsyncRandomNumberActionWithAsyncEffectAnimation()))
                    }
                    .disabled(store.state.isLoading)
                    .buttonStyle(BorderedButtonStyle(tint: .green))
                    
                    Button("Get Random Number (Async with await)") {
                        Task {
                            await store.send(EffectCounterFeature.createFetchAsyncRandomNumberActionWithAsyncEffectAnimation())
                        }
                    }
                    .disabled(store.state.isLoading)
                    .buttonStyle(BorderedButtonStyle(tint: .green))
                }
            }
            .listStyle(InsetGroupedListStyle())
            .animation(.spring(), value: store.state.isLoading)
            .navigationTitle("Async Effect Example")
            .refreshable {
                await store.send(EffectCounterFeature.createFetchAsyncRandomNumberActionWithAsyncEffect())
            }
        }
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
        let loggingMiddleware = LoggingMiddleware<EffectCounterFeature>()

        return [AnyMiddleware(thunkMiddleware), AnyMiddleware(loggingMiddleware)]
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
    
    static func createFetchAsyncRandomNumberActionWithAsyncEffect() -> AsyncEffectAction<State, Action> {
        AsyncEffectAction<State, Action> { dispatch, getState in
            let state = getState()
            print("Current random number (Async): \(state.randomNumber)")
            
            
            try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
            let randomNumber = Int.random(in: 1...100)
            dispatch(.setNumber(randomNumber))
        }
    }
    
    static func createFetchAsyncRandomNumberActionWithAsyncEffectAnimation() -> AsyncAnimationEffectAction<State, Action> {
        AsyncAnimationEffectAction<State, Action> { dispatch, getState in
            let state = getState()
            print("Current random number (Async): \(state.randomNumber)")
            
            dispatch(.startLoading, .default)

            try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
            let randomNumber = Int.random(in: 1...100)
            dispatch(.setNumber(randomNumber), .default)
            
            dispatch(.endLoading, .default)
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
