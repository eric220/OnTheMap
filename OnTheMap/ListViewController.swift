//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Macbook on 12/20/16.
//  Copyright © 2016 Macbook. All rights reserved.
//

import Foundation
import UIKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let client = AppDelegate().client
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //tableview functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return client.Students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //get and populate cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let student = client.Students[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = "\(student.lastName!), \(student.firstName!)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { 
        let app = UIApplication.shared
        let student = client.Students[(indexPath).row]
        if let url = NSURL(string: student.mediaURL!) {
            if (app.canOpenURL(url as URL)){
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            controller.webUrl = url as NSURL?
            present(controller, animated: true, completion: nil)
            }
        } else {
            print("cannot open URL")
        }
    }
    
    //buttons
    @IBAction func refreshButton(_ sender: AnyObject) {
        print("refresh")
        client.getAnnotations{(annotations) -> Void in
            let mainQ = DispatchQueue.main
            mainQ.async { () -> Void in
                
            }
        }
    }
    
    @IBAction func addPinButton(_ sender: AnyObject) {
        print("addPin")
        client.getPublicData()
        if (UserDefaults.standard.bool(forKey: "HasUserObjectID")){
            let alert = client.launchAlert(message: "You already have a posted pin. Would you like to overwrite it?")
            alert.addAction(UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.default, handler: { action in
                self.addPinPage()
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.addPinPage()
        }
    }
    
    @IBAction func logoutButton(_ sender: AnyObject) {
        client.logout(){(response, error) in
            
        }
    }
    
    //helpers
    func addPinPage() -> Void{
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "AddPinViewController") as! AddPinViewController
        present(controller, animated: true, completion: nil)
    }

    
}
