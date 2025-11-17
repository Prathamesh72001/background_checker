import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {

  override func applicationDidFinishLaunching(_ notification: Notification) {
    super.applicationDidFinishLaunching(notification)

    // Make sure the window exists
    guard let flutterWindow = mainFlutterWindow else { return }
    guard let controller = flutterWindow.contentViewController as? FlutterViewController else { return }

    // Create MethodChannel
    let channel = FlutterMethodChannel(name: "active_window_macos",
                                       binaryMessenger: controller.engine.binaryMessenger)

    // Handle method calls from Dart
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { return }
      switch call.method {
      case "getActiveWindow":
        let info = self.getActiveWindow()
        result(info)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  // Returns "AppName|||WindowTitle" as String
  private func getActiveWindow() -> String {
    guard let frontApp = NSWorkspace.shared.frontmostApplication else {
      return "Unknown|||Unknown"
    }

    let appName = frontApp.localizedName ?? "Unknown"

    // Ask for Accessibility permissions if needed
    let options: NSDictionary = [
        kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true
    ]
    if !AXIsProcessTrustedWithOptions(options) {
      return "\(appName)|||Accessibility Permission Required"
    }

    // Get the focused window
    let appRef = AXUIElementCreateApplication(frontApp.processIdentifier)
    var focusedWindow: AnyObject?
    let windowStatus = AXUIElementCopyAttributeValue(appRef,
                                                     kAXFocusedWindowAttribute as CFString,
                                                     &focusedWindow)

    guard windowStatus == .success else {
      return "\(appName)|||Unknown"
    }

    var titleObj: AnyObject?
    let titleStatus = AXUIElementCopyAttributeValue(focusedWindow as! AXUIElement,
                                                    kAXTitleAttribute as CFString,
                                                    &titleObj)
    let windowTitle: String
    if titleStatus == .success, let t = titleObj as? String, !t.isEmpty {
      windowTitle = t
    } else {
      windowTitle = "Unknown"
    }

    return "\(appName)|||\(windowTitle)"
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
