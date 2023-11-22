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

        let quitMenuItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitMenuItem.target = self
        statusMenu?.addItem(quitMenuItem)

        statusItem.menu = statusMenu
        if let button = statusItem.button {
            updateCounterDisplay()
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
}

