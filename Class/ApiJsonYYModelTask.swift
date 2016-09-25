//
//  ApiJsonYYModelTask.swift
//  DDRequest
//
//  Created by daniel on 16/9/4.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit
import SwiftyJSON
import YYModel

/**
 {
 code: Int
 message?: String
 data?: Dictionary
 }
 */
open class ApiJsonModelSerializer<ModelType: NSObject>: NSObject, ModelSerializer {
    open var successCodeRange: CountableRange<Int> = 0..<1
    
    open func modelSerialize(_ dict: [NSObject : NSObject]) -> ApiResult<ModelType> {
        let json = SwiftyJSON.JSON(dict)
        if let code = json["code"].int {
            if successCodeRange.contains(code) {
                if let dictModel = json["data"].dictionaryObject {
                    if let model = ModelType.yy_model(withJSON: dictModel) {
                        return ApiResult.success(model)
                    }
                    else {
                        return buildDataError()
                    }
                }
                else if let arrayModel = json["data"].arrayObject {
                    if let array = NSArray.yy_modelArray(with: ModelType.self, json: arrayModel) as? [ModelType] {
                        return ApiResult.successArray(array)
                    }
                    else {
                        return buildDataError()
                    }
                }
                else {
                    return buildDataError()
                }
            }
            else {
                if let message = json["message"].string {
                    let error = NSError(domain: ApiTaskErrorDomain, code: ApiTaskDataErrorCode, userInfo: [NSLocalizedDescriptionKey:message])
                    return ApiResult.failure(error)
                }
                else {
                    return buildDataError()
                }
            }
        }
        else {
            return buildDataError()
        }
    }
    
    fileprivate func buildDataError() -> ApiResult<ModelType> {
        let error = NSError(domain: ApiTaskErrorDomain, code: ApiTaskDataErrorCode, userInfo: [NSLocalizedDescriptionKey: "数据结构错误"])
        return ApiResult.failure(error)
    }
}

open class ApiJsonYYModelTask<T: NSObject>: ApiJsonModelTask<T, ApiJsonModelSerializer<T>> {
    public init() {
        super.init(config: ApiTaskDefaultYYConfig())
    }
    
    public override init(config: ApiTaskConfig<T, ApiJsonModelSerializer<T>>) {
        super.init(config: config)
    }
}
