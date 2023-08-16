import SwiftUI

struct Constants {
    static let quarterPadding: CGFloat = 2
    static let halfPadding: CGFloat = 4
    static let singlePadding: CGFloat = 8
    static let doublePadding: CGFloat = 16
    static let triplePadding: CGFloat = 24
    static let quadPadding: CGFloat = 32

    static let cornerRadius: CGFloat = 8
    static let buttonHeight: CGFloat = 56
}

extension CGFloat {
    static var quarterPadding: CGFloat {
        return Constants.quarterPadding
    }

    static var halfPadding: CGFloat {
        return Constants.halfPadding
    }

    static var singlePadding: CGFloat {
        return Constants.singlePadding
    }

    static var doublePadding: CGFloat {
        return Constants.doublePadding
    }

    static var triplePadding: CGFloat {
        return Constants.triplePadding
    }

    static var quadPadding: CGFloat {
        return Constants.quadPadding
    }

    static var cornerRadius: CGFloat {
        return Constants.cornerRadius
    }

    static var buttonHeight: CGFloat {
        return Constants.buttonHeight
    }
}
