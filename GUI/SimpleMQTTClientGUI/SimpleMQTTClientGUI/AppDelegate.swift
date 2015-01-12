//
//  AppDelegate.swift
//  SimpleMQTTClientGUI
//
//  Created by Gianluca Venturini on 11/01/15.
//  Copyright (c) 2015 Gianluca Venturini. All rights reserved.
//

import Cocoa
import SimpleMQTTClient

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var mqtt = SimpleMQTTClient(host: "127.0.0.1", synchronous: true)


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        mqtt.publish("test", message: "MQTT message from MAC application")
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

