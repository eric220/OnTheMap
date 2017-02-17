//
//  Student.swift
//  OnTheMap
//
//  Created by Macbook on 1/10/17.
//  Copyright © 2017 Macbook. All rights reserved.
//

import Foundation
import UIKit


struct StudentInformation {
    // MARK: properties
    
    static var StudentsArray : [StudentInformation] = []
    
    let objectId: String?
    let uniqueKey: String?
    let firstName: String?
    let lastName: String?
    let mapString: String?
    let mediaURL: String?
    let latitude: Float?
    let longitude: Float?
    let updatedAt: String?

    //build a student
    init(dictionary: [String: AnyObject]){
        objectId = dictionary[Constants.ResponseKeys.objectId] as! String?
        uniqueKey = dictionary[Constants.ResponseKeys.uniqueKey] as! String?
        firstName = dictionary[Constants.ResponseKeys.firstName] as! String?
        lastName = dictionary[Constants.ResponseKeys.lastName] as! String?
        mapString = dictionary[Constants.ResponseKeys.mapString] as! String?
        mediaURL = dictionary[Constants.ResponseKeys.mediaUrl] as! String?
        latitude = dictionary[Constants.ResponseKeys.latitude] as! Float?
        longitude = dictionary[Constants.ResponseKeys.longitude] as! Float?
        updatedAt = dictionary[Constants.ResponseKeys.updatedAt] as! String?
    }
    
    static func studentsFromResults(_ results: [[String: Any]]) -> [StudentInformation]{
        var students = [StudentInformation]()
        var studentSet = Set<String>()
        for result in results {
            let student = self.init(dictionary: result as [String : AnyObject])
            
            //check for valid and unique student
            if (isValidStudent(student: student)){
                if (!Constants.User.hasPin){
                    if (studentSet.contains(Constants.User.lastName)){
                        Constants.User.hasPin = true
                    }
                }
                studentSet.insert(student.lastName!)
                students.append(student)
            }
        }
        return students
    }
    
    static func isValidStudent(student: StudentInformation) -> Bool{
        guard (student.firstName != nil) else{
            return false
        }
        guard (student.lastName != nil) else{
            return false
        }
        guard (student.latitude != nil) else{
            return false
        }
        guard (student.longitude != nil) else{
            return false
        }
       return true
    }
}


extension StudentInformation: Equatable {}

func ==(lhs: StudentInformation, rhs: StudentInformation) -> Bool {
    return lhs.lastName == rhs.lastName
}
