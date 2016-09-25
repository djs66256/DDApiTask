//
//  ApiCacheProtocol.swift
//  ApiTask
//
//  Created by daniel on 16/9/4.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

public protocol ApiCacheProtocol {
    
    func object(forKey key: String) -> AnyObject?
    func setObject(_ obj: AnyObject?, forKey key: String, timeInterval: TimeInterval)
    func removeObject(forKey key: String)
    
    func removeAllObjects()
}
