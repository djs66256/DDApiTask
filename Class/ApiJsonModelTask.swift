//
//  ApiJsonModelTask.swift
//  DDRequest
//
//  Created by daniel on 16/9/3.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit
import Alamofire

public enum ApiResult<T> {
    case success(T)
    case successArray([T])
    case failure(Error)
}

public protocol ModelSerializer {
    associatedtype ModelType
    
    func modelSerialize(_ json: [NSObject: NSObject]) -> ApiResult<ModelType>
}

public let ApiTaskErrorDomain = "com.api.task"

public let ApiTaskDataErrorCode = -666

open class ApiJsonModelTask <T: AnyObject, M:ModelSerializer>: ApiTask where M.ModelType == T {
    fileprivate var config: ApiTaskConfig<T, M>
    open var localCacheEnable = false
    open var expireTimeInterval: TimeInterval = 24*3600
    
    open var cacheKey: String? {
        get {
            let data = try? JSONSerialization.data(withJSONObject: self.parameters, options: JSONSerialization.WritingOptions(rawValue: 0))
            let str = "\(self.path) => \(data)"
            return str
        }
    }
    
    public init(config: ApiTaskConfig<T, M>) {
        self.config = config
    }
    
    open func cache(_ enable: Bool, timeInterval: TimeInterval = 24*3600) -> Self {
        self.localCacheEnable = enable
        self.expireTimeInterval = timeInterval
        return self
    }
    
    open func clearCache() -> Self {
        if let key = cacheKey {
            config.cache?.removeObject(forKey: key)
        }
        return self
    }
    
    // need buildCache(true)
    open func cacheModel(_ result: (T)->Void) -> Self {
        if localCacheEnable && method == .GET {
            if let key = cacheKey, let data = config.cache?.object(forKey: key) as? [NSObject: NSObject] {
                let r = config.serializer.modelSerialize(data)
                switch r {
                case .success(let model):
                    result(model)
                default:
                    break
                }
            }
        }
        return self
    }
    
    open func cacheModelArray(_ result: ([T])->Void) -> Self {
        if localCacheEnable && method == .GET {
            if let key = cacheKey, let data = config.cache?.object(forKey: key) as? [NSObject: NSObject] {
                let r = config.serializer.modelSerialize(data)
                switch r {
                case .successArray(let model):
                    result(model)
                default:
                    break
                }
            }
        }
        return self
    }
    
    open func responseModel(_ serializer: M, result: @escaping (ApiResult<T>) -> Void) -> Self {
        let (validated, error) = validate()
        if !validated, let error = error {
            result(.failure(error))
        }
        else if let request = self.request {
            request.responseJSON { response in
                switch response.result {
                case .success(let json):
                    if let dict = json as? [NSObject: NSObject] {
                        if self.localCacheEnable && self.method == .GET {
                            if let key = self.cacheKey {
                                self.config.cache?.setObject(dict as AnyObject?, forKey: key, timeInterval: self.expireTimeInterval)
                            }
                        }
                        result(serializer.modelSerialize(dict))
                    }
                    else {
                        let error = NSError(domain: ApiTaskErrorDomain, code: ApiTaskDataErrorCode, userInfo: [NSLocalizedDescriptionKey: "数据结构错误"])
                        result(.failure(error))
                    }
                case .failure(let error):
                    result(.failure(error))
                }
            }
        }
        else {
            let error = NSError(domain: ApiTaskErrorDomain, code: ApiTaskDataErrorCode, userInfo: [URLResourceKey.localizedLabelKey: "未构造请求"])
            result(.failure(error))
        }
        return self
    }
    
    open func responseModel(_ result: @escaping (ApiResult<T>) -> Void) -> Self {
        return responseModel(config.serializer, result: result)
    }
    
}
