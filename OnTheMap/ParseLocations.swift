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
                self.state = .error
                self.error = error
                return
            }
            
            guard let results = result?["results"] as? [[String:Any]] else {
                self.state = .error
                self.error = NSError(domain: "failed", code: 1, userInfo: [NSLocalizedDescriptionKey:"Cannot find results"])
                return
            }
            
            let studentLocations = StudentLocation.studentLocationsFrom(results)
            self.studentLocations = studentLocations
            
            guard self.studentLocations != nil else {
                self.state = .error
                self.error = NSError(domain: "failed", code: 1, userInfo: [NSLocalizedDescriptionKey:"Couldn't create Locations"])

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
