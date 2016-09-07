//
//  ApiBatchTask.swift
//  ApiTask
//
//  Created by daniel on 16/9/7.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

public enum ApiGroupResult {
    case Success([ApiTask])
    case Failure([ApiTask], ApiTask, NSError)
}

public class ApiGroupTask: NSObject {
    public var tasks: [ApiTask]
    public var timeout: NSTimeInterval = 30
    
    public init(tasks: [ApiTask]) {
        self.tasks = tasks
    }
    
    public func timeout(timeout: NSTimeInterval) -> Self {
        self.timeout = timeout
        return self
    }

    public func responseTasks(result: (ApiGroupResult)->Void) -> Self {
        return self
    }
    
    public func resume() -> Self {
        for task in tasks {
            task.resume()
        }
        return self
    }
    
    public func suspend() -> Self {
        for task in tasks {
            task.suspend()
        }
        return self
    }
    
    public func cancel() -> Self {
        for task in tasks {
            task.cancel()
        }
        return self
    }
    
    public func validate() -> (Bool, NSError?, ApiTask?) {
        for task in tasks {
            let (b, error) = task.validate()
            if !b, let error = error {
                return (false, error, task)
            }
        }
        return (true, nil, nil)
    }
}

public class ApiBatchTask: ApiGroupTask {
    private var count: Int = 0
    
    public override func responseTasks(result: (ApiGroupResult)->Void) -> Self {
        let (b, error, task) = validate()
        if !b, let error = error, let task = task {
            result(.Failure(tasks, task, error))
            return self
        }
        
        self.count = self.tasks.count
        for task in tasks {
            responseTask(task, result: result)
        }
        return self
    }
    
    private func responseTask(task: ApiTask, result: (ApiGroupResult)->Void) {
        guard let request = task.request else {
            for task2 in tasks {
                task2.cancel()
            }
            let error =  NSError(domain: ApiTaskErrorDomain, code: ApiTaskDataErrorCode, userInfo: [NSLocalizedDescriptionKey: "请求参数错误"])
            result(.Failure(self.tasks, task, error))
            return
        }
        
        request.response(completionHandler: { (request, response, data, error) in
            self.count -= 1
            
            if let error = error {
                for task2 in self.tasks {
                    if task != task2 {
                        task2.cancel()
                    }
                }
                result(.Failure(self.tasks, task, error))
            }
            else if self.count <= 0 {
                result(.Success(self.tasks))
            }
        })
    }
}

public class ApiChainTask: ApiGroupTask {
    private var index = 0
    
    public override func responseTasks(result: (ApiGroupResult)->Void) -> Self {
        let (b, error, task) = validate()
        if !b, let error = error, let task = task {
            result(.Failure(tasks, task, error))
            return self
        }
        
        index = 0
        responseNextTask(result)
        return self
    }
    
    private func responseNextTask(result: (ApiGroupResult)->Void) {
        guard index < self.tasks.count else {
            return result(.Success(self.tasks))
        }
        
        let task = self.tasks[index]
        guard let request = task.request else {
            let error =  NSError(domain: ApiTaskErrorDomain, code: ApiTaskDataErrorCode, userInfo: [NSLocalizedDescriptionKey: "请求参数错误"])
            return result(.Failure(self.tasks, task, error))
        }
        
        request.response(completionHandler: { (request, response, data, error) in
            if let error = error {
                result(.Failure(self.tasks, task, error))
            }
            else {
                self.index += 1
                self.responseNextTask(result)
            }
            
        })
    }
}
