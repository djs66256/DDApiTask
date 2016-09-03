//
//  DDApiTask.swift
//  DDRequest
//
//  Created by daniel on 16/8/28.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit
import Alamofire

public class ApiTask: NSObject {
    public var method: Alamofire.Method = .GET
    public var parameters: [String: AnyObject]?
    public var parameterEncoding: Alamofire.ParameterEncoding = .URL
    public var headers: [String: String]?
    public var baseURL: NSURL?
    public var path: String = ""
    
    // MARK: - MOCK
    public var mock: Bool = false
    public var mockBaseURL = NSBundle.mainBundle().bundleURL
    public var mockPath: String?
    
    var request: Request?
    
    public override init() {
        super.init()
    }
    
    func buildURL() -> NSURL? {
        if mock && mockPath != nil {
            return NSURL(fileURLWithPath: mockPath!, relativeToURL: mockBaseURL)
        }
        else {
            if let baseURL = self.baseURL {
                let url = NSURL(string: self.path, relativeToURL: baseURL)
                return url
            }
            else {
                return NSURL()
            }
        }
    }
    
    func buildRequest() -> Request? {
        if let url = self.buildURL() {
            request = Alamofire.request(self.method, url, parameters: self.parameters, encoding: self.parameterEncoding, headers: self.headers)
            return request
        }
        return nil
    }
    
    
}

public extension ApiTask {
    
    public func mockData() -> Self {
        let path = "\(self.dynamicType).json"
        return mockData(path)
    }
    
    public func mockData(mockPath: String) -> Self {
        self.mock = true
        self.mockPath = mockPath
        return self
    }
}
