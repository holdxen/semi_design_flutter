import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    // Flutter macOS defaults to FlutterMouseTrackingModeInKeyWindow, which
    // stops hover (and enter/exit) delivery whenever this window is not the
    // key window — hover styles appear dead until the window is refocused.
    // `.always` matches normal AppKit hover behavior and also keeps the
    // pointer add/remove state stable across focus changes.
    // See: https://github.com/flutter/flutter/issues/185426
    flutterViewController.mouseTrackingMode = .always

    super.awakeFromNib()
  }
}
