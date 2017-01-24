//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Macbook on 12/20/16.
//  Copyright © 2016 Macbook. All rights reserved.
//

import Foundation
import UIKit

class ListViewController: UITableViewController {
    let client = Client.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return client.Students.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //get and populate cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let student = client.Students[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = "\(student.lastName!), \(student.firstName!)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        //print(client.Students[(indexPath).row])
        let app = UIApplication.shared
        print(indexPath)
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
}
