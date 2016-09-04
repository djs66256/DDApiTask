//
//  ApiTaskConfig.swift
//  ApiTask
//
//  Created by daniel on 16/9/4.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit
import DDFileCache

public class ApiTaskConfig<M, S:ModelSerializer where S.ModelType == M>: NSObject {
    var serializer: S
    var cache: ApiCacheProtocol?
    
    public init(serializer: S, cache: ApiCacheProtocol? = nil) {
        self.serializer = serializer
        self.cache = cache
    }
}

public struct ApiTaskCache {
    public static let defaultCache = DDCache(name: "ApiTask")
}

public func ApiTaskDefaultYYConfig<M>() -> ApiTaskConfig<M, ApiJsonModelSerializer<M>> {
    return ApiTaskConfig(serializer: ApiJsonModelSerializer<M>(), cache: ApiTaskCache.defaultCache)
}

extension DDCache: ApiCacheProtocol {
    
}
