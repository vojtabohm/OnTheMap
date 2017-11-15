//
//  UdacityAuthentication.swift
//  OnTheMap
//
//  Created by Vojtěch Böhm on 05/11/2017.
//  Copyright © 2017 Vojtěch Böhm. All rights reserved.
//

import Foundation
import UIKit // UNFORTUNATELY I MUST IMPORT UIKIT FOR UIAPPLICATION OPEN TO SEPERATE THIS LOGIC FROM THE LOGINVIEWCONTROLLER

// Here are authenticate functions that use template functions from UdacityClient; seperated to another file to maintain readability

extension UdacityClient {
    
    func loginUser(username: String, password: String, loginCompletionHandler: @escaping (Bool,Error?) -> Void) { // Send over the username and password
        let body = [
            "udacity":[
                "username":username,
                "password":password
            ]
        ]
        
        let headers = [
            "Accept":"application/json",
            "Content-Type":"application/json"
        ]
        
        postSession(username: username, password: password, headers: headers, body: body) { (success, sessionID, key, errorString) in
            if success {
                self.sessionID = sessionID!
                self.userID = key!
                self.getUserData()
                DispatchQueue.main.async {
                    loginCompletionHandler(true, nil)
                }
            } else {
                DispatchQueue.main.async {
                    loginCompletionHandler(false, NSError(domain: "failed", code: 1, userInfo: [NSLocalizedDescriptionKey:errorString!]))
                }
            }
        }
    }
    
    func postSession(username: String, password: String, headers: [String:Any], body: [String:Any], sessionCompletionHandler: @escaping (_ success: Bool, _ sessionID: String?, _ key: String?, _ errorString: String?) -> Void) {
        let _ = taskFor(method: .POST, parameters: [:], apiMethodPath: ApiMethods.Session, headers: headers, body: body, scheme: "https",isFromUdacity: true) { (result, error) in
            guard error == nil else {
                if error!.localizedDescription.contains("connection") {
                    sessionCompletionHandler(false, nil, nil, "Check your Internet connection please")
                } else {
                    sessionCompletionHandler(false, nil, nil, error!.localizedDescription)
                }
                return
            }
            
            guard let session = result?["session"] as? [String:Any], let account = result?["account"] as? [String:Any] else {
                guard let error = result?["error"] as? String else {
                    sessionCompletionHandler(false, nil, nil, "Can't find session key or account key")
                    return
                }
                sessionCompletionHandler(false, nil, nil, error)
                return
            }
            
            guard let sessionID = session["id"] as? String, let key = account["key"] as? String else {
                sessionCompletionHandler(false, nil, nil, "Cannot find id key or account id key")
                return
            }
            
            guard let registered = account["registered"] as? Int, registered == 1 else {
                sessionCompletionHandler(false, nil, nil, "User not registered")
                return
            }
            
            sessionCompletionHandler(true, sessionID, key, nil)
        }
    }
    
    func getUserData() {
        let _ = taskFor(method: .POST, parameters: [:], apiMethodPath: ApiMethods.User + "/\(userID!)", headers: [:], body: [:], scheme: "http", isFromUdacity: true) { (result, error) in
            guard error == nil else {
                return
            }
            
            guard let user = result?["user"] as? [String:Any] else {
                return
            }
            
            ParseClient.shared.user = User(dictionary: user)
        }
    }
    
    func logOut(logOutCompletionHandler: @escaping (Bool,Error?) -> Void) {
        let headers: [String:Any] = ["X-XSRF-TOKEN":sessionID!]
        
        let _ = taskFor(method: .DELETE, parameters: [:], apiMethodPath: ApiMethods.Session, headers: headers, body: [:], scheme: "http", isFromUdacity: true) { (result, error) in
            guard error == nil else {
                if error!.localizedDescription.contains("connection") {
                    logOutCompletionHandler(false, NSError(domain: "failure", code: 0, userInfo: [NSLocalizedDescriptionKey:"Check your Internet connection please"]))
                } else {
                    logOutCompletionHandler(false, error)
                }
                return
            }

            DispatchQueue.main.async {
                logOutCompletionHandler(true, nil)
            }
        }
    }
    
    func signUp() {
        guard let url = URL(string: Constants.UdacitySignUpWebsite) else {
            return
        }
        
        UIApplication.shared.openURL(url)
    }
}
