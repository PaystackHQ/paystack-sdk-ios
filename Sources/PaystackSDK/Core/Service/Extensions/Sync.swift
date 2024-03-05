import Foundation

public extension Service {

    func sync() throws -> T {
        let semaphore = DispatchSemaphore(value: 0)
        var result: T?
        var error: Error?
        async {
            result = $0
            error = $1
            semaphore.signal()
        }

        semaphore.wait()
        if let result = result {
            return result
        }

        throw error ?? PaystackError.technical
    }

}
