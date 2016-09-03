//
//  UserTask.swift
//  DDRequest
//
//  Created by daniel on 16/9/4.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

public class UserTask: ApiJsonYYModelTask<User> {

    public override init() {
        super.init()
        self.mockData("User.json")
    }
}
