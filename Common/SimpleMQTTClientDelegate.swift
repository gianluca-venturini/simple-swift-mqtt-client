//
//  SimpleMQTTClientDelegate.swift
//  Test
//
//  Created by Gianluca Venturini on 11/01/15.
//  Copyright (c) 2015 Gianluca Venturini. All rights reserved.
//

import Foundation

@objc public protocol SimpleMQTTClientDelegate {
    optional func messageReceived(channel: String, message: String)
    optional func disconnected()
    optional func connected()
}