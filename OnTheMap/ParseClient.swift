//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Vojtěch Böhm on 09/11/2017.
//  Copyright © 2017 Vojtěch Böhm. All rights reserved.
//

import Foundation

protocol ParseClientDelegate {
    func changedState(_ state: ParseClient.State)
    func finishedDownloading()
    func finishedPosting()
}

class ParseClient: Client {
    
    enum State {
        case loading
        case ready
        case empty
        case error
    }
    
    //MARK: Properties
    
    static let shared = ParseClient()
    
    var studentLocations: [StudentLocation]? = nil
    var delegates = [ParseClientDelegate]()
    var error: String?
    var objectID: String?
    var user: User? = nil
    var state: State = .empty {
        didSet {
            if oldValue != state {
                DispatchQueue.main.async {
                    for delegate in self.delegates {
                        delegate.changedState(self.state)
                    }
                }
            }
        }
    }
    
    //MARK: Life Cycle
    
    private override init() { }
    
    //MARK: Functions
    
    override func URLFromParameters(parameters: [String : Any], scheme: String, withPathExtension: String?) -> URL {
        var components = URLComponents()
        components.scheme = scheme
        components.host = Constants.ParseAPIHost
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
