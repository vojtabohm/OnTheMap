//
//  UdacityConvenience.swift
//  OnTheMap
//
//  Created by Vojtěch Böhm on 05/11/2017.
//  Copyright © 2017 Vojtěch Böhm. All rights reserved.
//

import Foundation

// Here are authenticate functions that use template functions from UdacityClient; seperated to another file varmaintain readability

extension UdacityClient {
    
    func loginUser(username: String, password: String, loginCompletionHandler: @escaping (Bool,Error?) -> Void) {
        
        let body = [
            "udacity":[
                "username":username,
                "password":password
            ]
        ]
        
        postSession(username: username, password: password, body: body) { (success, sessionID, key, errorString) in
            if success {
                self.sessionID = sessionID!
                self.userID = key!
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
    
    func postSession(username: String, password: String, body: [String:Any], sessionCompletionHandler: @escaping (_ success: Bool, _ sessionID: String?, _ key: String?, _ errorString: String?) -> Void) {
        taskForPOST(parameters: [:], method: Methods.GetSession, body: body) { (result, error) in
            guard error == nil else {
                sessionCompletionHandler(false, nil, nil, error!.localizedDescription)
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
                print(session, account)
                sessionCompletionHandler(false, nil, nil, "Cannot find id key or account id key")
                return
            }
            
            sessionCompletionHandler(true, sessionID, key, nil)
        }
    }
}
