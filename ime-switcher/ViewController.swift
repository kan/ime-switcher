//
//  ViewController.swift
//  ime-switcher
//
//  Created by FushiharaKan on 2016/09/22.
//  Copyright © 2016年 Kan Fushihara. All rights reserved.
//

import Cocoa
import ServiceManagement

class ViewController: NSViewController {
    var defaults = UserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideIconCheck?.state = self.defaults.integer(forKey: "Hide StatusBar Icon")
        self.startAtLoginCheck?.state = self.defaults.integer(forKey: "Start at Login")
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBOutlet weak var hideIconCheck: NSButton?
    @IBOutlet weak var startAtLoginCheck: NSButton?
    
    @IBAction func checkHideIconCheckState(sender: NSButton) {
        let app = NSApplication.shared().delegate as! AppDelegate
        if sender.state == NSOnState {
            self.defaults.set(1, forKey: "Hide StatusBar Icon")
            if #available(OSX 10.12, *) {
                app.statusItem.isVisible = false
            } else {
                app.statusItem.button?.isHidden = true

            }
            print("hide tray icon")
        } else {
            self.defaults.set(0, forKey: "Hide StatusBar Icon")
            if #available(OSX 10.12, *) {
                app.statusItem.isVisible = true
            } else {
                app.statusItem.button?.isHidden = false
            }
            print("show tray icon")
        }
    }
    
    @IBAction func checkStartAtLoginCeckState(sender: NSButton) {
        let launch = self.defaults.bool(forKey: "Start at Login")
        let appBundleIdentifier = "net.fushihara.IMESwitcher-Helper"
        
        if SMLoginItemSetEnabled(appBundleIdentifier as CFString, !launch) {
            if (launch) {
                print("success remove login item")
            } else {
                print("success add login item")
            }
            defaults.set(!launch, forKey: "Start at Login")
            self.startAtLoginCheck?.state = launch ? NSOffState : NSOnState
        } else {
            print("failed to add login item")
        }
       
    }
}
