//
//  ApiTaskConfig.swift
//  ApiTask
//
//  Created by daniel on 16/9/4.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit
//import DDFileCache

open class ApiTaskConfig<M, S:ModelSerializer>: NSObject where S.ModelType == M {
    var serializer: S
    var cache: ApiCacheProtocol?
    
    public init(serializer: S, cache: ApiCacheProtocol? = nil) {
        self.serializer = serializer
        self.cache = cache
    }
}

public struct ApiTaskCache {
    public static let defaultCache = ApiDefaultCache() //DDCache(name: "ApiTask")
}

public func ApiTaskDefaultYYConfig<M>() -> ApiTaskConfig<M, ApiJsonModelSerializer<M>> {
    return ApiTaskConfig(serializer: ApiJsonModelSerializer<M>(), cache: ApiTaskCache.defaultCache)
}

//extension DDCache: ApiCacheProtocol {
//    
//}

public class ApiDefaultCache: NSObject, ApiCacheProtocol {
    
    private let cache = NSCache<NSString, AnyObject>()
    
    public func object(forKey key: String) -> AnyObject? {
        return cache.object(forKey: key as NSString)
    }
    public func setObject(_ obj: AnyObject?, forKey key: String, timeInterval: TimeInterval) {
        if let obj = obj {
            cache.setObject(obj, forKey: key as NSString)
        }
        else {
            removeObject(forKey: key)
        }
    }
    public func removeObject(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }
    
    public func removeAllObjects() {
        cache.removeAllObjects()
    }
    
}
