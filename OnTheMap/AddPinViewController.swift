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
    
    //set delegate
    //let linkTextfieldDelegate = LinkTextFieldDelegate()
    
    //lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        linkTextField.isEnabled = false
        linkTextField.delegate = self //linkTextfieldDelegate
        locationTextField.delegate = self
        activityIndicator.hidesWhenStopped = true
    }
    
    //buttons
    @IBAction func goBack(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @ IBAction func getUserLocation(){
        if (addPin.titleLabel?.text == "Find On Map"){
            findOnMap()
        } else if (addPin.titleLabel?.text == "Submit?"){
            guard let lat = self.userLocationPoint?.location?.coordinate.latitude else{
                return
            }
            guard let long = self.userLocationPoint?.location?.coordinate.longitude else{
                return
            }
            
            let locationTextString = "\((self.userLocationPoint?.locality)!), \((self.userLocationPoint?.administrativeArea)!)."
            
            let media = linkTextField.text!
            
            let alert = launchAlert(message: "Do you want to post: Location: \(locationTextString) and Link: \(media)")
            alert.addAction(UIAlertAction(title: "Post", style: UIAlertActionStyle.default, handler: {action in
                Client.sharedInstance.addStudentPin(lat: lat, long: long, loc: locationTextString, media: media){success in
                    performUIUpdatesOnMain {
                        if (!success){
                            let alert = launchAlert(message: "Failed to post pin")
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }))
            //push pin to parse, if success set flag
            self.present(alert, animated: true, completion: nil)
        }
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

    //functions
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
                let alert = launchAlert(message: "Failed to geocode location")
                //self.present(alert, animated: true, completion: nil)
                self.present(alert, animated: true){ action in
                    self.activityIndicator.stopAnimating()
                }
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
