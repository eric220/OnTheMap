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
    
    var Students = [StudentInformation]()
    
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
    func taskManager(request: NSMutableURLRequest, handler:@escaping (_ data: AnyObject?, _ success: Bool, _ error: NSError?) -> Void) {
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            func printError(err: String){
                print(err)
                handler(nil, false, error as NSError?)
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                handler(nil, false, nil )
                return
            }
            
            if error != nil { // Handle error…
                printError(err: "returned an error")
                return
            }
            
            if let data = data {
                handler(data as AnyObject?, true, nil)
                return
            }
        }
        task.resume()
    } 

    //get users data and see if pin posted
    func getUserData() {
        let parameters = [String: AnyObject]()
        let urlRequest = self.OTMUrlParameter(parameters: parameters, withPathExtension: "/api/users/\(Constants.User.accountKey)", withHost: Constants.URL.APIHostUdacity)
        let request = NSMutableURLRequest(url: urlRequest)
        taskManager(request: request){data, response, error in
            let newData = data as! Data// subset response data!
            let range = Range(uncheckedBounds: (5, newData.count))
            let reallyNewData = newData.subdata(in: range)
            self.convertDataWithCompletionHandler(reallyNewData){(result, error) in
                if (error != nil){
                    print("conversion failed")
                } else {
                    guard let userDictionary = result?["user"] as? [String: AnyObject] else {
                        print("cant")
                        return
                    }
                    for (key, value) in userDictionary {
                        //set lastName, firstName, has pin
                        let newKey = key as String
                        if (newKey == "key"){
                            print(value)
                        }
                    }
                }
            }
        }
    }

    //post users pin
    func addStudentPin(){
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.httpMethod = "POST"
        
        //check for pin placed and leave PUT here
        if (UserDefaults.standard.bool(forKey: "HasUserObjectID")){
            let userID = UserDefaults.standard.value(forKey: "UserObjectID")
            let parameters = [String:AnyObject]()
            let urlRequest = self.OTMUrlParameter(parameters: parameters, withPathExtension: "/parse/classes/StudentLocation/\(userID!)", withHost: Constants.URL.APIHostParseNoWWW)
            let request = NSMutableURLRequest(url: urlRequest)
            request.httpMethod = "PUT"
        } 
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(Constants.User.accountKey)\", \"firstName\": \"\(Constants.User.firstName)\", \"lastName\": \"Criteser\",\"mapString\": \"Gulf Shores, AL\", \"mediaURL\": \"https://udacity.com\",\"latitude\": \(Constants.User.latitude), \"longitude\": \(Constants.User.longitude)}".data(using: String.Encoding.utf8)
        taskManager(request: request){(data, response, error) in
            self.convertDataWithCompletionHandler(data as! Data){result, error in
                if let result = result?[Constants.ResponseKeys.objectId]! {
                    UserDefaults.standard.set(result, forKey: "UserObjectID")
                }
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
    
    func getAnnotations(handler:@escaping (_ annotations: [MKAnnotation]) -> Void){
        let q = DispatchQueue.global(qos: .userInteractive)
        q.async { () -> Void in
            let parameters = ["limit": 10 as AnyObject]
            let urlRequest = self.OTMUrlParameter(parameters: parameters, withPathExtension: "/parse/classes/StudentLocation", withHost: Constants.URL.APIHostParseNoWWW)
            let request = NSMutableURLRequest(url: urlRequest)
            request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
            self.taskManager(request: request){(data, response, error) in
                self.convertDataWithCompletionHandler(data as! Data){(result, error) in
                    if (error != nil){
                        print("conversion failed")
                        print(error)
                    } else {
                        if let results = result?["results"] as? [[String:AnyObject]] {
                            let student = StudentInformation.studentsFromResults(results)
                            self.Students = student
                            var annotations = [MKPointAnnotation]()
                            annotations  = self.createMapPoints(dictionary: student)
                            handler(annotations)
                        }
                    }
                }
            }
        }
    }
    
    class func sharedInstance() -> Client {
        struct Singleton {
            static var sharedInstance = Client()
        }
        return Singleton.sharedInstance
    }

}
