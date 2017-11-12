//
//  GeoViewController.swift
//  OnTheMap
//
//  Created by Vojtěch Böhm on 12/11/2017.
//  Copyright © 2017 Vojtěch Böhm. All rights reserved.
//

import UIKit
import MapKit

class GeoViewController: UIViewController {
    
    //MARK: Properties
    
    var mediaURL = ""
    var mapString = ""
    var latitude: Double = 0
    var longitude: Double = 0

    //MARK: Outlets
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var finishButton: UIButton!
    
    //MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPinToMap()
    }
    
    //MARK: Actions
    
    @IBAction func didTapFinish(_ sender: Any) {
        setUIEnabled(false)
        ParseClient.shared.addLocation(mapString: mapString, mediaURL: mediaURL, latitude: latitude, longitude: longitude) { (success, error) in
            if success {
                self.navigationController?.dismiss(animated: true, completion: nil)
            } else {
                self.showOKAlert(title: "Error", message: error!.localizedDescription)
                self.setUIEnabled(true)
            }
        }
    }
    
    //MARK: Functions
    
    func addPinToMap() {
        guard let location = ParseClient.shared.user?.getLocation()?.location else {
            //show error
            return
        }
        
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        annotation.title = ParseClient.shared.user!.firstName + "" + ParseClient.shared.user!.lastName
        annotation.subtitle = mediaURL
        
        mapView.addAnnotation(annotation)
        mapView.showAnnotations([annotation], animated: true)
    }
}

extension GeoViewController {
    func setUIEnabled(_ enabled: Bool) {
        finishButton.isEnabled = enabled
    }
}
