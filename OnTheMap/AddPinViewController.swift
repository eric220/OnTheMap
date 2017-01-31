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
    @IBOutlet weak var linkTextField: UITextField!
    
    var userLocationString: String?
    var userLocationPoint: CLPlacemark?
    let client = AppDelegate().client
    
    //set delegate
    let linkTextfieldDelegate = LinkTextFieldDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        linkTextField.isEnabled = false
        linkTextField.delegate = linkTextfieldDelegate
        locationTextField.delegate = self
        locationTextField.becomeFirstResponder()
    }
    
    //button actions
    @IBAction func goBack(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    //TextField functions
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldDidReturn(locationTextField)
        return true
    }
    
    func textFieldDidReturn(_ textField: UITextField) {
        mapView.removeAnnotations(mapView.annotations)
        self.createPin(location: locationTextField.text!)
        self.addPin.setTitle("Submit?", for: .normal)
        if (linkTextField.text == ""){
            self.linkTextField.placeholder = "Enter Link Info"
        }
        self.linkTextField.isEnabled = true
        textField.resignFirstResponder()
        self.linkTextField.becomeFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        locationTextField.text = ""
    }
    
    //center map on location
    func centerOnMap() {
        let location = CLLocationCoordinate2D.init(latitude: (userLocationPoint?.location?.coordinate.latitude)!, longitude: (userLocationPoint?.location?.coordinate.longitude)! )
        mapView.setCenter(location, animated: true)
        mapView.isZoomEnabled = true
    }
    
    func createPin(location: String) {
        userLocationString = location
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(userLocationString!, completionHandler: {(placemarks, error)->Void in
            if let placemark = placemarks?[0] as CLPlacemark? {
                self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
                self.userLocationPoint = placemark
                self.centerOnMap()
            }
        })
    }
    
    @ IBAction func getUserLocation(){
        print(self.userLocationPoint?.location?.coordinate.latitude)
        print(self.userLocationPoint?.location?.coordinate.longitude)
        let alert = UIAlertController(title: "Alert", message: "Do you want to post: Location: \(locationTextField.text!) and Link: \(linkTextField.text!)", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Post", style: UIAlertActionStyle.default, handler: {action in
            self.dismiss(animated: true, completion: nil)}
        ))
        //push pin to parse, if success set flag
        self.present(alert, animated: true, completion: nil)
    }
}
