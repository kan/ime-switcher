//
//  AppDelegate.swift
//  ime-switcher
//
//  Created by FushiharaKan on 2016/09/22.
//  Copyright © 2016年 Kan Fushihara. All rights reserved.
//

import Cocoa
import ServiceManagement

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem = NSStatusBar.system().statusItem(withLength: -1)
    var defaults = UserDefaults()

    override func awakeFromNib() {
        _ = KeyEvent()
        
        let menu = NSMenu()
        //self.statusItem.title = "■"
        //self.statusItem.highlightMode = true
        self.statusItem.image = NSImage(named: "StatusBarImage")
        self.statusItem.menu = menu
        
        let prefMenuItem = NSMenuItem()
        prefMenuItem.title = "設定"
        prefMenuItem.action = #selector(AppDelegate.showPreference(sender:))
        menu.addItem(prefMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitMenuItem = NSMenuItem()
        quitMenuItem.title = "IMESwitcherを終了"
        quitMenuItem.action = #selector(AppDelegate.quit(sender:))
        menu.addItem(quitMenuItem)
        
        
        if #available(OSX 10.12, *) {
            self.statusItem.isVisible = !self.defaults.bool(forKey: "Hide StatusBar Icon")
        } else {
            self.statusItem.button?.isHidden = true
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if !self.defaults.bool(forKey: "Hide StatusBar Icon") {
            NSApplication.shared().windows.last!.orderOut(self)
        }
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        if self.defaults.bool(forKey: "Hide StatusBar Icon") {
            NSApplication.shared().activate(ignoringOtherApps: true)
            NSApplication.shared().windows.last!.makeKeyAndOrderFront(self)
        }
    }
    
    @IBAction func showPreference(sender: NSButton) {
        NSApplication.shared().activate(ignoringOtherApps: true)
        NSApplication.shared().windows.last!.makeKeyAndOrderFront(self)
    }
    
    @IBAction func quit(sender: NSButton) {
        if self.defaults.bool(forKey: "Confirm Quit") {
            let popup = NSAlert()
            popup.messageText = "Are you sure you want to quit IMESwitcher?"
            popup.informativeText = "The changed key will be restored after IMESwitcher is quit."
            popup.alertStyle = NSAlertStyle.warning
            popup.addButton(withTitle: "Quit")
            popup.addButton(withTitle: "Cancel")
            
            if popup.runModal() == NSAlertFirstButtonReturn {
                NSApplication.shared().terminate(self)
            }
        } else {
            NSApplication.shared().terminate(self)
        }
    }
}

