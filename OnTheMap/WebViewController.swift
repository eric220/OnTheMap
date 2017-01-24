//
//  SignUpViewController.swift
//  OnTheMap
//
//  Created by Macbook on 12/16/16.
//  Copyright © 2016 Macbook. All rights reserved.
//

import Foundation
import UIKit

class WebViewController: UIViewController {
    @IBOutlet weak var uiWebView: UIWebView!
    
    var webUrl: NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWebView()
    }
    
    @IBAction func cancelSignUp(_ sender: AnyObject) {
        dismiss(animated: true)
    }
    
    func loadWebView(/*url: NSURL? = NSURL(string:"https://auth.udacity.com/sign-up?" )*/){
        if let url = webUrl {
            let request = URLRequest(url: url as URL)
            uiWebView.loadRequest(request)
        } else {
            let url = NSURL(string:"https://auth.udacity.com/sign-up?")
            let request = URLRequest(url: url as! URL)
            uiWebView.loadRequest(request)
        }
        
    }
}
