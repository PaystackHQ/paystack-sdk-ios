import Foundation

extension String {

    var removingAllWhitespaces: String {
        self.replacingOccurrences(of: " ", with: "")
    }

}
