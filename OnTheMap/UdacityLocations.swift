//
//  UdacityLocations.swift
//  OnTheMap
//
//  Created by Vojtěch Böhm on 11/11/2017.
//  Copyright © 2017 Vojtěch Böhm. All rights reserved.
//

import Foundation

extension UdacityClient {
    func getUserData() {
        let _ = taskFor(method: .POST, parameters: [:], apiMethodPath: ApiMethods.User + "/\(userID!)", headers: [:], body: [:], isFromUdacity: true) { (result, error) in
            guard error == nil else {
                return
            }
            
            guard let user = result?["user"] as? [String:Any] else {
                return
            }
            
            self.user = User(dictionary: user)
        }
    }
    
    func getUserLocation(_ userID: String) {
        
    }
}
