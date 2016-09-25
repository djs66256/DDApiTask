//
//  User.swift
//  DDRequest
//
//  Created by daniel on 16/9/3.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

@objc public enum Gender: Int {
    case female = 2
    case male = 1
}

@objc open class User: NSObject {
    @objc var id: String?
    @objc var name: String?
    @objc var gender: Gender = .male
}
