//
//  Constants.swift
//  OnTheMap
//
//  Created by Macbook on 12/16/16.
//  Copyright © 2016 Macbook. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    struct Methods {
        static let getmethod = "get"
    }
    
    struct ParameterKeys{
        static let userName = "criteser2@gmail.com"
        static let password = "susancolt45"
        
    }
    
    struct URL {
        static let APIScheme = "https"
        static let APIHost = "www.udacity.com"
        static let APIPath = "api/"
        static let APISession = "session"
        static let APIUser = "user"
    }
    
    struct ResponseKeys {
        static let account = "account"
        static let key = "key"
        static let registered = "registered"
        static let id = "id"
        static let session = "session"
    }
    
    struct User {
        static var sessionID = ""
        static var accountKey = ""
    }
    
}
