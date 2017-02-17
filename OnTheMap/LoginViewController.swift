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
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var logoImage: UIImageView!
    
    let textFieldDelegatePassword = PasswordTextfieldDelegate()

    
    //lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.orange
        self.passwordTextField.delegate = self
        self.emailTextField.delegate = self
        self.logoImage.layer.cornerRadius = 8
    }
    
    override func viewWillAppear(_ animated: Bool) {
        subscribeToKeyboardNotifications()
        setUIEnable()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeToKeyboardNotifications()
    }

    //buttons
    @IBAction func loginButton(_ sender: AnyObject) {
        //make flash?? Make a UI control function
        setUIDisable(sender: loginButtonOutlet)
        
        //let email = emailTextField.text
        //let password = passwordTextField.text //need non-redacted value

        Client.sharedInstance.authenticateWithUserData(email: Constants.ParameterKeys.userName, password: Constants.ParameterKeys.password){(success, error) in
            performUIUpdatesOnMain {
                if (error != nil){
                    let alert = UIAlertController(title: "Alert", message: "\(error!)", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: {action in
                        self.setUIEnable()
                    }))
                    self.present(alert, animated: true, completion:nil)
                } else {
                    let controller = self.storyboard!.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
                    self.present(controller, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func signUpButton(_ sender: AnyObject) {
    }
    
    @IBAction func loginWithFacebook(_ sender: AnyObject) {
        let alert =  launchAlert(message: "Facebook login not enabled at this time")
        self.present(alert, animated: true, completion:  nil)
    }
    
    //Views
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //functions
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
            self.view.frame.origin.y = (getKeyboardHeight(notification: notification) * -1.3/2)
    }
    
    func keyboardWillHide(notification: NSNotification){
        view.frame.origin.y = 0
    }

    
}

private extension LoginViewController {
    func setUIDisable(sender: UIButton){
        if (sender.currentTitle! == "Login"){
            self.loginLabel.text = "Logging In"
            UIView.animate(withDuration: 0.4, delay: 0, options: [.repeat, .autoreverse], animations: {self.loginLabel.alpha = 0.2}, completion: nil)
            passwordTextField.isEnabled = false
            emailTextField.isEnabled = false
            signIn.isEnabled = false
            facebookLogin.isEnabled = false
            sender.isEnabled = false
        }
    }
    
    func setUIEnable(){ 
        self.loginLabel.alpha = 1
        self.loginLabel.text = "Login to Udacity"
        loginButtonOutlet.isEnabled = true
        passwordTextField.isEnabled = true
        emailTextField.isEnabled = true
        signIn.isEnabled = true
        facebookLogin.isEnabled = true
    }
    
}

