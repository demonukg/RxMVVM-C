import Swinject
import Alamofire

struct ApiServicesAssembly: Assembly {

  func assemble(container: Container) {

    container.register(ApiRequestInterceptor.self) { resolver in
      let authService = resolver.resolve(AuthenticationService.self)!
      let interceptor = ApiRequestInterceptorImpl(authService: authService)
      return interceptor
    }

    container.register(Session.self) { resolver in
      let interceptor = resolver.resolve(ApiRequestInterceptor.self)
      let session = Session(startRequestsImmediately: false, interceptor: interceptor)
      return session
    }
    .inObjectScope(.container)

    container.register(ApiRequestable.self) { (resolver, target: ApiTarget) in
      let session = resolver.resolve(Session.self)!
      let authUrl = URL(string: "http://89.108.65.107:8000/api")!
      let profileUrl = URL(string: "http://89.108.65.107:8002/api")!
      return ApiRequest(
        authUrl: authUrl,
        profileUrl: profileUrl,
        target: target,
        manager: session
      )
    }
    .inObjectScope(.transient)

    container.register(ApiService.self) { resolver in
      ApiServiceImpl { target in
        resolver.resolve(ApiRequestable.self, argument: target)!
      }
    }
    .inObjectScope(.container)
  }
}
