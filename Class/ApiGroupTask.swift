//
//  ApiBatchTask.swift
//  ApiTask
//
//  Created by daniel on 16/9/7.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit
import Alamofire

public enum ApiGroupResult {
    case success([ApiTask])
    case failure([ApiTask], ApiTask, Error)
}

open class ApiGroupTask: NSObject {
    open var tasks: [ApiTask]
    open var timeout: TimeInterval = 30
    
    public init(tasks: [ApiTask]) {
        self.tasks = tasks
    }
    
    open func timeout(_ timeout: TimeInterval) -> Self {
        self.timeout = timeout
        return self
    }

    open func responseTasks(_ result: @escaping (ApiGroupResult)->Void) -> Self {
        return self
    }
    
    open func resume() -> Self {
        for task in tasks {
            let _ = task.resume()
        }
        return self
    }
    
    open func suspend() -> Self {
        for task in tasks {
            let _ = task.suspend()
        }
        return self
    }
    
    open func cancel() -> Self {
        for task in tasks {
            let _ = task.cancel()
        }
        return self
    }
    
    open func validate() -> (Bool, NSError?, ApiTask?) {
        for task in tasks {
            let (b, error) = task.validate()
            if !b, let error = error {
                return (false, error, task)
            }
        }
        return (true, nil, nil)
    }
}

open class ApiBatchTask: ApiGroupTask {
    fileprivate var count: Int = 0
    
    open override func responseTasks(_ result: @escaping (ApiGroupResult)->Void) -> Self {
        let (b, error, task) = validate()
        if !b, let error = error, let task = task {
            result(.failure(tasks, task, error))
            return self
        }
        
        self.count = self.tasks.count
        for task in tasks {
            responseTask(task, result: result)
        }
        return self
    }
    
    fileprivate func responseTask(_ task: ApiTask, result: @escaping (ApiGroupResult)->Void) {
        guard let request = task.request else {
            for task2 in tasks {
                let _ = task2.cancel()
            }
            let error =  NSError(domain: ApiTaskErrorDomain, code: ApiTaskDataErrorCode, userInfo: [NSLocalizedDescriptionKey: "请求参数错误"])
            result(.failure(self.tasks, task, error))
            return
        }
        
        request.response { response in
            self.count -= 1
            
            if let error = response.error {
                for task2 in self.tasks {
                    if task != task2 {
                        let _ = task2.cancel()
                    }
                }
                result(.failure(self.tasks, task, error))
            }
            else if self.count <= 0 {
                result(.success(self.tasks))
            }
        }
    }
}

open class ApiChainTask: ApiGroupTask {
    fileprivate var index = 0
    
    open override func responseTasks(_ result: @escaping (ApiGroupResult)->Void) -> Self {
        let (b, error, task) = validate()
        if !b, let error = error, let task = task {
            result(.failure(tasks, task, error))
            return self
        }
        
        index = 0
        responseNextTask(result)
        return self
    }
    
    fileprivate func responseNextTask(_ result: @escaping (ApiGroupResult)->Void) {
        guard index < self.tasks.count else {
            return result(.success(self.tasks))
        }
        
        let task = self.tasks[index]
        guard let request = task.request else {
            let error =  NSError(domain: ApiTaskErrorDomain, code: ApiTaskDataErrorCode, userInfo: [NSLocalizedDescriptionKey: "请求参数错误"])
            return result(.failure(self.tasks, task, error))
        }
        
        request.response { response in
            if let error = response.error {
                result(.failure(self.tasks, task, error))
            }
            else {
                self.index += 1
                self.responseNextTask(result)
            }
            
        }
    }
}
