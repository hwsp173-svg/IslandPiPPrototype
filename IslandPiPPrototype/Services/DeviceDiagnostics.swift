import UIKit
import Darwin

struct DeviceDiagnostics {
    static var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
        return "\(version) (\(build))"
    }
    static var deviceModel: String {
        var info = utsname()
        uname(&info)
        let identifier = withUnsafePointer(to: &info.machine) { pointer in
            pointer.withMemoryRebound(to: CChar.self, capacity: 1) { String(cString: $0) }
        }
        return "\(UIDevice.current.model) (\(identifier))"
    }
    static var systemVersion: String { "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)" }
}
