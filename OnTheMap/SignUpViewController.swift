//
//  SignUpViewController.swift
//  OnTheMap
//
//  Created by Macbook on 12/16/16.
//  Copyright © 2016 Macbook. All rights reserved.
//

import Foundation
import UIKit

class SignUpViewController: UIViewController {
    @IBOutlet weak var uiWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWebView()
    }
    
    @IBAction func cancelSignUp(_ sender: AnyObject) {
        dismiss(animated: true)
    }
    
    func loadWebView(){
        let urlString = NSURL(string:"https://auth.udacity.com/sign-up?")
        let request = URLRequest(url: urlString as! URL)
        uiWebView.loadRequest(request)
        
    }
}
