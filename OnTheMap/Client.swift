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
                        let student = Student.studentsFromResults(results)
                        handler(student as AnyObject?, nil)
                    }
                }
            }
        }
        task.resume()
    }

    class func sharedInstance() -> Client {
        struct Singleton {
            static var sharedInstance = Client()
        }
        return Singleton.sharedInstance
    }

}
