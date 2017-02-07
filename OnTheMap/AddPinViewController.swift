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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var userLocationString: String?
    var userLocationPoint: CLPlacemark?
    let client = AppDelegate().client
    
    //set delegate
    let linkTextfieldDelegate = LinkTextFieldDelegate()
    
    //lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        linkTextField.isEnabled = false
        linkTextField.delegate = linkTextfieldDelegate
        locationTextField.delegate = self
        activityIndicator.hidesWhenStopped = true
    }
    
    //Views
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.addPin.setTitle("Find On Map", for: .normal)
        locationTextField.text = ""
    }
    
    //buttons
    @IBAction func goBack(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @ IBAction func getUserLocation(){
        if (addPin.titleLabel?.text == "Find On Map"){
            findOnMap()
        } else if (addPin.titleLabel?.text == "Submit?"){
            if let lat = self.userLocationPoint?.location?.coordinate.latitude {
                Constants.User.latitude = Double(lat)
            }
            if let long = self.userLocationPoint?.location?.coordinate.longitude {
            Constants.User.longitude = Double(long)
            }
            //Constants.User.mediaUrl = linkTextField.text! // need to protect against nil
            let alert = client.launchAlert(message: "Do you want to post: Location: \(locationTextField.text!) and Link: \(linkTextField.text!)")
            alert.addAction(UIAlertAction(title: "Post", style: UIAlertActionStyle.default, handler: {action in
                self.client.addStudentPin(){success in
                    if (!success){
                        let alert = self.client.launchAlert(message: "Failed to post pin")
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }))
            //push pin to parse, if success set flag
            self.present(alert, animated: true, completion: nil)
        }
    }
    //helpers
    //center map on location
    func centerOnMap() {
        let location = CLLocationCoordinate2D.init(latitude: (userLocationPoint?.location?.coordinate.latitude)!, longitude: (userLocationPoint?.location?.coordinate.longitude)! )
        mapView.setCenter(location, animated: true)
        mapView.isZoomEnabled = true
    }
    
    //place pin and center map
    func createPin(location: String) {
        userLocationString = location
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(userLocationString!, completionHandler: {(placemarks, error)->Void in
            if let placemark = placemarks?[0] as CLPlacemark? {
                self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
                self.userLocationPoint = placemark
                self.centerOnMap()
                self.activityIndicator.stopAnimating()
            } else {
                let alert = self.client.launchAlert(message: "Failed to geocode location")
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    //add pin
    func findOnMap(){
        activityIndicator.startAnimating()
        mapView.removeAnnotations(mapView.annotations)
        self.createPin(location: locationTextField.text!)
        self.addPin.setTitle("Submit?", for: .normal)
        if (linkTextField.text == ""){
            self.linkTextField.placeholder = "Add A Link?"
        }
        self.linkTextField.isEnabled = true
    }
}
