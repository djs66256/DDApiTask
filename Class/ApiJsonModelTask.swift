//
//  ApiJsonModelTask.swift
//  DDRequest
//
//  Created by daniel on 16/9/3.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit
import Alamofire

public enum Result<T> {
    case Success(T)
    case SuccessArray([T])
    case Failure(NSError)
}

public protocol ModelSerializer {
    associatedtype ModelType
    
    func modelSerialize(json: [NSObject: NSObject]) -> Result<ModelType>
}

public let ApiTaskErrorDomain = "com.api.task"

public let ApiTaskDataErrorCode = -666

public class ApiJsonModelTask <T: AnyObject, M:ModelSerializer where M.ModelType == T>: ApiTask {
    private var config: ApiTaskConfig<T, M>
    public var localCacheEnable = false
    public var expireTimeInterval: NSTimeInterval = 24*3600
    
    public init(config: ApiTaskConfig<T, M>) {
        self.config = config
    }
    
    public func buildCache(enable: Bool, timeInterval: NSTimeInterval = 24*3600) -> Self {
        self.localCacheEnable = enable
        self.expireTimeInterval = timeInterval
        return self
    }
    
    public func clearCache() -> Self {
        if let key = cacheKey() {
            config.cache?.removeObjectForKey(key)
        }
        return self
    }
    
    // need buildCache(true)
    public func cacheModel(result: (T)->Void) -> Self {
        if localCacheEnable && method == .GET {
            if let key = cacheKey(), data = config.cache?.objectForKey(key) as? [NSObject: NSObject] {
                let r = config.serializer.modelSerialize(data)
                switch r {
                case .Success(let model):
                    result(model)
                default:
                    break
                }
            }
        }
        return self
    }
    
    public func cacheModelArray(result: ([T])->Void) -> Self {
        if localCacheEnable && method == .GET {
            if let key = cacheKey(), data = config.cache?.objectForKey(key) as? [NSObject: NSObject] {
                let r = config.serializer.modelSerialize(data)
                switch r {
                case .SuccessArray(let model):
                    result(model)
                default:
                    break
                }
            }
        }
        return self
    }
    
    public func responseModel<M:ModelSerializer where M.ModelType == T>(serializer: M, result: (Result<T>) -> Void) -> Self {
        if let request = request {
            request.responseJSON(completionHandler: {(response: Response<AnyObject, NSError>) in
                switch response.result {
                case .Success(let json):
                    if let dict = json as? [NSObject: NSObject] {
                        if self.localCacheEnable && self.method == .GET {
                            if let key = self.cacheKey() {
                                self.config.cache?.setObject(dict, forKey: key, timeInterval: self.expireTimeInterval)
                            }
                        }
                        result(serializer.modelSerialize(dict))
                    }
                    else {
                        let error = NSError(domain: ApiTaskErrorDomain, code: ApiTaskDataErrorCode, userInfo: [NSLocalizedDescriptionKey: "数据结构错误"])
                        result(Result.Failure(error))
                    }
                case .Failure(let error):
                    result(Result.Failure(error))
                }
            })
        }
        else {
            let error = NSError(domain: ApiTaskErrorDomain, code: ApiTaskDataErrorCode, userInfo: [NSURLLocalizedLabelKey: "未构造请求"])
            result(Result.Failure(error))
        }
        return self
    }
    
    public func responseModel(result: (Result<T>) -> Void) -> Self {
        return responseModel(config.serializer, result: result)
    }
    
    private func cacheKey() -> String? {
        let data = try? NSJSONSerialization.dataWithJSONObject(self.parameters ?? [:], options: NSJSONWritingOptions(rawValue: 0))
        let str = "\(self.path) => \(data ?? "")"
        return str
    }
}
