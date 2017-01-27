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
    let mediaURL: String?
    let latitude: Float?
    let longitude: Float?

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
    }
    
    static func studentsFromResults(_ results: [[String: Any]]) -> [Student]{
        var students = [Student]()
        var studentSet = Set<String>()
        for result in results {
            let student = self.init(dictionary: result as [String : AnyObject])
            print(student)
            if (doesContainStudent(name: student.lastName!, set: studentSet)){//student.lastName != nil){
                if (studentSet.contains(student.lastName!)){
                    print("contains")
                //may search for most recent post
                } else {
                    studentSet.insert(student.lastName!)
                    students.append(student)
                }
            }
        }
        return students
    }
    
    static func doesContainStudent(name: String, set: Set<String>) -> Bool{
        if (set.contains(name)){
            return false
        } else {
        return true
        }
    }
}

extension Student: Equatable {}

func ==(lhs: Student, rhs: Student) -> Bool {
    return lhs.lastName == rhs.lastName
}
