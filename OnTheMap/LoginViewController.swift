//
//  ViewController.swift
//  OnTheMap
//
//  Created by Macbook on 12/15/16.
//  Copyright © 2016 Macbook. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    let textFieldDelegatePassword = PasswordTextfieldDelegate()
    let client = Client.sharedInstance()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.orange
        self.passwordTextField.delegate = textFieldDelegatePassword
        self.emailTextField.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func loginButton(_ sender: AnyObject) {
        let parameters = [String: AnyObject]()
        let urlRequest = client.OTMUrlParameter(parameters: parameters, withPathExtension: "/api/session", withHost: "Udacity")
        let request = NSMutableURLRequest(url: urlRequest)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(Constants.ParameterKeys.userName)\", \"password\": \"\(Constants.ParameterKeys.password)\"}}".data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error…
                print(error)
                return
            }
            let range = Range(uncheckedBounds: (5, data!.count))
            let newData = data?.subdata(in: range) /* subset response data! */
           // self.client.convertDataWithCompletionHandler(<#T##data: Data##Data#>, completionHandlerForConvertData: <#T##(AnyObject?, NSError?) -> Void#>)
            let parsedResult: AnyObject
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as AnyObject
                print(parsedResult)
            } catch {
                let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
                print(userInfo)
                return
            }
            
            if let keyResult = parsedResult[Constants.ResponseKeys.account] as? [String: AnyObject] {
                let accountKey = keyResult[Constants.ResponseKeys.key] as! String
                Constants.User.accountKey = accountKey
                print(Constants.User.accountKey)
            }
            if let sessionResult = parsedResult[Constants.ResponseKeys.session] as? [String: AnyObject] {
                let sessionID = sessionResult[Constants.ResponseKeys.id] as! String
                Constants.User.sessionID = sessionID
                print(Constants.User.sessionID)
            }
            
            if ((parsedResult["registered"]) != nil){
                let controller = self.storyboard!.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
                self.present(controller, animated: true, completion: nil)
            }

        }
        task.resume()
    }
    @IBAction func signUpButton(_ sender: AnyObject) {
    }
    
    @IBAction func loginWithFacebook(_ sender: AnyObject) {
        print("facebookLogin")
    }
    
}

