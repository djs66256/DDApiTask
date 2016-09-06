//
//  DDApiTask.swift
//  DDRequest
//
//  Created by daniel on 16/8/28.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit
import Alamofire

public enum Method: String {
    case OPTIONS, GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
}

public class ApiTask: NSObject {
    // You can also override the getter to dynamic build it!
    public var method: Method = .GET
    public var parameters = [String: AnyObject]()
    public var parameterEncoding: Alamofire.ParameterEncoding = .URL
    public var headers = [String: String]()
    public var baseURL: NSURL?
    public var path: String = ""
    
    // MARK: - MOCK
    public var mock: Bool = false
    public var baseMockURL = NSBundle.mainBundle().bundleURL
    public var mockPath: String?
    
    var request: Request? {
        get {
            if let url = self.URL {
                return Alamofire.request(Alamofire.Method(rawValue:self.method.rawValue)!, url, parameters: self.parameters, encoding: self.parameterEncoding, headers: self.headers)
            }
            else {
                return nil
            }
        }
    }
    
    public override init() {
        super.init()
    }
    
    private var URL: NSURL? {
        get {
            if mock && mockPath != nil {
                return NSURL(string: mockPath!, relativeToURL: baseMockURL)
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
    }
    
    public func buildMethod(method: Method) -> Self {
        self.method = method
        return self
    }
    
    public func buildParameters(parameters: [String: AnyObject]?) -> Self {
        if let parameters = parameters {
            for (key, value) in parameters {
                buildParameter(key, value)
            }
        }
        return self
    }
    
    public func buildParameter(key: String, _ value: AnyObject) -> Self {
        self.parameters[key] = value
        return self
    }
    
    public func buildHeaders(headers: [String: String]?) -> Self {
        if let headers = headers {
            for (key, value) in headers {
                buildHeader(key, value)
            }
        }
        return self
    }
    
    public func buildHeader(key: String, _ value: String) -> Self {
        self.headers[key] = value
        return self
    }
    
    public func buildURL(path: String, baseURL: NSURL) -> Self {
        self.path = path
        self.baseURL = baseURL
        return self
    }
    
    public func buildMock(mock: Bool, mockPath: String? = nil, baseMockURL: NSURL? = nil) -> Self {
        self.mock = mock
        self.mockPath = mockPath ?? "\(self.dynamicType).json"
        if let baseMockURL = baseMockURL {
            self.baseMockURL = baseMockURL
        }
        return self
    }
    
    public func validate() -> (Bool, NSError?) {
        let (validated, errStr) = validateString()
        if validated {
                return (validated, nil)
            }
        else if let str = errStr {
            return (false, NSError(domain: ApiTaskErrorDomain, code: ApiTaskDataErrorCode, userInfo: [NSLocalizedDescriptionKey: str]))
        }
        else {
            return (false, NSError(domain: ApiTaskErrorDomain, code: ApiTaskDataErrorCode, userInfo: [NSLocalizedDescriptionKey: "未知错误"]))
        }
    }
    
    public func validateString() -> (Bool, String?) {
        return (true, nil)
    }
    
}
