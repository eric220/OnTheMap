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
    @IBOutlet weak var loginButtonOutlet: UIButton!
    @IBOutlet weak var signIn: UIButton!
    @IBOutlet weak var facebookLogin: UIButton!
    
    let textFieldDelegatePassword = PasswordTextfieldDelegate()
    let client = AppDelegate().client

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.orange
        self.passwordTextField.delegate = textFieldDelegatePassword
        self.emailTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func loginButton(_ sender: AnyObject) {
        //make flash?? Make a UI control function
        setUIEnable(sender: loginButtonOutlet)
        //let email = emailTextField.text 
        //let password = passwordTextField.text //need non-redacted value
        let parameters = [String: AnyObject]()
        let urlRequest = client.OTMUrlParameter(parameters: parameters, withPathExtension: "/api/session", withHost: Constants.URL.APIHostUdacity)
        let request = NSMutableURLRequest(url: urlRequest)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(Constants.ParameterKeys.userName)\", \"password\": \"\(Constants.ParameterKeys.password)\"}}".data(using: String.Encoding.utf8)
        client.taskManager(request: request){data, response, error in
            let newData = data as! Data// subset response data!
            let range = Range(uncheckedBounds: (5, newData.count))
            let reallyNewData = newData.subdata(in: range)
            self.client.convertDataWithCompletionHandler(reallyNewData){(result, error) in
                if let keyResult = result?[Constants.ResponseKeys.account] as? [String: AnyObject] {
                    let accountKey = keyResult[Constants.ResponseKeys.key] as! String
                    Constants.User.accountKey = accountKey
                }
                if let sessionResult = result?[Constants.ResponseKeys.session] as? [String: AnyObject] {
                    let sessionID = sessionResult[Constants.ResponseKeys.id] as! String
                    Constants.User.sessionID = sessionID
                }
                if ((result?["registered"]) != nil){
                    print("Logged In")
                    let controller = self.storyboard!.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
                    self.present(controller, animated: true, completion: nil)
                }
            }
        }
    }
    @IBAction func signUpButton(_ sender: AnyObject) {
    }
    
    @IBAction func loginWithFacebook(_ sender: AnyObject) {
        print("facebookLogin")
    }
    
}

private extension LoginViewController {
    func setUIEnable(sender: UIButton){
        if (sender.currentTitle! == "Login"){
            sender.setTitle("Logging In", for: UIControlState.normal)
            UIView.animate(withDuration: 0.4, delay: 0, options: [.repeat, .autoreverse], animations: {sender.alpha = 0.2}, completion: nil)
            passwordTextField.isEnabled = false
            emailTextField.isEnabled = false
            signIn.isEnabled = false
            facebookLogin.isEnabled = false
        }
    }
    
}

