import Foundation

public protocol Queryable {
    var keyPair: (String, String) { get }
}

public extension Array where Element: Queryable {

    var keyPairs: [(String, String)] {
        return map { $0.keyPair }
    }

}
