import Foundation

protocol PinTextFieldDelegate: AnyObject {
    func didUserFinishEnter(the code: String)
}
