import Cocoa
import FlutterMacOS

public class ActiveWindowMacOSPlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "active_window_macos",
            binaryMessenger: registrar.messenger
        )
        let instance = ActiveWindowMacOSPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getActiveWindow":
            result(self.getActiveWindowTitle())
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func getActiveWindowTitle() -> String {
        guard let frontApp = NSWorkspace.shared.frontmostApplication else {
            return "Unknown|||Unknown"
        }

        let appName = frontApp.localizedName ?? "Unknown"

        // Permissions popup
        let options: NSDictionary = [
            kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true
        ]

        if !AXIsProcessTrustedWithOptions(options) {
            return "\(appName)|||Accessibility Permission Required"
        }

        let appRef = AXUIElementCreateApplication(frontApp.processIdentifier)

        // Focused window
        var focusedWindow: AnyObject?
        let windowStatus = AXUIElementCopyAttributeValue(
            appRef,
            kAXFocusedWindowAttribute as CFString,
            &focusedWindow
        )

        guard windowStatus == .success,
              let windowRef = focusedWindow // ← no cast needed
        else {
            return "\(appName)|||Unknown"
        }

        // Title
        var titleObj: AnyObject?
        let titleStatus = AXUIElementCopyAttributeValue(
            windowRef as! AXUIElement, // safe cast (guaranteed by SDK)
            kAXTitleAttribute as CFString,
            &titleObj
        )

        let title: String
        if titleStatus == .success, let t = titleObj as? String, !t.isEmpty {
            title = t
        } else {
            title = "Unknown"
        }

        return "\(appName)|||\(title)"
    }
}
