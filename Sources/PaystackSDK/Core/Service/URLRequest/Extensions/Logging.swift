import Foundation
import UIKit

// MARK: - Logging
extension URLRequestBuilder {
    func addLoggingHeaders() -> Self {
        return addPlatformHeader()
            .addSDKVersionHeader()
            .addPlatformVersionHeader()
            .addDeviceModelHeader()
    }

    private func addPlatformHeader() -> Self {
        return addHeader("x-platform", "iOSSDK")
    }

    private func addSDKVersionHeader() -> Self {
        guard let versionUrl = Bundle.current.url(forResource: "versions",
                                                  withExtension: "plist"),
              let data = try? Data(contentsOf: versionUrl),
              let plist = try? PropertyListSerialization.propertyList(
                from: data, format: nil) as? [String: String],
                let versionNumber = plist["Version"] else {
            return self
        }

        return addHeader("sdk-version", versionNumber)
    }

    private func addPlatformVersionHeader() -> Self {
        let iosVersion = UIDevice.current.systemVersion
        return addHeader("platform-version", iosVersion)
    }

    private func addDeviceModelHeader() -> Self {
        return addHeader("device", UIDevice.modelName)
    }
}

private extension UIDevice {
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }()
}
