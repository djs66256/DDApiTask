//
//  DDRequestTests.swift
//  DDRequestTests
//
//  Created by daniel on 16/8/28.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import XCTest
import SwiftyJSON
import DDFileCache
@testable import ApiTask

let config = ApiTaskConfig(serializer: ApiJsonModelSerializer<User>(), cache: DDCache(name: "test"))

class DDRequestTests: XCTestCase {
    
    var json: JSON?
    
    override func setUp() {
        super.setUp()
        
        let path = NSBundle.mainBundle().pathForResource("UserTask", ofType: "json")
        let data = NSData(contentsOfFile: path!)
        let dict = try? NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
        self.json = JSON(dict!)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRequest() {
        let exception = self.expectationWithDescription("test request")
        UserTask(config: config).buildMock(true).responseModel { (result) in
            switch result {
            case .Success(let user):
                XCTAssert(user.id == self.json?["data"]["id"].string, "")
                XCTAssert(user.gender == Gender(rawValue: self.json?["data"]["gender"].int ?? -1), "")
                XCTAssert(user.name == self.json?["data"]["name"].string, "")
            case .Failure(let error):
                XCTAssert(false, error.localizedDescription)
            default:
                break
            }
            exception.fulfill()
        }
        self.waitForExpectationsWithTimeout(10) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testRequestCache() {
        let exception = self.expectationWithDescription("test cache")
        UserTask(config: config).clearCache().buildCache(true).buildMock(true).responseModel( {(result) in
            UserTask(config: config).buildCache(true).cacheModel({ (user) in
                XCTAssert(user.id == self.json?["data"]["id"].string, "")
                XCTAssert(user.gender == Gender(rawValue: self.json?["data"]["gender"].int ?? -1), "")
                XCTAssert(user.name == self.json?["data"]["name"].string, "")
                
                UserTask(config: config).clearCache().buildCache(true).cacheModel({ (user) in
                    XCTFail("shoud clear cache")
                })
                exception.fulfill()
            })
            }
        )
        self.waitForExpectationsWithTimeout(10) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testBatchRequest() {
        let exception = self.expectationWithDescription("batch request error")
        ApiBatchTask(tasks: [UserTask(config: config).buildMock(true), UserTask(config: config).buildMock(true)]).responseTasks { (result) in
            switch result {
            case .Success(let tasks):
                if tasks.count == 2 {
                    if let task1 = tasks[0] as? UserTask, let task2 = tasks[1] as? UserTask {
                        var b1 = false
                        var b2 = false
                        task1.responseModel({ (result) in
                            b1 = true
                            
                            if b2 {
                                exception.fulfill()
                            }
                        })
                        task2.responseModel({ (result) in
                            b2 = true
                            
                            if b1 {
                                exception.fulfill()
                            }
                        })
                        return
                    }
                }
                XCTAssert(false, "tasks complete error")
            case .Failure :
                XCTAssert(false, "tasks complete error")
            }
        }
        self.waitForExpectationsWithTimeout(10) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testChainRequest() {
        let exception = self.expectationWithDescription("batch request error")
        ApiChainTask(tasks: [UserTask(config: config).buildMock(true), UserTask(config: config).buildMock(true)]).responseTasks { (result) in
            switch result {
            case .Success(let tasks):
                if tasks.count == 2 {
                    if let task1 = tasks[0] as? UserTask, let task2 = tasks[1] as? UserTask {
                        var b1 = false
                        var b2 = false
                        task1.responseModel({ (result) in
                            b1 = true
                            
                            if b2 {
                                exception.fulfill()
                            }
                        })
                        task2.responseModel({ (result) in
                            b2 = true
                            
                            if b1 {
                                exception.fulfill()
                            }
                        })
                        return
                    }
                }
                XCTAssert(false, "tasks complete error")
            case .Failure :
                XCTAssert(false, "tasks complete error")
            }
        }
        self.waitForExpectationsWithTimeout(10) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
}
