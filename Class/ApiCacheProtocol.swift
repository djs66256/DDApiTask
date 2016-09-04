//
//  ApiCacheProtocol.swift
//  ApiTask
//
//  Created by daniel on 16/9/4.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

public protocol ApiCacheProtocol {
    
    func objectForKey(key: String) -> AnyObject?
    func setObject(obj: AnyObject?, forKey key: String, timeInterval: NSTimeInterval)
    func removeObjectForKey(key: String)
    
    func removeAllObjects()
}
