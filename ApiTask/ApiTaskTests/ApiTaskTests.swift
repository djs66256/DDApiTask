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
}
