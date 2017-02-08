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
    
    let client = AppDelegate().client
    
    @IBOutlet weak var MapView: MKMapView!
    
    //lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        MapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.refresh()
    }
    
    //buttons
    @IBAction func addPin(_ sender: AnyObject) {
        //client.getUserData()
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
    
    @IBAction func refreshView(_ sender: AnyObject) {
        refresh()
    }
    
    @IBAction func logoutButton(_ sender: AnyObject) {
        client.logout(){(response, error) in
            var alert: UIAlertController? = nil
            if (error != nil){
                alert = self.client.launchAlert(message: "Error Logging Out, Please Try Again")
                self.present(alert!, animated: true, completion: nil)
            } else if (!response){
                alert = self.client.launchAlert(message: "Network Difficulty, Check Network Connection")
                self.present(alert!, animated: true, completion: nil)
            } else {
                print("logout complete")
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
                let url = URL(string: toOpen)!
                //print(url)
                if (app.canOpenURL(url as URL)){
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                    controller.webUrl = url as NSURL?
                    present(controller, animated: true, completion: nil)
                }else {
                    print("cannot open url")
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
            self.client.getAnnotations{(annotations) -> Void in
                let mainQ = DispatchQueue.main
                mainQ.async { () -> Void in
                    self.MapView.removeAnnotations(self.MapView.annotations)
                    self.MapView.addAnnotations(annotations)
                }
            }
        }
    }
}




