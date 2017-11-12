//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Vojtěch Böhm on 10/11/2017.
//  Copyright © 2017 Vojtěch Böhm. All rights reserved.
//

import Foundation

struct StudentLocation {
    let firstName: String
    let lastName: String
    let latitude: Double
    let longitude: Double
    let mediaURL: String
    
    init(dictionary: [String:Any]) {
        self.firstName = dictionary["firstName"] as? String ?? "[No First Name]"
        self.lastName = dictionary["lastName"] as? String ?? "[No Last Name]"
        self.latitude = dictionary["latitude"] as? Double ?? 0
        self.longitude = dictionary["longitude"] as? Double ?? 0
        self.mediaURL = dictionary["mediaURL"] as? String ?? "[No URL]"
    }
    
    static func studentLocationsFrom(_ results: [[String:Any]]) -> [StudentLocation] {
        var resultArray = [StudentLocation]()
        
        for dictionary in results {
            resultArray.append(StudentLocation(dictionary: dictionary))
        }
        
        return resultArray
    }
}
