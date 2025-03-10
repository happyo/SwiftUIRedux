import SwiftUI
import SwiftUIRedux

struct InternalStateExampleView: View {
    @StateObject private var store: Store<MixedStateFeature> = StoreFactory.createStore()
    @State private var localCounter = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("全局状态: \(store.state.globalCount)")
                .font(.title)
            
            Text("本地状态: \(localCounter)")
                .font(.title)
                .foregroundColor(.secondary)
            
            HStack(spacing: 20) {
                Button("全局+1") { store.send(.incrementGlobal) }
                Button("全局-1") { store.send(.decrementGlobal) }
            }
            .buttonStyle(CircleButtonStyle(color: .purple))
            
            Divider().padding()
            
            HStack(spacing: 20) {
                Button("本地+1") { localCounter += 1 }
                Button("本地-1") { localCounter -= 1 }
            }
            .buttonStyle(CircleButtonStyle(color: .orange))
            
            Button("重置所有") {
                store.send(.reset)
                localCounter = 0
            }
            .buttonStyle(BorderedButtonStyle(tint: .red))
        }
        .navigationTitle("混合状态示例")
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
