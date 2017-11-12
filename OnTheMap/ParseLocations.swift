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
    
    func downloadUserLocation(completionHandler: @escaping (Bool, Error?) -> Void) {
        getUserLocation(UdacityClient.shared.userID!, handler: completionHandler)
    }
    
    func getUserLocation(_ userID: String, handler: @escaping (Bool, Error?) -> Void) {
        //FORCED THIS TASK TO A FIXED URL, I COULDNT FIGURE OUT HWO TO ESCAPE COLON CHARACTER
        var urlRequest = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(userID)%22%7D")!)
        urlRequest.addValue(Constants.parseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        urlRequest.addValue(Constants.restAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        urlRequest.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            func sendError(_ error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                handler(false, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            self.parseData(data, parseCompletionHandler: { (result, error) in
                guard error == nil else {
                    sendError("Failed to parse data")
                    return
                }
                
                guard let objectID = result?["objectId"] as? String else {
                    return
                }
                
                self.objectID = objectID
                
                print(self.objectID)
            })
        }
        
        task.resume()
    }
}
