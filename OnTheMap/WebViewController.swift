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
    
    //lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWebView()
    }
    
    //buttons
    @IBAction func cancelSignUp(_ sender: AnyObject) {
        dismiss(animated: true)
    }
    
    //functions
    func loadWebView(){
        if let url = webUrl {
            let request = URLRequest(url: url as URL)
            uiWebView.loadRequest(request)
        }else {
            let alert = launchAlert(message: "Cannot Open URL")
            self.present(alert, animated: true, completion: nil)
        }
    }
}
