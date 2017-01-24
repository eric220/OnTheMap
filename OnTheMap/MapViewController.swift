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
    
    let client = Client.sharedInstance()
    
    @IBOutlet weak var MapView: MKMapView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MapView.delegate = self
        
        //get data and insert to map
        client.getAnnotations{(annotations) -> Void in
            let mainQ = DispatchQueue.main
            mainQ.async { () -> Void in
                self.MapView.addAnnotations(annotations)
            }
        }
    }
    
    // MARK: - MKMapViewDelegate
    
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
    }
    
}
    
    
    

