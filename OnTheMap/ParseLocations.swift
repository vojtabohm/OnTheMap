//
//  ParseLocations.swift
//  OnTheMap
//
//  Created by Vojtěch Böhm on 09/11/2017.
//  Copyright © 2017 Vojtěch Böhm. All rights reserved.
//

import Foundation
import CoreLocation

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
        self.state = .loading
        
        //Check to see if I already downloaded Object ID once. If yes, skip return from this method.
        guard objectID == nil else {
            state = .ready
            handler(true, nil)
            return
        }
        
        //FORCED THIS TASK TO A FIXED URL, I COULDNT FIGURE OUT HWO TO ESCAPE COLON CHARACTER
        var urlRequest = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(userID)%22%7D")!)
        urlRequest.addValue(Constants.parseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        urlRequest.addValue(Constants.restAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        urlRequest.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            func sendError(_ error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                handler(false, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                if error!.localizedDescription.contains("connection") {
                    self.error = "Please check your Internet connection"
                } else {
                    self.error = error?.localizedDescription
                }
                self.state = .error
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            guard let data = data else {
                self.error = "No data returned"
                self.state = .error
                sendError("No data was returned by the request!")
                return
            }
            
            self.parseData(data, parseCompletionHandler: { (result, error) in
                guard error == nil else {
                    self.error = "Failed to parse data"
                    self.state = .error
                    sendError("Failed to parse data")
                    return
                }
                
                guard let results = result?["results"] as? [[String:Any]] else {
                    self.error = "Failed to parse results"
                    self.state = .error
                    sendError("Failed to parse results")
                    return
                }
                
                guard let objectID = results.first?["objectId"] as? String else {
                    return
                }
                
                self.objectID = objectID
                self.state = .ready
                
                DispatchQueue.main.async {
                    handler(true, nil)
                }
            })
        }
        
        task.resume()
    }
    
    func geocode(string: String, completionHandler: @escaping (Bool, Error?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(string) { (placemark, error) in
            guard error == nil else {
                DispatchQueue.main.async {
                    completionHandler(false, error)
                }
                return
            }
            
            self.user?.addLocation(Location(objectID: self.objectID, location: (placemark?.first?.location)!))
            
            DispatchQueue.main.async {
                completionHandler(true, nil)
            }
        }
    }
    
    func addLocation(mapString: String, mediaURL: String, latitude: Double, longitude: Double, completionHandler: @escaping (Bool, Error?) -> Void) {
        guard let firstName = user?.firstName, let lastName = user?.lastName, let id = user?.userID else {
            completionHandler(false, NSError(domain: "failure", code: 1, userInfo: [NSLocalizedDescriptionKey:"No User info, unable to post location"]))
            return
        }
        
        var method = Methods.POST
        var methodPath = ""
        
        if objectID != nil {
            method = .PUT
            methodPath = "/\(objectID!)"
        }
        
        let headers = [
            "X-Parse-Application-Id":Constants.parseApplicationID,
            "X-Parse-REST-API-Key":Constants.restAPIKey,
            "Content-Type":"application/json"
        ]
        
        let body: [String:Any] = [
            "uniqueKey":id,
            "firstName":firstName,
            "lastName":lastName,
            "mapString":mapString,
            "mediaURL":mediaURL,
            "latitude":latitude,
            "longitude":longitude
        ]
        
        let _ = taskFor(method: method, parameters: [:], apiMethodPath: ApiMethods.StudentLocation + methodPath, headers: headers, body: body, isFromUdacity: false) { (result, error) in
            guard error == nil else {
                DispatchQueue.main.async {
                    completionHandler(false, error)
                }
                return
            }
            
            guard (result?["updatedAt"]) != nil else {
                DispatchQueue.main.async {
                    completionHandler(false, error)
                }
                return
            }
            
            DispatchQueue.main.async {
                for delegate in self.delegates {
                    delegate.finishedPosting()
                    
                }
                completionHandler(true, error)
            }
        }
    }
}
