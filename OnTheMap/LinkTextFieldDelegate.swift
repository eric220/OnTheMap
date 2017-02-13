//
//  LinkTextFieldDelegate.swift
//  OnTheMap
//
//  Created by Macbook on 1/30/17.
//  Copyright © 2017 Macbook. All rights reserved.
//

import Foundation
import UIKit

class LinkTextFieldDelegate: NSObject, UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
}
