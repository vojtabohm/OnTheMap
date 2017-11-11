//
//  ParseLocations.swift
//  OnTheMap
//
//  Created by Vojtěch Böhm on 09/11/2017.
//  Copyright © 2017 Vojtěch Böhm. All rights reserved.
//

import Foundation

extension ParseClient {
    
    func downloadLocations() {
        self.state = .loading
        
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
                if (error?.localizedDescription.contains("connection"))! {
                    self.error = "Please check your Internet connection"
                } else {
                    self.error = error?.localizedDescription
                }
                self.state = .error
                return
            }
            
            guard let results = result?["results"] as? [[String:Any]] else {
                self.error = "Cannot find results"
                self.state = .error
                return
            }
            
            let studentLocations = StudentLocation.studentLocationsFrom(results)
            self.studentLocations = studentLocations
            
            guard self.studentLocations != nil else {
                self.error = "Couldn't create Locations"
                self.state = .error
                return
            }
            
            self.state = .ready
            
            DispatchQueue.main.async {
                for delegate in self.delegates {
                    delegate.finishedDownloading()
                }
            }
        }
        
    }
}
