import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()

    let frame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(frame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    // Register your plugin
    ActiveWindowMacOSPlugin.register(
        with: flutterViewController.registrar(forPlugin: "ActiveWindowMacOSPlugin")
    )

    self.makeKeyAndOrderFront(nil)
    self.orderFrontRegardless()

    super.awakeFromNib()
  }
}
