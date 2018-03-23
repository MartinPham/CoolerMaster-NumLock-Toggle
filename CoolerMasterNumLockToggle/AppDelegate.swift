//
//  AppDelegate.swift
//  CoolerMasterNumLockToggle
//
//  Created by Jeff Peck - Home on 1/2/18.
//  Copyright © 2018 Jeff Peck. All rights reserved.
//

// Notes:
// http://eon.codes/blog/2017/11/09/mac-status-bar-app/

import Cocoa

let kNameMatch = "MasterKeys*"
let kNumLockKeyCode = 71
let kScrollLockKeyCode = 107
let kCapsLockKeyCode = 57

let kNumLockKey = "num"
let kScrollLockKey = "scroll"
let kCapsLockKey = "caps"

var mode = "on"

private func toggleKey(key: String) {
    if(mode == "toggle")
    {
        toggle(key, kNameMatch)
    }
}
private func turnOnKey(key: String) {
    turnOn(key, kNameMatch)
}
private func turnOffKey(key: String) {
    turnOff(key, kNameMatch)
}


private func myCGEventCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    if [.keyDown].contains(type) {
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        
        if keyCode == kNumLockKeyCode {
            toggleKey(key: kNumLockKey)
        }else if keyCode == kScrollLockKeyCode {
            toggleKey(key: kScrollLockKey)
        }
    }
    return Unmanaged.passRetained(event)
}

private func captureKeyPresses() {
    let eventMask = (1 << CGEventType.keyDown.rawValue)
    guard let eventTap = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                           place: .headInsertEventTap,
                                           options: .defaultTap,
                                           eventsOfInterest: CGEventMask(eventMask),
                                           callback: myCGEventCallback,
                                           userInfo: nil)
        else {
            print("failed to create event tap")
            exit(1)
    }
    
    let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
    CGEvent.tapEnable(tap: eventTap, enable: true)
    CFRunLoopRun()
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    var statusBar = NSStatusBar.system
    var statusBarItem : NSStatusItem = NSStatusItem()
    var menu: NSMenu = NSMenu()
    var toggleMenuItem = NSMenuItem(title: "Toggle mode", action: #selector(toggleMode), keyEquivalent: "");
    var onMenuItem = NSMenuItem(title: "Always On", action: #selector(onMode), keyEquivalent: "");
    var offMenuItem = NSMenuItem(title: "Always Off", action: #selector(offMode), keyEquivalent: "");


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        
        if !accessEnabled {
            print("Access Not Enabled")
        }
        
        captureKeyPresses()
        
//        turnOnKey(key: kNumLockKey)
//        turnOnKey(key: kScrollLockKey)
        
        
        statusBarItem = statusBar.statusItem(withLength: -1)
        statusBarItem.menu = menu
        statusBarItem.title = "⌨"
//        statusBarItem.image = #imageLiteral(resourceName: "numlock-dark-mode")
//        statusBarItem.highlightMode = truetoggleScrollLock
        
//        let toggleMenuItem = NSMenuItem(title: "Toggle", action: #selector(toggle), keyEquivalent: "")
        menu.addItem(toggleMenuItem)
        menu.addItem(onMenuItem)
        menu.addItem(offMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        
//        let aboutMenuItem = NSMenuItem(title: "About", action: #selector(about), keyEquivalent: "")
//        menu.addItem(aboutMenuItem)
        
        let quitMenuItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "")
        menu.addItem(quitMenuItem)
        
        onMode(sender: onMenuItem)
    }
    
    @objc func toggleMode(sender: AnyObject){
        mode = "toggle"
        
        toggleMenuItem.state = .on
        onMenuItem.state = .off
        offMenuItem.state = .off
    }
    @objc func onMode(sender: AnyObject){
        mode = "on"
        
        toggleMenuItem.state = .off
        onMenuItem.state = .on
        offMenuItem.state = .off
        
        turnOnKey(key: kNumLockKey)
        turnOnKey(key: kScrollLockKey)
    }
    @objc func offMode(sender: AnyObject){
        mode = "off"
        
        toggleMenuItem.state = .off
        onMenuItem.state = .off
        offMenuItem.state = .on
        
        
        turnOffKey(key: kNumLockKey)
        turnOffKey(key: kScrollLockKey)
    }
    
//    @objc func about(sender: AnyObject){
//        Swift.print("about")
//        // TODO
//    }
    
    @objc func quitApp(){
        exit(0)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
//    func referesDarkMode() {
//        // TODO
//    }


}

