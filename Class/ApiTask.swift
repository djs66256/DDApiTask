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

open class ApiTask: NSObject {
    // You can also override the getter to dynamic build it!
    open var method: Method = .GET
    open var parameters = [String: AnyObject]()
    open var parameterEncoding = Alamofire.URLEncoding.default
    open var headers = [String: String]()
    open var baseURL: Foundation.URL?
    open var path: String = ""
    
    // MARK: - MOCK
    open var mock: Bool = false
    open var baseMockURL = Bundle.main.bundleURL
    open var mockPath: String?
    
    var request: Alamofire.DataRequest? {
        get {
            if let url = self.URL {
                return Alamofire.request(url, method: Alamofire.HTTPMethod(rawValue: self.method.rawValue)!, parameters: self.parameters, encoding: self.parameterEncoding, headers: self.headers)
//                return Alamofire.request(Alamofire.Method(rawValue:self.method.rawValue)!, url, parameters: self.parameters, encoding: self.parameterEncoding, headers: self.headers)
            }
            else {
                return nil
            }
        }
    }
    
    public override init() {
        super.init()
    }
    
    fileprivate var URL: Foundation.URL? {
        get {
            if mock && mockPath != nil {
                return Foundation.URL(string: mockPath!, relativeTo: baseMockURL)
            }
            else {
                if let baseURL = self.baseURL {
                    let url = Foundation.URL(string: self.path, relativeTo: baseURL)
                    return url
                }
                else {
                    return Foundation.URL(string: "")
                }
            }
        }
    }
    
    open func method(_ method: Method) -> Self {
        self.method = method
        return self
    }
    
    open func parameters(_ parameters: [String: AnyObject]?) -> Self {
        if let parameters = parameters {
            for (key, value) in parameters {
                let _ = parameter(key, value)
            }
        }
        return self
    }
    
    open func parameter(_ key: String, _ value: AnyObject) -> Self {
        self.parameters[key] = value
        return self
    }
    
    open func headers(_ headers: [String: String]?) -> Self {
        if let headers = headers {
            for (key, value) in headers {
                let _ = header(key, value)
            }
        }
        return self
    }
    
    open func header(_ key: String, _ value: String) -> Self {
        self.headers[key] = value
        return self
    }
    
    open func URL(_ path: String, baseURL: Foundation.URL) -> Self {
        self.path = path
        self.baseURL = baseURL
        return self
    }
    
    open func mock(_ mock: Bool, mockPath: String? = nil, baseMockURL: Foundation.URL? = nil) -> Self {
        self.mock = mock
        self.mockPath = mockPath ?? "\(type(of: self)).json"
        if let baseMockURL = baseMockURL {
            self.baseMockURL = baseMockURL
        }
        return self
    }
    
    open func validate() -> (Bool, NSError?) {
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
    
    open func validateString() -> (Bool, String?) {
        return (true, nil)
    }
    
    open func cancel() -> Self {
        request?.cancel()
        return self
    }
    
    open func resume() -> Self {
        if request?.task?.state == .suspended {
            request?.resume()
        }
        return self
    }
    
    open func suspend() -> Self {
        if request?.task?.state == .running {
            request?.suspend()
        }
        return self
    }
}
