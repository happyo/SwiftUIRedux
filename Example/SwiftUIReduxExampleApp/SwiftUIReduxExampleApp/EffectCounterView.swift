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
                Text("随机数: \(store.state.randomNumber)")
                    .font(.largeTitle)
                    .transition(.scale.combined(with: .opacity))
            }
            
            Button("获取随机数") {
                store.send(.fetchRandomNumber)
            }
            .disabled(store.state.isLoading)
            .buttonStyle(BorderedButtonStyle(tint: .blue))
        }
        .animation(.spring(), value: store.state.isLoading)
        .navigationTitle("异步效果示例")
    }
}

struct EffectCounterFeature: Feature {
    struct State: Equatable {
        var randomNumber = 0
        var isLoading = false
    }
    
    enum Action: Equatable {
        case fetchRandomNumber
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
            case .fetchRandomNumber:
                // 由中间件处理异步操作
                break
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
