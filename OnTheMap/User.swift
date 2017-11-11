//
//  User.swift
//  OnTheMap
//
//  Created by Vojtěch Böhm on 11/11/2017.
//  Copyright © 2017 Vojtěch Böhm. All rights reserved.
//

import Foundation

struct User {
    let firstName: String
    let lastName: String
    let userID: String
    
    init(dictionary: [String:Any]) {
        self.firstName = dictionary["first_name"] as! String
        self.lastName = dictionary["last_name"] as! String
        self.userID = dictionary["key"] as! String
    }
}
