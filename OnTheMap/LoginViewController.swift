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
        self.passwordTextField.delegate = self
        self.emailTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUIEnable()
    }

    @IBAction func loginButton(_ sender: AnyObject) {
        //make flash?? Make a UI control function
        setUIDisable(sender: loginButtonOutlet)
        
        //let email = emailTextField.text 
        //let password = passwordTextField.text //need non-redacted value
        
        client.loginManager(email: Constants.ParameterKeys.userName, password: Constants.ParameterKeys.password){(response, error) in
            if (!response){
                let alert = self.client.launchAlert(message: "Check Network Connection")
                self.present(alert, animated: true, completion: nil)
            } else if (error!){
                let alert = self.client.launchAlert(message: "Check User Email And Password")
                self.present(alert, animated: true, completion: nil)
            } else {
                let controller = self.storyboard!.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
                self.present(controller, animated: true, completion: nil)
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
    func setUIDisable(sender: UIButton){
        if (sender.currentTitle! == "Login"){
            sender.setTitle("Logging In", for: UIControlState.normal)
            UIView.animate(withDuration: 0.4, delay: 0, options: [.repeat, .autoreverse], animations: {sender.alpha = 0.2}, completion: nil)
            passwordTextField.isEnabled = false
            emailTextField.isEnabled = false
            signIn.isEnabled = false
            facebookLogin.isEnabled = false
        }
    }
    
    func setUIEnable(){
        loginButtonOutlet.setTitle("Login", for: UIControlState.normal)
        loginButtonOutlet.isEnabled = true
        passwordTextField.isEnabled = true
        emailTextField.isEnabled = true
        signIn.isEnabled = true
        facebookLogin.isEnabled = true
    }
    
}

