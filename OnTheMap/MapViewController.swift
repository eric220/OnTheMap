//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Macbook on 12/20/16.
//  Copyright © 2016 Macbook. All rights reserved.
//

import Foundation
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var MapView: MKMapView!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var addPinButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    //lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        MapView.delegate = self
        activityView.hidesWhenStopped = true
        activityView.stopAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.refresh()
    }
    
    //buttons
    @IBAction func addPin(_ sender: AnyObject) {
        if (Constants.User.hasPin){
            let alert = launchAlert(message: "You already have a posted pin. Would you like to overwrite it?")
            alert.addAction(UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.default, handler: { action in
                self.addPinPage()
            }))
        self.present(alert, animated: true, completion: nil)
        } else {
            self.addPinPage()
        }
    }
    
    @IBAction func refreshView(_ sender: AnyObject) {
        refresh()
    }
    
    @IBAction func logoutButton(_ sender: AnyObject) {
        activityView.startAnimating()
        Client.sharedInstance.logout(){(response, error) in
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
    
    //Views
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    //respond to tap to launch url
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                if let url = URL(string: toOpen) {
                    if (app.canOpenURL(url as URL)){
                        let controller = self.storyboard?.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                        controller.webUrl = url as NSURL?
                        present(controller, animated: true, completion: nil)
                    }else {
                        let alert = launchAlert(message: "Url cannot be opened")
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    //functions
    func addPinPage() -> Void{
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "AddPinViewController") as! AddPinViewController
        present(controller, animated: true, completion: nil)
    }
    
    func refresh(){
        let a = DispatchQueue.global(qos: .userInitiated)
        a.async {
            Client.sharedInstance.getAnnotations{(error, annotations) -> Void in
                guard (error == nil) else{
                    let alert = launchAlert(message: error!)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                if let annotations = annotations {
                    let mainQ = DispatchQueue.main
                    mainQ.async { () -> Void in
                        self.MapView.removeAnnotations(self.MapView.annotations)
                        self.MapView.addAnnotations(annotations)
                    }
                }
            }
        }
    }
}




