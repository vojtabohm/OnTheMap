//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Vojtěch Böhm on 05/11/2017.
//  Copyright © 2017 Vojtěch Böhm. All rights reserved.
//

import Foundation

class UdacityClient: Client {
    
    //MARK: Properties
    
    static let shared = UdacityClient()
    
    var sessionID: String? = nil
    var userID: String? = nil
    var user: User? = nil
    
    //MARK: Life Cycle
    
    private override init() {}
    
    //MARK: Functions
    
    override func URLFromParameters(parameters: [String:Any], withPathExtension: String? = nil) -> URL {
        var components = URLComponents()
        components.scheme = "http"
        components.host = Constants.UdacityAPIHost
        components.path = Constants.APIPath + (withPathExtension ?? "")
        
        if !parameters.isEmpty {
            components.queryItems = [URLQueryItem]()
            
            for item in parameters {
                let queryItem = URLQueryItem(name: item.key, value: "\(item.value)")
                components.queryItems?.append(queryItem)
            }
        }
        
        return components.url!
    }
}
