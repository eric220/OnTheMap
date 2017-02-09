//
//  Convenience.swift
//  OnTheMap
//
//  Created by Macbook on 2/6/17.
//  Copyright © 2017 Macbook. All rights reserved.
//

import Foundation
import UIKit
import MapKit

extension Client{

    func logout(handler:@escaping (_ response: Bool, _ error: String?) -> Void) {
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
        taskManager(request: request){(response, error) in
            handler((response != nil), error)
        }
    }
    
    func loginManager(email: String, password: String, handler:@escaping (_ success: Bool,_ error: String?) -> Void){
        let parameters = [String: AnyObject]()
        let urlRequest = OTMUrlParameter(parameters: parameters, withPathExtension: "/api/session", withHost: Constants.URL.APIHostUdacity)
        let request = NSMutableURLRequest(url: urlRequest)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
        taskManager(request: request){data, error in
            guard (error == nil) else{
                handler(false, error)
                return
            }
            let newData = data as! Data// subset response data!
            let range = Range(uncheckedBounds: (5, newData.count))
            let secureData = newData.subdata(in: range)
            self.convertDataWithCompletionHandler(secureData){(result, error) in
                func sendError(_ error: String) {
                    print(error)
                    handler(false, error)
                }
                
                guard (error == nil) else{
                    sendError("Could not parse data")
                    return
                }
                
                if let keyResult = result?[Constants.ResponseKeys.account] as? [String: AnyObject] {
                    Constants.User.accountKey = keyResult[Constants.ResponseKeys.key] as! String
                }else {
                    sendError("Did not receive account ID")
                }
                if let sessionResult = result?[Constants.ResponseKeys.session] as? [String: AnyObject] {
                    Constants.User.sessionID = sessionResult[Constants.ResponseKeys.id] as! String
                }else {
                    sendError("Did not receive session ID")
                }
                if ((result?["registered"]) != nil){
                    print("Logged In")
                    handler(true, nil)
                }
            }
        }
    }
    
    //get users data and see if pin posted
    func getUserData(getDataHandler: @escaping(_ success: Bool, _ error: String?) -> Void ) {
        let parameters = [String: AnyObject]()
        let urlRequest = self.OTMUrlParameter(parameters: parameters, withPathExtension: "/api/users/\(Constants.User.accountKey)", withHost: Constants.URL.APIHostUdacity)
        let request = NSMutableURLRequest(url: urlRequest)
        taskManager(request: request){data, error in
            let newData = data as! Data// subset response data!
            let range = Range(uncheckedBounds: (5, newData.count))
            let reallyNewData = newData.subdata(in: range)
            self.convertDataWithCompletionHandler(reallyNewData){(result, error) in
                func sendError(_ error: String) {
                    print(error)
                    getDataHandler(false, error)
                }
                
                guard (error == nil) else{
                    sendError("Could not parse data")
                    return
                }
                
                guard let userDictionary = result?["user"] as? [String: AnyObject] else {
                        sendError("Could not find user dictionary")
                        return
                }
                
                for (key, value) in userDictionary {
                    //set lastName, firstName
                    let newKey = key as String
                    if (newKey == "first_name"){
                        Constants.User.firstName = value as! String
                    } else if (newKey == "last_name"){
                        Constants.User.lastName = value as! String
                    }
                }
                getDataHandler(true, nil)
            }
        }
    }
    
    //create map points from student dictionary
    func createMapPoints(dictionary: [StudentInformation]) -> [MKPointAnnotation]{
        var annotations = [MKPointAnnotation]()
        for dictionary in dictionary {
            let lat = CLLocationDegrees(dictionary.latitude as Float!)
            let long = CLLocationDegrees(dictionary.longitude as Float!)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let first = (dictionary.firstName as String!)!
            let last = (dictionary.lastName as String!)!
            let mediaURL = (dictionary.mediaURL as String!)!
            
            //create annotation and attach data
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            //place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        return annotations
    }
    
    func getAnnotations(handler:@escaping (_ error: String?, _ annotations: [MKAnnotation]?) -> Void){
        let parameters = ["limit": 100,
                          "order": "-updatedAt"] as [String : Any]
        let urlRequest = self.OTMUrlParameter(parameters: parameters as [String : AnyObject], withPathExtension: "/parse/classes/StudentLocation", withHost: Constants.URL.APIHostParseNoWWW)
        let request = NSMutableURLRequest(url: urlRequest)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        self.taskManager(request: request){(data, error) in
            guard (error == nil) else{
                handler(error, nil)
                return
            }
            self.convertDataWithCompletionHandler(data as! Data){(result, error) in
                guard (error == nil) else{
                    handler("failed to parse", nil)
                    return
                }
                if let results = result?["results"] as? [[String:AnyObject]] {
                    self.Students = StudentInformation.studentsFromResults(results)
                    var annotations = [MKPointAnnotation]()
                    annotations  = self.createMapPoints(dictionary: self.Students)//changed from student
                    handler(nil, annotations)
                }
            }
        }
    }
    
    func launchAlert(message: String) -> UIAlertController {
        let alert = UIAlertController(title: "Alert", message: "\(message)", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        return alert
    }
}
