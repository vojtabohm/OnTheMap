//
//  Constants.swift
//  OnTheMap
//
//  Created by Vojtěch Böhm on 05/11/2017.
//  Copyright © 2017 Vojtěch Böhm. All rights reserved.
//

import Foundation

extension UdacityClient {
    struct Constants {
        static let parseApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let restAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let UdacityAPIHost = "www.udacity.com"
        static let APIPath = "/api"
        static let UdacitySignUpWebsite = "https://www.udacity.com/account/auth#!/signup"
    }
    
    struct ApiMethods {
        static let Session = "/session"
    }
    
    enum Methods: String {
        case GET = "GET"
        case POST = "POST"
        case DELETE = "DELETE"
        case PUT = "PUT"
    }
}
