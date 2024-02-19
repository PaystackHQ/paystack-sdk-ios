import Foundation

class ServiceExecutorProvider {

    static var executor: ServiceExecutor = URLSession.shared

    static func execute(request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        self.executor.execute(request: request, completion: completion)
    }

    static func set(executor: ServiceExecutor) {
        self.executor = executor
    }

    static func reset() {
        self.executor = URLSession.shared
    }

}
