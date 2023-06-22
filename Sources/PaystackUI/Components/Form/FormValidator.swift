import Foundation

public protocol FormValidator: AnyObject {
    var errorMessage: String { get }

    func validate() -> Bool
}
