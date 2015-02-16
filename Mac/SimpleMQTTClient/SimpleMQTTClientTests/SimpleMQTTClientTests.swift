//
//  SimpleMQTTClientTests.swift
//  SimpleMQTTClientTests
//
//  Created by Gianluca Venturini on 11/01/15.
//  Copyright (c) 2015 Gianluca Venturini. All rights reserved.
//

import Cocoa
import XCTest
import SimpleMQTTClient

class SimpleMQTTClientTests: XCTestCase, SimpleMQTTClientDelegate {
    
    
    var mqtt: SimpleMQTTClient = SimpleMQTTClient(synchronous: false)
    var expectation: XCTestExpectation?
    
    override func setUp() {
        super.setUp()
        mqtt.connect("127.0.0.1")
    }
    
    override func tearDown() {
        mqtt.disconnect()
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPublishSync() {
        mqtt.delegate = self
        mqtt.synchronous = true
        mqtt.subscribe("test/channel")
        mqtt.publish("test/channel", message: "Test message")
        
        expectation = expectationWithDescription("Message back")
        
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testPublishAsync() {
        mqtt.delegate = self
        mqtt.synchronous = false
        mqtt.subscribe("test/channel")
        mqtt.publish("test/channel", message: "Test message")
        
        expectation = expectationWithDescription("Message back")
        
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testSubscribeSync() {
        mqtt.synchronous = true
        mqtt.subscribe("channel1")
        mqtt.subscribe("channel2")
        mqtt.subscribe("channel3")
        mqtt.subscribe("channel4")
        mqtt.subscribe("channel5")
        
        let channels = mqtt.getSubscribedChannels()
        
        // Equality test
        XCTAssert(contains(channels, "channel1"), "Pass")
        XCTAssert(contains(channels, "channel2"), "Pass")
        XCTAssert(contains(channels, "channel3"), "Pass")
        XCTAssert(contains(channels, "channel4"), "Pass")
        XCTAssert(contains(channels, "channel5"), "Pass")
    }
    
    func testSubscribeAsyncWildcard() {
        mqtt.delegate = self
        mqtt.synchronous = false
        mqtt.subscribe("test/#")
        mqtt.publish("test/channel", message: "Test message")
        
        expectation = expectationWithDescription("Message back")
        
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testSubscribeSyncWildcard() {
        mqtt.delegate = self
        mqtt.synchronous = true
        mqtt.subscribe("test/#")
        mqtt.publish("test/channel", message: "Test message")
        
        expectation = expectationWithDescription("Message back")
        
        waitForExpectationsWithTimeout(5, handler: nil)
        XCTAssert(mqtt.isSubscribed("test/test1"), "Pass")
        XCTAssert(mqtt.isSubscribed("test/test2"), "Pass")
        XCTAssert(mqtt.isSubscribed("test/test3"), "Pass")
        XCTAssert(mqtt.isSubscribed("test/test4"), "Pass")
        XCTAssert(mqtt.isSubscribed("test/u39567234786iutyerghdhg"), "Pass")
        XCTAssert(mqtt.isSubscribed("test/sjghsdfgkjkshfkjfdshgsjgskgjhfdsjkhsdjkhdgfksjg"), "Pass")
        XCTAssert(mqtt.isSubscribed("test/"), "Pass")
        XCTAssert(!mqtt.isSubscribed("otherchannel/"), "Pass")
        XCTAssert(!mqtt.isSubscribed("otherchannel/test/test1"), "Pass")
    }
    
    func testUnsubscribeSync() {
        mqtt.synchronous = true
        mqtt.subscribe("channel1")
        mqtt.subscribe("channel2")
        mqtt.subscribe("channel3")
        mqtt.subscribe("channel4")
        mqtt.subscribe("channel5")
        
        mqtt.unsubscribe("channel1")
        
        let channels = mqtt.getSubscribedChannels()
        
        // Equality test
        XCTAssert(!contains(channels, "channel1"), "Pass")
        XCTAssert(contains(channels, "channel2"), "Pass")
        XCTAssert(contains(channels, "channel3"), "Pass")
        XCTAssert(contains(channels, "channel4"), "Pass")
        XCTAssert(contains(channels, "channel5"), "Pass")
    }
    
    
    
    func messageReceived(channel: String, message: String) {
        if(channel == "test/channel" && message == "Test message") {
            println("Lol")
            XCTAssert(true, "Pass")
            expectation?.fulfill()
        }
    }
    
    func testWildcard() {
        mqtt.synchronous = true
        mqtt.subscribe("#")
        var wildcard = mqtt.wildcardSubscribed("test/test")
        if let w = wildcard {
            XCTAssert(w == "#", "pass")
        }
        else {
            XCTAssert(false, "pass")
        }
    }
    
    func testReconnect() {
        mqtt.delegate = self
        mqtt.synchronous = true
        
        mqtt.subscribe("channel1")
        mqtt.subscribe("channel2")
        mqtt.subscribe("channel3")
        mqtt.subscribe("channel4")
        mqtt.subscribe("channel5")

        mqtt.subscribe("test/channel")
        
        
        mqtt.unsubscribe("channel1")
        
        let channels = mqtt.getSubscribedChannels()
        
        println("Disconnect the server...")
        println("10...")
        sleep(2)
        println("8...")
        sleep(2)
        println("6...")
        sleep(2)
        println("4...")
        sleep(2)
        println("2...")
        sleep(2)
        println("0...")

        sleep(2)   // Disconnect the server and reconnect it
        println("Lets continue the test")

        let nextTimer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "sendMessage:", userInfo: nil, repeats: false)
        
        // Equality test
        XCTAssert(!contains(channels, "channel1"), "Pass")
        XCTAssert(contains(channels, "channel2"), "Pass")
        XCTAssert(contains(channels, "channel3"), "Pass")
        XCTAssert(contains(channels, "channel4"), "Pass")
        XCTAssert(contains(channels, "channel5"), "Pass")

        
        expectation = expectationWithDescription("Message back")
        
        waitForExpectationsWithTimeout(500, handler: nil)
    }
    
    func sendMessage(timer: NSTimer) {
        mqtt.publish("test/channel", message: "Test message")
        println("Sended message")
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
