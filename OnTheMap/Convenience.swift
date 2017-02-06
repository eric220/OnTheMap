//
//  Convenience.swift
//  OnTheMap
//
//  Created by Macbook on 2/6/17.
//  Copyright © 2017 Macbook. All rights reserved.
//

import Foundation
import UIKit

extension Client{
    func launchAlert(message: String) -> UIAlertController {
        let alert = UIAlertController(title: "Alert", message: "\(message)", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        return alert
    }

    func logout(handler:@escaping (_ response: Bool, _ error: NSError?) -> Void) {
        let parameters = [String: AnyObject]()
        let urlRequest = Client.sharedInstance().OTMUrlParameter(parameters: parameters, withPathExtension: "/api/session", withHost: Constants.URL.APIHostUdacity)
        let request = NSMutableURLRequest(url: urlRequest)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        taskManager(request: request){(data, response, error) in
            handler(response, error)
        }
    }
    
    func loginManager(email: String, password: String, handler:@escaping (_ response: Bool,_ error: Bool?) -> Void){
        let parameters = [String: AnyObject]()
        let urlRequest = OTMUrlParameter(parameters: parameters, withPathExtension: "/api/session", withHost: Constants.URL.APIHostUdacity)
        let request = NSMutableURLRequest(url: urlRequest)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
        taskManager(request: request){data, response, error in
            if (!response){
                handler(false, false)
            } else if (error != nil){
                handler(true, true)
            } else {
                let newData = data as! Data// subset response data!
                let range = Range(uncheckedBounds: (5, newData.count))
                let reallyNewData = newData.subdata(in: range)
                self.convertDataWithCompletionHandler(reallyNewData){(result, error) in
                    if let keyResult = result?[Constants.ResponseKeys.account] as? [String: AnyObject] {
                        let accountKey = keyResult[Constants.ResponseKeys.key] as! String
                        Constants.User.accountKey = accountKey
                    }
                    if let sessionResult = result?[Constants.ResponseKeys.session] as? [String: AnyObject] {
                        let sessionID = sessionResult[Constants.ResponseKeys.id] as! String
                        Constants.User.sessionID = sessionID
                    }
                    if ((result?["registered"]) != nil){
                        print("Logged In")
                        handler(true, false)
                    }
                }
            }
        }

    }
}
