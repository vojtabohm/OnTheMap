//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Vojtěch Böhm on 05/11/2017.
//  Copyright © 2017 Vojtěch Böhm. All rights reserved.
//

import Foundation

class UdacityClient: NSObject {
    
    //MARK: Properties
    
    static let shared = UdacityClient()
    
    var sessionID: String? = nil
    var userID: String? = nil
    
    //MARK: Life Cycle
    
    private override init() {}
    
    //MARK: Functions
    
    func URLFromParameters(parameters: [String:Any], withPathExtension: String? = nil) -> URL {
        var components = URLComponents()
        components.scheme = "https"
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
    
    func parseData(_ data: Data, parseCompletionHandler: (_ results: AnyObject?, _ error: Error?) -> Void) {
        var parsedResult: AnyObject?
        parsedResult = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        
        guard let result = parsedResult else {
            parseCompletionHandler(nil, NSError(domain: "failure", code: 1, userInfo: [NSLocalizedDescriptionKey:"Can't parse JSON from PARSE DATA"]))
            return
        }
        
        parseCompletionHandler(result, nil)
    }
    
    //Generalized task function for every method listed in UdacityClient.Methods
    func taskFor(method: Methods, parameters: [String:Any], apiPath: String, headers: [String:Any], body: [String:Any], isFromUdacity: Bool, _ handler: @escaping (_ data: AnyObject?, _ error: Error?) -> Void) -> URLSessionDataTask {
        
        var request = URLRequest(url: URLFromParameters(parameters: parameters, withPathExtension: apiPath))
        request.httpMethod = method.rawValue
        
        for (key, value) in headers {
            request.addValue("\(value)", forHTTPHeaderField: key)
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                handler(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            //If the response comes from Udacity, skip first 5 chars (security server-sided reasons)
            if isFromUdacity {
                let range = Range(5..<data.count)
                let newData = data.subdata(in: range)
                
                self.parseData(newData, parseCompletionHandler: handler)
            } else {
                self.parseData(data, parseCompletionHandler: handler)
            }
        }
        
        task.resume()
        return task
    }
}
