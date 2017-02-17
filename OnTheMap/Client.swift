//
//  Client.swift
//  OnTheMap
//
//  Created by Macbook on 12/16/16.
//  Copyright © 2016 Macbook. All rights reserved.
//

import Foundation
import MapKit


class Client: NSObject, MKMapViewDelegate {
    
    //build url by components
    func OTMUrlParameter(parameters: [String:AnyObject], withPathExtension: String? = nil, withHost: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.URL.APIScheme
        components.host = withHost!
        components.path = withPathExtension!
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    //serialize json data
    func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    //task manager for tasks
    func taskManager(request: NSMutableURLRequest, handler:@escaping (_ data: AnyObject?, _ error: String?) -> Void) {
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            func sendError(_ error: String) {
                handler(nil, error)
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request, check network connection")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx! Check credentials")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            handler(data as AnyObject?,nil)
        }
        task.resume()
    }
    
    func authenticateWithUserData(email: String, password: String, loginWithDataHandler: @escaping(_ success: Bool, _ error: String?) -> Void ){
        self.loginManager(email: email, password: password){(success, error)in
            if (success){
                self.getUserData(){(success, error) in
                    loginWithDataHandler(success, error)
                }
            }else {
                loginWithDataHandler(success, error)
            }
        }
        
    }

    //post users pin
    func addStudentPin(lat: Double, long: Double, loc: String, media: String?, handler:@escaping (_ success: Bool) -> Void){
        var request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)

        if (!UserDefaults.standard.bool(forKey: "HasUserObjectID")){
            request.httpMethod = "POST"
        } else {
            let userID = UserDefaults.standard.value(forKey: "UserObjectID")
            let parameters = [String:AnyObject]()
            let urlRequest = self.OTMUrlParameter(parameters: parameters, withPathExtension: "/parse/classes/StudentLocation/\(userID!)", withHost: Constants.URL.APIHostParseNoWWW)
            request = NSMutableURLRequest(url: urlRequest)
            request.httpMethod = "PUT"
        }
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"\(Constants.ResponseKeys.uniqueKey)\": \"\(Constants.User.accountKey)\", \"\(Constants.ResponseKeys.firstName)\": \"\(Constants.User.firstName)\", \"\(Constants.ResponseKeys.lastName)\": \"\(Constants.User.lastName)\",\"\(Constants.ResponseKeys.mapString)\": \"\(loc)\", \"\(Constants.ResponseKeys.mediaUrl)\": \"\(media!)\", \"\(Constants.ResponseKeys.latitude)\": \(lat), \"\(Constants.ResponseKeys.longitude)\": \(long)}".data(using: String.Encoding.utf8)
        
        taskManager(request: request){(data, error) in //\"https://udacity.com\" \"\(media!)\"
            guard error == nil else{
                    handler(false)
                    return
            }
            self.convertDataWithCompletionHandler(data as! Data){result, error in
                guard (error == nil) else{
                    handler(false)
                    return
                }
                
                if let result = result?[Constants.ResponseKeys.objectId]! {
                    UserDefaults.standard.set(result, forKey: "UserObjectID")
                    UserDefaults.standard.set(true, forKey:"HasUserObjectID")
                    handler(true)
                }
                handler(true)
            }
        }
    }
    
    static var sharedInstance = Client()
}
