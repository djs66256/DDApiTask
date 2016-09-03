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
public class ApiJsonModelSerializer<ModelType: NSObject>: NSObject, ModelSerializer {
    public var successCodeRange: Range<Int> = 0..<1
    
    public func modelSerialize(dict: [NSObject : NSObject]) -> Result<ModelType> {
        let json = SwiftyJSON.JSON(dict)
        if let code = json["code"].int {
            if successCodeRange.contains(code) {
                if let dictModel = json["data"].dictionaryObject {
                    if let model = ModelType.yy_modelWithJSON(dictModel) {
                        return Result.Success(model)
                    }
                    else {
                        return buildDataError()
                    }
                }
                else if let arrayModel = json["data"].arrayObject {
                    if let array = NSArray.yy_modelArrayWithClass(ModelType.self, json: arrayModel) as? [ModelType] {
                        return Result.SuccessArray(array)
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
                    return Result.Failure(error)
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
    
    private func buildDataError() -> Result<ModelType> {
        let error = NSError(domain: ApiTaskErrorDomain, code: ApiTaskDataErrorCode, userInfo: [NSLocalizedDescriptionKey: "数据结构错误"])
        return Result.Failure(error)
    }
}

public class ApiJsonYYModelTask<T: NSObject>: ApiJsonModelTask<T, ApiJsonModelSerializer<T>> {
    public init() {
        super.init(serializer: ApiJsonModelSerializer<T>())
    }
}