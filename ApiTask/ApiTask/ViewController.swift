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
        
        let _ = ApiJsonYYModelTask<User>()
            .method(.POST)
            .URL("user", baseURL: URL(string: "http://www.baidu.com")!)
            .parameter("id", "12" as NSString)
            .parameters(["key": "value" as NSString])
            .headers(["Authorization": "xxfwqwefq2efiwefo"])
            .cache(true)   // 本地缓存
            .cacheModel({ (user) in     // 获取本地缓存
                NSLog(user.description)
            })
            .responseModel ({ (result) in
                switch result {
                case .success(let user):
                    NSLog(user.description)
                case .failure(let error):
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

