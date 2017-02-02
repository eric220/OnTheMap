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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MapView.delegate = self
        self.refresh()
    }
    
    // MARK: - MKMapViewDelegate
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    //make pins for mapview
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
    @IBAction func addPin(_ sender: AnyObject) {
        client.getPublicData()
        if (UserDefaults.standard.bool(forKey: "HasUserObjectID")){
            let alert = UIAlertController(title: "Alert", message: "You already have a posted pin. Would you like to overwrite it?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
            alert.addAction(UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.default, handler: { action in
                self.addPinPage()
            }))
        self.present(alert, animated: true, completion: nil)
        } else {
            self.addPinPage()
        }
    }
    
    func addPinPage() -> Void{
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "AddPinViewController") as! AddPinViewController
        present(controller, animated: true, completion: nil)
    }
    
    func refresh(){
        client.getAnnotations{(annotations) -> Void in
            let mainQ = DispatchQueue.main
            mainQ.async { () -> Void in
                self.MapView.addAnnotations(annotations)
            }
        }
    }
    @IBAction func refreshView(_ sender: AnyObject) {
        refresh()
    }
}




