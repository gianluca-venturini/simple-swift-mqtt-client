//
//  SimpleMQTTClient.swift
//  Test
//
//  Created by Gianluca Venturini on 10/01/15.
//  Copyright (c) 2015 Gianluca Venturini. All rights reserved.
//

import Foundation

public class SimpleMQTTClient: NSObject, MQTTSessionDelegate {
    
    // Options
    public var synchronous = false
    
    var session: MQTTSession
    
    // Subscribed channels
    var subscribedChannels: [String: Bool]
    var subscribedChannelMessageIds: [Int: String]
    var unsubscribedChannelMessageIds: [Int: String]
    
    // Session variables
    var sessionConnected = false
    var sessionError = false
    
    // Delegate
    public weak var delegate: SimpleMQTTClientDelegate?
    
    // Delegate initializer
    public init(synchronous: Bool, clientId optionalClientId: String? = nil) {
        
        self.synchronous = synchronous
        
        if let clientId = optionalClientId {
            session = MQTTSession(
                clientId: clientId,
                userName: nil,
                password: nil,
                keepAlive: 60,
                cleanSession: true,
                will: false,
                willTopic: nil,
                willMsg: nil,
                willQoS: MQTTQosLevel.QoSLevelAtMostOnce,
                willRetainFlag: false,
                protocolLevel: 4,
                runLoop: nil,
                forMode: nil
            )
        }
        else {
            // Random generate clientId
            let chars = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
            let length = 22;    // Imposed by MQTT protocol
            var clientId = String();
            for (var i = length; i > 0; --i) {
                clientId += chars[Int(arc4random_uniform(UInt32(length)))];
            }
            
            session = MQTTSession(
                clientId: clientId,
                userName: nil,
                password: nil,
                keepAlive: 60,
                cleanSession: true,
                will: false,
                willTopic: nil,
                willMsg: nil,
                willQoS: MQTTQosLevel.QoSLevelAtMostOnce,
                willRetainFlag: false,
                protocolLevel: 4,
                runLoop: nil,
                forMode: nil
            )
        }
        
        self.subscribedChannels = [:]
        self.subscribedChannelMessageIds = [:]
        self.unsubscribedChannelMessageIds = [:]
        
        super.init()
        session.delegate = self;
    }
    
    // Convenience initializers
    
    public convenience init(host: String, synchronous: Bool, clientId optionalClientId: String? = nil) {
        self.init(synchronous: synchronous, clientId: optionalClientId)
        connect(host)
    }
    
    public func subscribe(channel: String) {
        while !sessionConnected && !sessionError {
            NSRunLoop.currentRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 1))
        }
        
        var messageId = 0
        
        if(synchronous) {
            if session.subscribeAndWaitToTopic(channel, atLevel: MQTTQosLevel.QoSLevelAtMostOnce) {
                subscribedChannels[channel] = true
            }
        }
        else {
            var messageId = Int(session.subscribeToTopic(channel, atLevel: MQTTQosLevel.QoSLevelAtMostOnce))
            subscribedChannelMessageIds[messageId] = channel
        }
        
    }
    
    public func unsubscribe(channel: String) {
        if(synchronous) {
            if let entry = subscribedChannels[channel] {
                if entry.boolValue {
                    if(session.unsubscribeAndWaitTopic(channel)) {
                        subscribedChannels[channel] = false
                    }
                }
            }
        }
        else {
            let messageId = Int(session.unsubscribeTopic(channel))
            unsubscribedChannelMessageIds[messageId] = channel
        }
    }
    
    public func getSubscribedChannels() -> [String] {
        var channels:[String] = []
        for (channel, subscribed) in subscribedChannels {
            if subscribed {
                channels.append(channel)
            }
        }
        return channels
    }
    
    public func publish(channel: String, message: String) {
        while !sessionConnected && !sessionError {
            NSRunLoop.currentRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 1))
        }
        
        if(synchronous) {
            session.publishAndWaitData(message.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false),
                onTopic: channel,
                retain: false,
                qos: MQTTQosLevel.QoSLevelAtMostOnce)
        }
        else{
            session.publishData(message.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false),
                onTopic: channel,
                retain: false,
                qos: MQTTQosLevel.QoSLevelAtMostOnce)
        }
    }
        
    
    public func disconnect() {
        session.close()
        sessionConnected = false
    }
    
    public func connect(host: String) {
        if( sessionConnected == false) {
            subscribedChannels = [:]
            if(synchronous) {
                session.connectAndWaitToHost(host,
                    port: 1883,
                    usingSSL: false)
            }
            else {
                session.connectToHost(host,
                    port: 1883,
                    usingSSL: false)
            }
            
        }
        
    }
    
    // MQTTSessionDelegate protocol
    
    public func newMessage(session: MQTTSession!, data: NSData!, onTopic topic: String!, qos: MQTTQosLevel, retained: Bool, mid: UInt32) {
        println("New message received \(NSString(data: data, encoding: NSUTF8StringEncoding))")
        self.delegate?.messageReceived?(
            topic,
            message: NSString(data: data, encoding: NSUTF8StringEncoding)!
        )
    }
    
    public func handleEvent(session: MQTTSession!, event eventCode: MQTTSessionEvent, error: NSError!) {
        switch eventCode {
            case .Connected:
                sessionConnected = true
                self.delegate?.connected?()
            case .ConnectionClosed:
                sessionConnected = false
                self.delegate?.disconnected?()
            default:
                sessionError = true
        }
    }
    
    public func subAckReceived(session: MQTTSession, msgID: UInt16, grantedQoss: [AnyObject]) {
        if let channel = subscribedChannelMessageIds[Int(msgID)] {
            subscribedChannels[channel] = true
        }
    }
    
    public func unsubAckReceived(session: MQTTSession, msgID: UInt16, grantedQoss: [AnyObject]) {
        if let channel = unsubscribedChannelMessageIds[Int(msgID)] {
            subscribedChannels[channel] = false
        }
    }
}