import SwiftUI
import PaystackCore

private struct DisplayAudienceKey: EnvironmentKey {
    static let defaultValue: DisplayAudience = .customerFacing
}

extension EnvironmentValues {
    var displayAudience: DisplayAudience {
        get { self[DisplayAudienceKey.self] }
        set { self[DisplayAudienceKey.self] = newValue }
    }
}
