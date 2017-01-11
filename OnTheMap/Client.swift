//
//  Client.swift
//  OnTheMap
//
//  Created by Macbook on 12/16/16.
//  Copyright © 2016 Macbook. All rights reserved.
//

import Foundation


class Client: NSObject {
    //build url by components
    
    var Students = [Student]()
    
    func OTMUrlParameter(parameters: [String:AnyObject], withPathExtension: String? = nil, withHost: String?) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.URL.APIScheme
        if (withHost == "Udacity"){
            components.host = Constants.URL.APIHostUdacity
        } else {
            components.host = Constants.URL.APIHostParse
        }
        components.path = withPathExtension!
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            print(queryItem)
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    //return json data
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
    
    //get data
    func getDataFromParse(handler:@escaping (_ response: AnyObject?, _ error: NSError?) -> Void){
        //let parameters = [String: AnyObject]()
        //let url = self.OTMUrlParameter(parameters: parameters, withPathExtension: "/parse/classes", withHost: "Parse")
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=2")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error...
                print("failed to get data from parse")
                return
            }
            self.convertDataWithCompletionHandler(data!){(result, error) in
                if (error != nil){
                    print("conversion failed")
                } else {
                    if let results = result?["results"] as? [[String:AnyObject]] {
                        self.Students = Student.studentsFromResults(results)
                        handler(results as AnyObject?, nil as NSError!)
                    }
                }
            }
        }
        task.resume()
    }
    
    func hardCodedLocationData() -> [[String : AnyObject]] {
        return  [
            [
                "createdAt" : "2015-02-24T22:27:14.456Z" as AnyObject,
                "firstName" : "Jessica" as AnyObject,
                "lastName" : "Uelmen" as AnyObject,
                "latitude" : 28.1461248 as AnyObject,
                "longitude" : -82.75676799999999 as AnyObject,
                "mapString" : "Tarpon Springs, FL" as AnyObject,
                "mediaURL" : "http://www.linkedin.com/in/jessicauelmen/en" as AnyObject,
                "objectId" : "kj18GEaWD8" as AnyObject,
                "uniqueKey" : 872458750 as AnyObject,
                "updatedAt" : "2015-03-09T22:07:09.593Z" as AnyObject
            ], [
                "createdAt" : "2015-02-24T22:35:30.639Z" as AnyObject,
                "firstName" : "Gabrielle" as AnyObject,
                "lastName" : "Miller-Messner" as AnyObject,
                "latitude" : 35.1740471 as AnyObject,
                "longitude" : -79.3922539 as AnyObject,
                "mapString" : "Southern Pines, NC" as AnyObject,
                "mediaURL" : "http://www.linkedin.com/pub/gabrielle-miller-messner/11/557/60/en" as AnyObject,
                "objectId" : "8ZEuHF5uX8" as AnyObject,
                "uniqueKey" : 225629859 as AnyObject,
                "updatedAt" : "2015-03-11T03:23:49.582Z" as AnyObject
            ], [
                "createdAt" : "2015-02-24T22:30:54.442Z" as AnyObject,
                "firstName" : "Jason" as AnyObject,
                "lastName" : "Schatz" as AnyObject,
                "latitude" : 37.7617 as AnyObject,
                "longitude" : -122.4216 as AnyObject,
                "mapString" : "18th and Valencia, San Francisco, CA" as AnyObject,
                "mediaURL" : "http://en.wikipedia.org/wiki/Swift_%28programming_language%29" as AnyObject,
                "objectId" : "hiz0vOTmrL" as AnyObject,
                "uniqueKey" : 236275853 as AnyObject,
                "updatedAt" : "2015-03-10T17:20:31.828Z" as AnyObject
            ]
        ]
    }    

    
    class func sharedInstance() -> Client {
        struct Singleton {
            static var sharedInstance = Client()
        }
        return Singleton.sharedInstance
    }

}
