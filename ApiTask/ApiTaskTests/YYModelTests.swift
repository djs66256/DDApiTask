//
//  YYModelTests.swift
//  DDRequest
//
//  Created by daniel on 16/9/4.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import XCTest
import YYModel
import SwiftyJSON
@testable import ApiTask

class YYModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testYYModel() {
        if let path = Bundle.main.path(forResource: "UserTask", ofType: "json") {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                do {
                    let dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    if let user = User.yy_modelWithJSON(dict["data"]) {
                        let json = JSON(dict)
                        XCTAssert(user.id == json["data"]["id"].string, "")
                        XCTAssert(user.gender == Gender(rawValue: json["data"]["gender"].int ?? -1), "")
                        XCTAssert(user.name == json["data"]["name"].string, "")
                    }
                    else {
                        XCTAssert(false, "JSON parser failed")
                    }
                }
                catch {
                    XCTAssert(false, "Not JSON file")
                }
            }
            else {
                XCTAssert(false, "Data error")
            }
        }
        else {
            XCTAssert(false, "File not exists")
        }
    }
    
    
}
