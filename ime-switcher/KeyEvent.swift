//
//  KeyEvent.swift
//  ime-switcher
//
//  Created by FushiharaKan on 2016/09/22.
//  Copyright © 2016年 Kan Fushihara. All rights reserved.
//

import Cocoa

class KeyEvent: NSObject {
    enum KeySetting: Int {
        case None
        case IMEOn
        case IMEOff
        case IMEToggle
    }
    
    struct ModifierKey {
        var key: String
        var flag: NSEventModifierFlags
    }
    
    static let ModifierKeys: [UInt16: ModifierKey] = [
        54: ModifierKey(key: "Right Command", flag: NSEventModifierFlags.command),
        55: ModifierKey(key: "Left Command", flag: NSEventModifierFlags.command),
        56: ModifierKey(key: "Left Shift", flag: NSEventModifierFlags.shift),
        58: ModifierKey(key: "Left Option", flag: NSEventModifierFlags.option),
        59: ModifierKey(key: "Left Control", flag: NSEventModifierFlags.control),
        60: ModifierKey(key: "Right Shift", flag: NSEventModifierFlags.shift),
        61: ModifierKey(key: "Right Option", flag: NSEventModifierFlags.option),
        62: ModifierKey(key: "Right Control", flag: NSEventModifierFlags.control),
    ]
    
    var keyCode: UInt16? = nil
    var imeMode: Bool = false
    var defaults = UserDefaults()
    
    override init() {
        super.init()
        
        let checkOptionPrompt = kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString
        let options = [checkOptionPrompt: true] as CFDictionary
        
        if !AXIsProcessTrustedWithOptions(options) {
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(KeyEvent.watchAXIsProcess(timer:)),userInfo: nil, repeats: true)
        } else {
            self.watch()
        }
    }
    
    func watchAXIsProcess(timer: Timer) {
        if AXIsProcessTrusted() {
            timer.invalidate()
            
            self.watch()
        }
    }
    
    func watch() {
        let masks = [
            NSEventMask.keyDown,
            NSEventMask.keyUp
        ]
        
        for mask in masks {
            NSEvent.addGlobalMonitorForEvents(matching: mask, handler: {(evt: NSEvent!) -> Void in
                self.keyCode = nil
            })
        }
        
        func emulateKeyPush(code: UInt16) {
            let loc = CGEventTapLocation.cghidEventTap
            
            CGEvent(keyboardEventSource: nil, virtualKey: code, keyDown: true)?.post(tap: loc)
            CGEvent(keyboardEventSource: nil, virtualKey: code, keyDown: false)?.post(tap: loc)
        }
        
        func imeOn() {
            print("kana")
            emulateKeyPush(code: 104)
            self.imeMode = true
        }
        
        func imeOff() {
            print("eisuu")
            emulateKeyPush(code: 102)
            self.imeMode = false
        }
        
        func checkFlagKey(event: NSEvent, keyCode: UInt16) {
            if let setting = KeyEvent.ModifierKeys[event.keyCode] {
                if event.modifierFlags.contains(setting.flag) {
                    self.keyCode = keyCode
                }
                else if self.keyCode == keyCode {
                    switch self.defaults.integer(forKey: setting.key) {
                    case KeySetting.None.rawValue:
                        break
                    case KeySetting.IMEOn.rawValue:
                        imeOn()
                    case KeySetting.IMEOff.rawValue:
                        imeOff()
                    case KeySetting.IMEToggle.rawValue:
                        self.imeMode ? imeOff() : imeOn()
                    default:
                        print("invalid setting type")
                    }
                }
            }
        }
        
        NSEvent.addGlobalMonitorForEvents(matching: NSEventMask.flagsChanged, handler: {(event: NSEvent!) -> Void in
            for modifierKey in KeyEvent.ModifierKeys.keys {
                if event.keyCode == modifierKey {
                    checkFlagKey(event: event, keyCode: modifierKey)
                    return
                }
            }
        })
    }
}
