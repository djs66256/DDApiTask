//
//  DDRequestTests.swift
//  DDRequestTests
//
//  Created by daniel on 16/8/28.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import XCTest
import SwiftyJSON
//import DDFileCache
@testable import ApiTask

let config = ApiTaskConfig(serializer: ApiJsonModelSerializer<User>(), cache: DDCache(name: "test"))

class DDRequestTests: XCTestCase {
    
    var json: JSON?
    
    override func setUp() {
        super.setUp()
        
        let path = Bundle.main.path(forResource: "UserTask", ofType: "json")
        let data = try? Data(contentsOf: URL(fileURLWithPath: path!))
        let dict = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments)
        self.json = JSON(dict!)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRequest() {
        let exception = self.expectation(description: "test request")
        UserTask(config: config).mock(true).responseModel { (result) in
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
        self.waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testRequestCache() {
        let exception = self.expectation(description: "test cache")
        UserTask(config: config).clearCache().cache(true).mock(true).responseModel( {(result) in
            UserTask(config: config).cache(true).cacheModel({ (user) in
                XCTAssert(user.id == self.json?["data"]["id"].string, "")
                XCTAssert(user.gender == Gender(rawValue: self.json?["data"]["gender"].int ?? -1), "")
                XCTAssert(user.name == self.json?["data"]["name"].string, "")
                
                UserTask(config: config).clearCache().cache(true).cacheModel({ (user) in
                    XCTFail("shoud clear cache")
                })
                exception.fulfill()
            })
            }
        )
        self.waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testBatchRequest() {
        let exception = self.expectation(description: "batch request error")
        ApiBatchTask(tasks: [UserTask(config: config).mock(true), UserTask(config: config).mock(true)]).responseTasks { (result) in
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
        self.waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testChainRequest() {
        let exception = self.expectation(description: "batch request error")
        ApiChainTask(tasks: [UserTask(config: config).mock(true), UserTask(config: config).mock(true)]).responseTasks { (result) in
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
        self.waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
}
