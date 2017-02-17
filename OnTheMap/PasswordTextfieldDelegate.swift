//
//  File.swift
//  OnTheMap
//
//  Created by Macbook on 12/16/16.
//  Copyright © 2016 Macbook. All rights reserved.
//

import Foundation
import UIKit

class PasswordTextfieldDelegate: NSObject, UITextFieldDelegate {
    
    var password = ""
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = textField.text! as String
        //let passwordText = String(describing: newText.characters.last)
        //passwordTextStore(c: (passwordText))
        //var printText = ""
        //for c: Character in newText.characters {
          //  printText.append("\u{25CF}")
        //}
        textField.text = newText
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func passwordTextStore(c: String){
        password += c
    }
    
}
