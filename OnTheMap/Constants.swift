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
        static let APIHostUdacity = "www.udacity.com"
        static let APIHostParse = "www.parse.udacity.com"
        static let APIHostParseNoWWW = "parse.udacity.com"
        static let APIPath = "api/"
        static let APISession = "session"
        static let APIUser = "user"
        static let url = "https://parse.udacity.com/parse/classes/StudentLocation"
    }
    
    struct ResponseKeys {
        static let account = "account"
        static let key = "key"
        static let registered = "registered"
        static let id = "id"
        static let session = "session"
        static let objectId = "objectId"
        static let uniqueKey = "uniqueKey"
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let mapString = "mapString"
        static let mediaUrl = "mediaURL"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let createdAt = "createdAt"
        static let updatedAt = "updatedAt"
        static let ACL = true

    }
    
    struct User {
        static var sessionID = ""
        static var accountKey = ""
        static var firstName = "Eric"
        static let lastName = "Criteser"
        static var mapString = "Gulf Shores, AL"
        static var mediaUrl = "https://udacity.com"
        static var latitude: Double = 30.272469000000001
        static var longitude: Double = -80.194702000000007
        static var hasPin: Bool = false
    }
    
    struct ParseParameters {
        static let parseID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let parseAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"

    }
    
}
