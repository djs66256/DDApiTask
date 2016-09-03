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

let ApiTaskErrorDomain = "com.api.task"

let ApiTaskDataErrorCode = -666

public class ApiJsonModelTask <T: NSObject, M:ModelSerializer where M.ModelType == T>: ApiTask {
    var serializer: M
    
    public init(serializer: M) {
        self.serializer = serializer
    }
    
    public func responseModel<M:ModelSerializer where M.ModelType == T>(serializer: M, result: (Result<T>) -> Void) {
        if let request = buildRequest() {
            request.responseJSON(completionHandler: { (response: Response<AnyObject, NSError>) in
                switch response.result {
                case .Success(let json):
                    if let dict = json as? [NSObject: NSObject] {
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
            let error = NSError(domain: ApiTaskErrorDomain, code: ApiTaskDataErrorCode, userInfo: [NSURLLocalizedLabelKey: "请求参数错误"])
            result(Result.Failure(error))
        }
    }
    
    public func responseModel(result: (Result<T>) -> Void) {
        responseModel(serializer, result: result)
    }
}
