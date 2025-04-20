import Cocoa
import HotKey

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var hotKey: HotKey?

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
        let customItem = NSMenuItem(title: "Custom...", action: #selector(showCustomIncrementWindow), keyEquivalent: "")
        customItem.target = self
        statusMenu?.addItem(customItem)
        statusMenu?.addItem(NSMenuItem.separator())

        let quitMenuItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitMenuItem.target = self
        statusMenu?.addItem(quitMenuItem)

        statusItem.menu = statusMenu
        updateCounterDisplay()

        hotKey = HotKey(key: .equal, modifiers: [.command, .option])
        hotKey?.keyDownHandler = { [weak self] in
            self?.incrementCounter()
        }
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
        if window != nil {
            window?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        DispatchQueue.main.async {
            NSApp.activate(ignoringOtherApps: true)

            let customWindow = NSWindow(contentRect: NSMakeRect(0, 0, 200, 100),
                                        styleMask: [.titled, .closable],
                                        backing: .buffered, defer: false)
            customWindow.center()
            customWindow.title = "Custom Increment"

            // Make sure the window floats above others
            customWindow.level = .floating
            customWindow.collectionBehavior = [.moveToActiveSpace, .transient]

            let textField = NSTextField(frame: NSMakeRect(20, 50, 160, 24))
            textField.placeholderString = "Enter a number"
            textField.alignment = .center
            customWindow.contentView?.addSubview(textField)

            let addButton = NSButton(frame: NSMakeRect(60, 10, 80, 32))
            addButton.title = "Add"
            addButton.action = #selector(self.addCustomIncrement)
            addButton.target = self
            customWindow.contentView?.addSubview(addButton)

            customWindow.defaultButtonCell = addButton.cell as? NSButtonCell

            self.window = customWindow

            // Focus and bring to front
            customWindow.makeKeyAndOrderFront(nil)
            customWindow.makeMain() // This helps if there's no main window
        }
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
