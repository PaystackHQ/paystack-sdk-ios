import Foundation

#if canImport(UIKit)
import UIKit
#endif

#if canImport(IOKit)
import IOKit
#endif

// MARK: - Logging
extension URLRequestBuilder {
    private static let operatingSystem: String = {
#if os(iOS)
#if targetEnvironment(macCatalyst)
        return "macOS - Catalyst"
#else
        return "iOS"
#endif
#else
        return "macOS"
#endif
    }()

    func addLoggingHeaders() -> Self {
        return addPlatformHeader()
            .addSDKVersionHeader()
            .addPlatformVersionHeader()
            .addDeviceIdentifier()
            .addDeviceModelHeader()
    }

    // TODO: Confirm if we want to do this or to hardcode it as iOSSDK regardless
    private func addPlatformHeader() -> Self {
        return addHeader("x-platform", "\(Self.operatingSystem)SDK")
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

        return addHeader("x-sdk-version", versionNumber)
    }

    private func addPlatformVersionHeader() -> Self {
        let osVersion = ProcessInfo().operatingSystemVersion
        let osVersionString = "\(osVersion.majorVersion).\(osVersion.minorVersion)"
        return addHeader("x-platform-version", "\(Self.operatingSystem) \(osVersionString)")
    }

    func addDeviceIdentifier() -> Self {
        addHeader("x-device-identifier", "sdk_ios_" + getDeviceID())
    }

    private func addDeviceModelHeader() -> Self {
        guard let modelName = getDeviceModel() else {
            return self
        }
        return addHeader("x-device", modelName)
    }

    private func getDeviceModel() -> String? {
#if canImport(UIKit)
        return UIDevice.modelName
#elseif canImport(IOKit)
        return getModelIdentifier()
#endif
    }

    private func getDeviceID() -> String {
#if canImport(UIKit)
        return UIDevice.deviceID
#elseif canImport(IOKit)
        return getModelIdentifier() ?? ""
#endif
    }

#if canImport(IOKit)
    func getModelIdentifier() -> String? {
        let service = IOServiceGetMatchingService(kIOMasterPortDefault,
                                                  IOServiceMatching("IOPlatformExpertDevice"))
        var modelIdentifier: String?
        if let modelData = IORegistryEntryCreateCFProperty(
            service, "model" as CFString, kCFAllocatorDefault, 0).takeRetainedValue() as? Data {
            modelIdentifier = String(data: modelData, encoding: .utf8)?.trimmingCharacters(in: .controlCharacters)
        }

        IOObjectRelease(service)
        return modelIdentifier
    }
#endif
}

#if canImport(UIKit)
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

    static let deviceID: String = {
        UIDevice.current.identifierForVendor?.uuidString ?? ""
    }()
}
#endif
