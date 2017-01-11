//
//  Student.swift
//  OnTheMap
//
//  Created by Macbook on 1/10/17.
//  Copyright © 2017 Macbook. All rights reserved.
//

import Foundation
import UIKit


struct Student{
    // MARK: properties
    let objectId: String?
    let uniqueKey: String?
    let firstName: String?
    let lastName: String?
    let mapString: String?
    let mediaUrl: String?
    let latitude: Float?
    let longitude: Float?
    //let createdAt: Date?
    //let updatedAt: Date?
    //let ACL: Bool?


    //build a student
    init(dictionary: [String: AnyObject]){
        objectId = dictionary[Constants.ResponseKeys.objectId] as! String?
        uniqueKey = dictionary[Constants.ResponseKeys.uniqueKey] as! String?
        firstName = dictionary[Constants.ResponseKeys.uniqueKey] as! String?
        lastName = dictionary[Constants.ResponseKeys.uniqueKey] as! String?
        mapString = dictionary[Constants.ResponseKeys.uniqueKey] as! String?
        mediaUrl = dictionary[Constants.ResponseKeys.uniqueKey] as! String?
        latitude = dictionary[Constants.ResponseKeys.uniqueKey] as! Float?
        longitude = dictionary[Constants.ResponseKeys.uniqueKey] as! Float?
        //createdAt = dictionary[Constants.ResponseKeys.uniqueKey] as! Date?
        //updatedAt = dictionary[Constants.ResponseKeys.uniqueKey] as! Date?
        //ACL = dictionary[Constants.ResponseKeys.uniqueKey] as! Bool?

    }
    
    static func studentFromResults(_ results: [[String: Any]]) -> [Student]{
        var students = [Student]()
        for result in results {
            students.append(Student(dictionary: result as [String : AnyObject]))
        }
        return students
    }
}

extension Student: Equatable {}

func ==(lhs: Student, rhs: Student) -> Bool {
    return lhs.lastName == rhs.lastName
}
