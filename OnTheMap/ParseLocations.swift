//
//  ParseLocations.swift
//  OnTheMap
//
//  Created by Vojtěch Böhm on 09/11/2017.
//  Copyright © 2017 Vojtěch Böhm. All rights reserved.
//

import Foundation

extension ParseClient {
    
    func downloadLocations(downloadCompletionHandler: @escaping (Bool, String?) -> Void) {
        let parameters: [String:Any] = [
            "limit":100,
            "order":"-updatedAt",
        ]
        
        let headers = [
            "X-Parse-Application-Id":Constants.parseApplicationID,
            "X-Parse-REST-API-Key":Constants.restAPIKey
        ]
        
        let _ = taskFor(method: .POST, parameters: parameters, apiMethodPath: ApiMethods.StudentLocation, headers: headers, body: [:], isFromUdacity: false) { (result, error) in
            guard error == nil else {
                downloadCompletionHandler(false, error?.localizedDescription)
                return
            }
            
            guard let results = result?["results"] as? [[String:Any]] else {
                downloadCompletionHandler(false, "Cannot find results")
                return
            }
            
            let studentLocations = StudentLocation.studentLocationsFrom(results)
            self.studentLocations = studentLocations
            
            guard self.studentLocations != nil else {
                downloadCompletionHandler(false, "Couldn't create Locations")
                return
            }
            
            downloadCompletionHandler(true, nil)
        }
        
    }
}
