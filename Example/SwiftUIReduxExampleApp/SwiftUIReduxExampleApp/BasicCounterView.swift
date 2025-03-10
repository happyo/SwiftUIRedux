import SwiftUI
import SwiftUIRedux

struct BasicCounterView: View {
    @StateObject private var store = StoreFactory.createStore(
        initialState: BasicCounterFeature.State(),
        middlewares: [LoggingMiddleware()]
    )
    
    var body: some View {
        VStack(spacing: 20) {
            Text("当前计数: \(store.state.count)")
                .font(.largeTitle)
            
            HStack(spacing: 20) {
                Button("−") { store.send(.decrement) }
                    .buttonStyle(CircleButtonStyle(color: .red))
                
                Button("+") { store.send(.increment) }
                    .buttonStyle(CircleButtonStyle(color: .green))
            }
        }
        .navigationTitle("基础计数器")
    }
}

struct BasicCounterFeature: Feature {
    struct State: Equatable {
        var count = 0
    }
    
    enum Action: Equatable {
        case increment
        case decrement
    }
    
    struct Reducer: ReducerProtocol {
        func reduce(oldState: State, action: Action) -> State {
            var state = oldState
            switch action {
            case .increment: state.count += 1
            case .decrement: state.count -= 1
            }
            return state
        }
    }
    
    static func initialState() -> State { State() }
    static func createReducer() -> Reducer { Reducer() }
}

struct CircleButtonStyle: ButtonStyle {
    var color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title)
            .padding()
            .background(color)
            .foregroundColor(.white)
            .clipShape(Circle())
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}
