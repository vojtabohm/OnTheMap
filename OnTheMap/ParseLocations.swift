//
//  ParseLocations.swift
//  OnTheMap
//
//  Created by Vojtěch Böhm on 09/11/2017.
//  Copyright © 2017 Vojtěch Böhm. All rights reserved.
//

import Foundation

extension ParseClient {
    
    func downloadLocations(downloadCompletionHandler: (Bool, String?) -> Void) {
        let parameters: [String:Any] = [
            "limit":100,
            "order":"-updatedAt",
        ]
        
        let headers = [
            "Connection":"close",
            "X-Parse-Application-Id":Constants.parseApplicationID,
            "X-Parse-REST-API-Key":Constants.restAPIKey
        ]
        
        let _ = taskFor(method: .GET, parameters: parameters, apiMethodPath: ApiMethods.StudentLocation, headers: headers, body: [:], isFromUdacity: false) { (result, error) in
            print(result) // THIS INITIALLY IS NIL BECAUSE OF THE STUPID ERROR
        }
        
    }
}
