import Foundation

protocol FormValidator: AnyObject {
    var errorMessage: String { get }

    func validate() -> Bool
}
