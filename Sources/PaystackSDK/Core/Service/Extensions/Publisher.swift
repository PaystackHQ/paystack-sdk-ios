import Foundation
import Combine

@available(iOS 13.0, *)
public extension Service {

    func publisher() -> AnyPublisher<T, Error> {
        return Future { promise in
            async {
                if let result = $0 {
                    promise(.success(result))
                }

                promise(.failure($1 ?? PaystackError.technical))
            }
        }
        .eraseToAnyPublisher()
    }

}
