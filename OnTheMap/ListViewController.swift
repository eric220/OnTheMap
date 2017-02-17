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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    //lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        activityView.hidesWhenStopped = true
        activityView.stopAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refresh()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //buttons
    @IBAction func refreshButton(_ sender: AnyObject) {
        refresh()
    }
    
    @IBAction func addPinButton(_ sender: AnyObject) {
        if (UserDefaults.standard.bool(forKey: "HasUserObjectID")){
            let alert = launchAlert(message: "You already have a posted pin. Would you like to overwrite it?")
            alert.addAction(UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.default, handler: { action in
                self.addPinPage()
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.addPinPage()
        }
    }
    
    @IBAction func logoutButton(_ sender: AnyObject) {
        activityView.startAnimating()
        let b = DispatchQueue.global(qos: .userInitiated)
        b.async {
            Client.sharedInstance.logout(){(response, error) in
                let mainQ = DispatchQueue.main
                mainQ.async {
                    var alert: UIAlertController? = nil
                    if (error != nil){
                        alert = launchAlert(message: "Error Logging Out, Please Try Again")
                        self.present(alert!, animated: true, completion: nil)
                    } else if (!response){
                        alert = launchAlert(message: "Network Difficulty, Check Network Connection")
                        self.present(alert!, animated: true, completion: nil)
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    //Views
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentInformation.StudentsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //get and populate cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let student = StudentInformation.StudentsArray[(indexPath).row]
        cell.textLabel?.text = "\(student.lastName!), \(student.firstName!)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let app = UIApplication.shared
        let student = StudentInformation.StudentsArray[(indexPath).row]
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

    
    //functions
    func addPinPage() -> Void{
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "AddPinViewController") as! AddPinViewController
        present(controller, animated: true, completion: nil)
    }
    
    func refresh(){
        let b = DispatchQueue.global(qos: .userInitiated)
        b.async {
            Client.sharedInstance.getAnnotations{(error, annotations) -> Void in
                guard (error == nil) else{
                    let alert = launchAlert(message: error!)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                if annotations != nil {
                    DispatchQueue.main.async{
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }

    
}
