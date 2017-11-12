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
        self.firstName = dictionary["first_name"] as? String ?? "[No First Name]"
        self.lastName = dictionary["last_name"] as? String ?? "[No Last Name]"
        self.userID = dictionary["key"] as! String
    }
}
