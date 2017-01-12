//
//  Student.swift
//  OnTheMap
//
//  Created by Macbook on 1/10/17.
//  Copyright © 2017 Macbook. All rights reserved.
//

import Foundation
import UIKit


struct Student {
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
        print("making student")
        objectId = dictionary[Constants.ResponseKeys.objectId] as! String?
        uniqueKey = dictionary[Constants.ResponseKeys.uniqueKey] as! String?
        firstName = dictionary[Constants.ResponseKeys.firstName] as! String?
        lastName = dictionary[Constants.ResponseKeys.lastName] as! String?
        mapString = dictionary[Constants.ResponseKeys.mapString] as! String?
        mediaUrl = dictionary[Constants.ResponseKeys.mediaUrl] as! String?
        latitude = dictionary[Constants.ResponseKeys.latitude] as! Float?
        longitude = dictionary[Constants.ResponseKeys.longitude] as! Float?
        //createdAt = dictionary[Constants.ResponseKeys.uniqueKey] as! Date?
        //updatedAt = dictionary[Constants.ResponseKeys.uniqueKey] as! Date?
        //ACL = dictionary[Constants.ResponseKeys.uniqueKey] as! Bool?

    }
    
    static func studentsFromResults(_ results: [[String: Any]]) -> [Student]{
        var students = [Student]()
        for result in results {
            let student = self.init(dictionary: result as [String : AnyObject])
            students.append(student)
        }
        return students
    }
}

extension Student: Equatable {}

func ==(lhs: Student, rhs: Student) -> Bool {
    return lhs.lastName == rhs.lastName
}
