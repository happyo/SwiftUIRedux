//
//  RouterFeature.swift
//  SwiftUIReduxExampleApp
//
//  Created by belyenochi on 2024/5/22.
//

import SwiftUI
import SwiftUIRedux
class ViewManager {
    private var viewBuilders = [String: Any]()

    // 注册视图生成器
    func register<D: Hashable, V: View>(dataType: D.Type, builder: @escaping (D) -> V) {
        let key = String(describing: D.self)
        viewBuilders[key] = builder
    }

    // 根据数据类型和具体数据获取视图
    @ViewBuilder
    func viewFor<D: Hashable, V: View>(data: D) -> some View {
        let key = String(describing: D.self)
        if let builder = viewBuilders[key] as? (D) -> some View {
            builder(data)
        } else {
            EmptyView()
        }
    }
}
// HomeModule
public struct HomePage: View {
    public var name: String
    
    public var body: some View {
        
        Text("Home")
        Text(name)
        Button("GoSetting") {
            goSetting()
        }
    }
    
    func goSetting() {
        // Use in HomeModule
    }
}

// SettingModule
public struct SettingPage: View {
    public var body: some View {
        Text("Setting")
    }
}



// RouterLayer
protocol ModuleRoute {
    static func key() -> String
    func params() -> [String: Any]?
}

extension ModuleRoute {
    static func key() -> String {
        return String(describing: type(of: self))
    }
}

class HomePageRoute: ModuleRoute {
    var name: String = ""
    func params() -> [String : Any]? {
        return ["name" : name]
    }
}

class SettingRouter: ModuleRoute {
    func params() -> [String : Any]? {
        return nil
    }
}
//
//protocol ModuleProvider {
//    associatedtype Content: View
//    associatedtype RouteType: ModuleRoute
//    
//    func createView(route: RouteType) -> Content
//    func performAction(route: RouteType)
//}
//
//extension ModuleProvider {
//    func performAction(route: RouteType) {
//        
//    }
//}
//
//struct AnyModuleProvider<Route: ModuleRoute>: ModuleProvider {
//    private let _createView: (Route) -> AnyView
//
//    init<Provider: ModuleProvider>(_ provider: Provider) where Provider.RouteType == Route {
//        _createView = { route in AnyView(provider.createView(route: route)) }
//    }
//
//    func createView(route: Route) -> some View {
//        _createView(route)
//    }
//}
//
//
//
//class ModuleManager {
//    private var providers: [String: any ModuleProvider] = [:]
//    private var viewTypes = [(routeType: ModuleRoute, viewType: View)]()
//
//    static let shared = ModuleManager()
//
//    func registerProvider<Route: ModuleRoute, Provider: ModuleProvider>(_ provider: Provider) where Provider.RouteType == Route {
//        let key = Provider.RouteType.key()
//        providers[key] = provider
//        viewTypes[key] = Provider.Content.self
//    }
//
//    private func providerFor<Route: ModuleRoute>(route: Route) -> any ModuleProvider {
//        let key = Route.key()
//
//        providers[key]
//    }
//    
//    @ViewBuilder
//    func viewFor<Route: ModuleRoute>(route: Route) -> some View {
//        let provider: any ModuleProvider = providerFor(route: route)
//            
//        
//        provider.createView(route:route)
//            
//            
//            
////            if let viewType = viewTypes[key] {
////                if let view = provider.createView(route: route) as? viewType.Type {
////                    view
////                } else {
////                    EmptyView()
////                }
////            } else {
////                EmptyView()
////            }
////        } else {
////            EmptyView()
////        }
//    }
//
//    func performAction<Route: ModuleRoute>(route: Route) {
//        if let provider: AnyModuleProvider<Route> = providerFor(route: route) {
//            provider.performAction(route: route)
//        }
//    }
//}
//
//
//
// Use
struct HontentView: View {
    let manager = ViewManager()

    init() {
        // 注册视图和对应数据处理闭包
        manager.register(dataType: Int.self) { item in
            Text("Item is \(item)")
        }
    }

    var body: some View {
        VStack {
            // 使用数据获取视图
            manager.viewFor(data: 5)
        }
    }
}
