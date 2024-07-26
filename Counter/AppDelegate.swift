import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow?
    var statusItem: NSStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var statusMenu: NSMenu?
    var counter: Int {
        get {
            return UserDefaults.standard.integer(forKey: counterKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: counterKey)
            updateCounterDisplay()
        }
    }

    let userDefaults = UserDefaults.standard
    let counterKey = "CounterValue"

    func applicationWillTerminate(_ aNotification: Notification) {
        // Save the counter value when the app is about to terminate
        userDefaults.set(counter, forKey: counterKey)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusMenu = NSMenu()
        
        if let savedCounter = userDefaults.value(forKey: counterKey) as? Int {
            counter = savedCounter
            updateCounterDisplay()
        }

        statusMenu?.addItem(withTitle: "+1", action: #selector(incrementCounter), keyEquivalent: "")
        statusMenu?.addItem(withTitle: "-1", action: #selector(decrementCounter), keyEquivalent: "")
        statusMenu?.addItem(withTitle: "0", action: #selector(resetCounter), keyEquivalent: "")
        statusMenu?.addItem(NSMenuItem.separator())
        statusMenu?.addItem(withTitle: "Custom...", action: #selector(showCustomIncrementWindow), keyEquivalent: "")
        statusMenu?.addItem(NSMenuItem.separator())

        let quitMenuItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitMenuItem.target = self
        statusMenu?.addItem(quitMenuItem)

        statusItem.menu = statusMenu
        updateCounterDisplay()
    }

    @objc func incrementCounter() {
        counter += 1
        updateCounterDisplay()
    }

    @objc func decrementCounter() {
        counter -= 1
        updateCounterDisplay()
    }

    @objc func resetCounter() {
        counter = 0
        updateCounterDisplay()
    }

    func updateCounterDisplay() {
        // Update the status bar title to display the counter value
        if let button = statusItem.button {
            button.title = "\(counter)"
        }
    }

    @objc func quitApp() {
        NSApp.terminate(nil)
    }

    @objc func showCustomIncrementWindow() {
        // Check if the window is already open
        if window != nil {
            return
        }

        let customWindow = NSWindow(contentRect: NSMakeRect(0, 0, 200, 100),
                                    styleMask: [.titled, .closable],
                                    backing: .buffered, defer: false)
        customWindow.center()
        customWindow.title = "Custom Increment"

        let textField = NSTextField(frame: NSMakeRect(20, 50, 160, 24))
        textField.placeholderString = "Enter a number"
        textField.alignment = .center
        customWindow.contentView?.addSubview(textField)

        let addButton = NSButton(frame: NSMakeRect(60, 10, 80, 32))
        addButton.title = "Add"
        addButton.action = #selector(addCustomIncrement)
        addButton.target = self
        customWindow.contentView?.addSubview(addButton)

        self.window = customWindow
        customWindow.makeKeyAndOrderFront(nil)
    }

    @objc func addCustomIncrement() {
        guard let customWindow = self.window,
              let textField = customWindow.contentView?.subviews.first(where: { $0 is NSTextField }) as? NSTextField,
              let inputValue = Int(textField.stringValue) else {
            return
        }

        counter += inputValue
        updateCounterDisplay()
        customWindow.orderOut(nil)
        self.window = nil // Set the window to nil after closing
    }
}
