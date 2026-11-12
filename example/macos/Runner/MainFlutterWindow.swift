
import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {

    private var debugTimer: Timer?
    private var notificationObservers: [NSObjectProtocol] = []

    override func awakeFromNib() {
        let flutterViewController = FlutterViewController()
        let windowFrame = self.frame

        self.contentViewController = flutterViewController
        self.setFrame(windowFrame, display: true)

        RegisterGeneratedPlugins(registry: flutterViewController)

        // 用于复现 Bug
        // .inActiveApp：偶尔出现 hover 不响应
        // .always：目前测试可以绕过问题
        flutterViewController.mouseTrackingMode = .inActiveApp

        super.awakeFromNib()

        NSLog("MOUSE-DEBUG: awakeFromNib executed")

        // 监听 AppKit 激活及窗口焦点变化
        registerNotifications()

        // 打印初始状态
        logState("START")

        // 每 0.5 秒输出一次完整状态
        let timer = Timer(
            timeInterval: 0.5,
            repeats: true
        ) { [weak self] _ in
            self?.logState("STATE")
        }

        debugTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    // MARK: - 状态日志

    private func logState(_ tag: String) {
        let current = NSRunningApplication.current
        let frontmost = NSWorkspace.shared.frontmostApplication

        let currentPID = ProcessInfo.processInfo.processIdentifier
        let frontmostPID = frontmost?.processIdentifier ?? -1

        NSLog(
            "MOUSE-DEBUG \(tag) " +
            "nsAppActive=\(NSApp.isActive) " +
            "runningActive=\(current.isActive) " +
            "isKeyWindow=\(self.isKeyWindow) " +
            "canBecomeKey=\(self.canBecomeKey) " +
            "activationPolicy=\(NSApp.activationPolicy().rawValue) " +
            "currentPID=\(currentPID) " +
            "frontmostPID=\(frontmostPID) " +
            "samePID=\(currentPID == frontmostPID) " +
            "frontmostBundle=\(frontmost?.bundleIdentifier ?? "unknown")"
        )
    }

    // MARK: - 监听应用和窗口状态变化

    private func registerNotifications() {
        let center = NotificationCenter.default

        let appNotifications: [(Notification.Name, String)] = [
            (
                NSApplication.didBecomeActiveNotification,
                "APP DID_BECOME_ACTIVE"
            ),
            (
                NSApplication.didResignActiveNotification,
                "APP DID_RESIGN_ACTIVE"
            )
        ]

        for (name, tag) in appNotifications {
            let observer = center.addObserver(
                forName: name,
                object: NSApp,
                queue: .main
            ) { [weak self] _ in
                self?.logState(tag)
            }

            notificationObservers.append(observer)
        }

        let windowNotifications: [(Notification.Name, String)] = [
            (
                NSWindow.didBecomeKeyNotification,
                "WINDOW DID_BECOME_KEY"
            ),
            (
                NSWindow.didResignKeyNotification,
                "WINDOW DID_RESIGN_KEY"
            )
        ]

        for (name, tag) in windowNotifications {
            let observer = center.addObserver(
                forName: name,
                object: self,
                queue: .main
            ) { [weak self] _ in
                self?.logState(tag)
            }

            notificationObservers.append(observer)
        }
    }

    // MARK: - 原生鼠标事件

    override func sendEvent(_ event: NSEvent) {

        // Option + Shift + 鼠标左键松开：
        // 手动尝试激活 App 和窗口
        let shouldActivate =
            event.type == .leftMouseUp &&
            event.modifierFlags.contains(.option) &&
            event.modifierFlags.contains(.shift)

        switch event.type {
        case .leftMouseDown:
            logState("DOWN")

        case .leftMouseUp:
            logState("UP")

        default:
            break
        }

        if shouldActivate {
            logState("BEFORE")
        }

        // 正常交给 AppKit / Flutter 处理
        super.sendEvent(event)

        guard shouldActivate else { return }

        NSLog("MOUSE-DEBUG REQUESTING ACTIVATION")

        // 仅用于诊断：旧式激活方式
        // 在较新 macOS 中已弃用
        let requested = NSRunningApplication.current.activate(
            options: [.activateIgnoringOtherApps]
        )

        NSLog("MOUSE-DEBUG ACTIVATE RESULT: \(requested)")

        // 尝试让窗口成为 Key Window
        self.makeKeyAndOrderFront(nil)

        // 等待 0.5 秒后检查是否激活成功
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.5
        ) { [weak self] in
            self?.logState("AFTER")
        }
    }

    // MARK: - 清理调试资源

    deinit {
        debugTimer?.invalidate()

        for observer in notificationObservers {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}