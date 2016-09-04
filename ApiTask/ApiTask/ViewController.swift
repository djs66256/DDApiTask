//
//  ViewController.swift
//  ApiTask
//
//  Created by daniel on 16/9/4.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ApiJsonYYModelTask<User>()
            .buildMethod(.POST)
            .buildURL("user", baseURL: NSURL(string: "http://www.baidu.com")!)
            .buildParameter("id", "12")
            .buildParameters(["key": "value"])
            .buildHeaders(["Authorization": "xxfwqwefq2efiwefo"])
            .buildCache(true)   // 本地缓存
            .cacheModel({ (user) in     // 获取本地缓存
                NSLog(user.description)
            })
            .responseModel ({ (result) in
                switch result {
                case .Success(let user):
                    NSLog(user.description)
                case .Failure(let error):
                    NSLog(error.localizedDescription)
                default:
                    break
                }
            })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

