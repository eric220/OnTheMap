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

    
    //lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.orange
        self.passwordTextField.delegate = self
        self.emailTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        subscribeToKeyboardNotifications()
        setUIEnable()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeToKeyboardNotifications()
    }
    
    //Views
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    //buttons
    @IBAction func loginButton(_ sender: AnyObject) {
        //make flash?? Make a UI control function
        setUIDisable(sender: loginButtonOutlet)
        
        //let email = emailTextField.text
        //let password = passwordTextField.text //need non-redacted value
        
        client.loginManager(email: /*email*/Constants.ParameterKeys.userName, password: /*password*/Constants.ParameterKeys.password){(response, error) in
            if (!response){
                let alert = self.client.launchAlert(message: "Check Network Connection")
                self.present(alert, animated: true, completion: nil)
                self.setUIEnable()
            } else if (error!){
                let alert = self.client.launchAlert(message: "Check User Email And Password")
                self.present(alert, animated: true, completion: nil)
                self.setUIEnable()
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
    
    //MARK: keyboard notifications
    func subscribeToKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat{
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func keyboardWillShow(notification: NSNotification){
        if passwordTextField.isFirstResponder{
            print(getKeyboardHeight(notification: notification) * -1)
            self.view.frame.origin.y = -50//getKeyboardHeight(notification: notification) * -1
        }
    }
    
    func keyboardWillHide(notification: NSNotification){
        view.frame.origin.y = 0
    }

    
}

private extension LoginViewController {
    func setUIDisable(sender: UIButton){
        if (sender.currentTitle! == "Login"){
            sender.setTitle("Logging In", for: UIControlState.normal)
            //UIView.animate(withDuration: 0.4, delay: 0, options: [.repeat, .autoreverse], animations: {sender.alpha = 0.2}, completion: nil)
            passwordTextField.isEnabled = false
            emailTextField.isEnabled = false
            signIn.isEnabled = false
            facebookLogin.isEnabled = false
        }
    }
    
    func setUIEnable(){
        UIView.setAnimationsEnabled(false)
        loginButtonOutlet.setTitle("Login", for: UIControlState.normal)
        loginButtonOutlet.isEnabled = true
        passwordTextField.isEnabled = true
        emailTextField.isEnabled = true
        signIn.isEnabled = true
        facebookLogin.isEnabled = true
    }
    
}

