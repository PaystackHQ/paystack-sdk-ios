import Foundation
import os

// Note: We are currently forced to use os_log since we are supporting iOS 13. When we eventually drop support, we should change this to use the new iOS 14 Logger API.
public final class Logger {

    private static var logger = OSLog(subsystem: "com.paystack.ios_sdk", category: "main")
    static var loggingEnabled = false

    /// Logs a message with the `default` type
    /// - Parameters:
    ///   - message: A constant string or format string that produces a human-readable log message
    ///   - arguments: If message is a constant string, do not specify arguments.
    ///     If message is a format string, pass the expected number of arguments in the order that they appear in the string.
    public class func `default`(_ message: StaticString, arguments: CVarArg...) {
        guard loggingEnabled else { return }
        os_log(message, log: logger, type: .default, arguments)
    }

    /// Logs a message with the `info` type
    /// - Parameters:
    ///   - message: A constant string or format string that produces a human-readable log message
    ///   - arguments: If message is a constant string, do not specify arguments.
    ///     If message is a format string, pass the expected number of arguments in the order that they appear in the string.
    public class func info(_ message: StaticString, arguments: CVarArg...) {
        guard loggingEnabled else { return }
        os_log(message, log: logger, type: .info, arguments)
    }

    /// Logs a message with the `debug` type
    /// - Parameters:
    ///   - message: A constant string or format string that produces a human-readable log message
    ///   - arguments: If message is a constant string, do not specify arguments.
    ///     If message is a format string, pass the expected number of arguments in the order that they appear in the string.
    public class func debug(_ message: StaticString, arguments: CVarArg...) {
        guard loggingEnabled else { return }
        os_log(message, log: logger, type: .debug, arguments)
    }

    /// Logs a message with the `error` type
    /// - Parameters:
    ///   - message: A constant string or format string that produces a human-readable log message
    ///   - arguments: If message is a constant string, do not specify arguments.
    ///     If message is a format string, pass the expected number of arguments in the order that they appear in the string.
    public class func error(_ message: StaticString, arguments: CVarArg...) {
        guard loggingEnabled else { return }
        os_log(message, log: logger, type: .error, arguments)
    }

    /// Logs a message with the `fault` type
    /// - Parameters:
    ///   - message: A constant string or format string that produces a human-readable log message
    ///   - arguments: If message is a constant string, do not specify arguments.
    ///     If message is a format string, pass the expected number of arguments in the order that they appear in the string.
    public class func fault(_ message: StaticString, arguments: CVarArg...) {
        guard loggingEnabled else { return }
        os_log(message, log: logger, type: .fault, arguments)
    }

}
