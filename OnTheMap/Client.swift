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
    
    var Students = [Student]()
    
    
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
    func getAnnotations(handler:@escaping (_ annotations: [MKAnnotation]) -> Void){
        let q = DispatchQueue.global(qos: .userInteractive)
        q.async { () -> Void in
            let parameters = ["limit": 100 as AnyObject]
            //let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=100")!)
            let urlRequest = self.OTMUrlParameter(parameters: parameters, withPathExtension: "/parse/classes/StudentLocation", withHost: Constants.URL.APIHostParseNoWWW)
            print(urlRequest)
            let request = NSMutableURLRequest(url: urlRequest)
            request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
            let session = URLSession.shared
            let task = session.dataTask(with: request as URLRequest) { data, response, error in
                if (error != nil){
                    print(error)
                }
                
                guard (error == nil) else {
                    print("There was an error with your request: \(error)")
                    return
                }
                
                ///GUARD: Did we get a successful 2XX response?
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                    print("Your request returned a status code other than 2xx!")
                    return
                }
                
                /* GUARD: Was there any data returned? */
                guard let data = data else {
                    print("No data was returned by the request!")
                    return
                }
                
                self.convertDataWithCompletionHandler(data){(result, error) in
                    if (error != nil){
                        print("conversion failed")
                        print(error)
                    } else {
                        if let results = result?["results"] as? [[String:AnyObject]] {
                            let student = Student.studentsFromResults(results)
                            self.Students = student
                            var annotations = [MKPointAnnotation]()
                            annotations  = self.createMapPoints(dictionary: student)
                            handler(annotations)
                        }
                    }
                }
            }
            task.resume()
        }
    }
    func getPublicData() {
        let parameters = [String: AnyObject]()
        let urlRequest = self.OTMUrlParameter(parameters: parameters, withPathExtension: "/api/users/\(Constants.User.accountKey)", withHost: Constants.URL.APIHostUdacity)
        let request = NSMutableURLRequest(url: urlRequest)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error...
                print("failed to get data from parse")
                return
            }
            let range = Range(uncheckedBounds: (5, data!.count))
            let newData = data?.subdata(in: range) /* subset response data! */
            self.convertDataWithCompletionHandler(newData!){(result, error) in
                if (error != nil){
                    print("conversion failed")
                } else {
                    print("result")
                }
            }
        }
        task.resume()
    }

    
    func createMapPoints(dictionary: [Student]) -> [MKPointAnnotation]{
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
    
    func addStudentPin(){
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.httpMethod = "POST"
        
        //check for pin placed
        if (UserDefaults.standard.bool(forKey: "HasUserObjectID")){
            let userID = UserDefaults.standard.value(forKey: "UserObjectID")
            let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation/\(userID!)")!)
            request.httpMethod = "PUT"
        } 
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(Constants.User.accountKey)\", \"firstName\": \"\(Constants.User.firstName)\", \"lastName\": \"Criteser\",\"mapString\": \"Gulf Shores, AL\", \"mediaURL\": \"https://udacity.com\",\"latitude\": \(Constants.User.latitude), \"longitude\": \(Constants.User.longitude)}".data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error…
                print(error)
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                return
            }
            self.convertDataWithCompletionHandler(data!){(result, error) in
                if (error != nil){
                    print(error)
                } else {
                    if let result = result?[Constants.ResponseKeys.objectId]! {
                        UserDefaults.standard.set(result, forKey: "UserObjectID")
                    }
                }
            }
            UserDefaults.standard.set(true, forKey: "HasUserObjectID")
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
