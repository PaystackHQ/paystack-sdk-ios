import Foundation

public protocol PinTextFieldDelegate: AnyObject {
    func didUserFinishEnter(the code: String)
}
