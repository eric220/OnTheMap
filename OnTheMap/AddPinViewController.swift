//
//  AddPinViewController.swift
//  OnTheMap
//
//  Created by Macbook on 1/24/17.
//  Copyright © 2017 Macbook. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class AddPinViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addPin: UIButton!
    
    var userLocation: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextField.delegate = self
        
    }
    
    @IBAction func goBack(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldDidReturn(locationTextField)
        return true
    }
    
    func textFieldDidReturn(_ textField: UITextField) {
        self.mapView.removeAnnotations(mapView.annotations)
        userLocation = (locationTextField.text)
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(userLocation!, completionHandler: {(placemarks, error)->Void in
            if let placemark = placemarks?[0] as CLPlacemark? {
                self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
                let location = self.findCenterOnMap(placemark: placemark)
                self.mapView.setCenter(location, animated: true)
                //self.view.alpha = 1.0
                //self.mapView.isHidden = false
                self.mapView.isZoomEnabled = true
                print(location.latitude)
                print(location.longitude)
                self.addPin.setTitle("Submit?", for: .normal)
                self.locationTextField.text = "Not Correct? Change Location."
                
            }
        })
        textField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        locationTextField.text = ""
    }
    
   func findCenterOnMap(placemark: CLPlacemark) -> CLLocationCoordinate2D {
        let location = CLLocationCoordinate2D.init(latitude: (placemark.location?.coordinate.latitude)!, longitude: (placemark.location?.coordinate.longitude)! )
        return location
    }
    
    @ IBAction func getUserLocation(){
        
        print("great")
    }
}
