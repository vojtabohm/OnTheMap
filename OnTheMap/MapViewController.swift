//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Vojtěch Böhm on 07/11/2017.
//  Copyright © 2017 Vojtěch Böhm. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController {
    
    //MARK: Properties
    
    //MARK: Outlets
    
    @IBOutlet var logOutButton: UIBarButtonItem!
    @IBOutlet var refreshButton: UIBarButtonItem!
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var mapView: MKMapView!
    
    //MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        downloadAnnotations()
    }
    
    //MARK: Actions
    
    @IBAction func logOut(_ sender: Any) {
        setUIEnabled(false)
        
        UdacityClient.shared.logOut() { (success, error) in
            if success {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.showOKAlert(title: "Error", message: (error?.localizedDescription)!)
                self.setUIEnabled(true)
            }
        }
    }
    
    //MARK: Functions
    
    func downloadAnnotations() {
        ParseClient.shared.downloadLocations { (success, error) in
            if success {
                self.addAnnotationsToMap()
            } else {
                self.showOKAlert(title: "Failed to download Locations", message: error!)
            }
        }
    }
    
    func addAnnotationsToMap() {
        var annotations = [MKPointAnnotation]()
        
        for student in ParseClient.shared.studentLocations! {
            let latitude = CLLocationDegrees(student.latitude)
            let longitude = CLLocationDegrees(student.longitude)
            
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let firstName = student.firstName
            let lastName = student.lastName
            let mediaURL = student.mediaURL
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(firstName) \(lastName)"
            annotation.subtitle = mediaURL
            
            annotations.append(annotation)
        }
        
        mapView.addAnnotations(annotations)
    }
}

//MARK: - MapViewController (Configure)
extension MapViewController {
    func setUIEnabled(_ enabled: Bool) {
        logOutButton.isEnabled = enabled
        refreshButton.isEnabled = enabled
        addButton.isEnabled = enabled
        self.tabBarController?.tabBar.items?[1].isEnabled = enabled
    }
    
    func showOKAlert(title: String, message: String) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(vc, animated: true, completion: nil)
    }
}

//MARK: - MapViewController (MKMapViewDelegate)
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        pinView.canShowCallout = true
        pinView.pinTintColor = UIColor.blue
        pinView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let urlString = view.annotation?.subtitle as? String, (urlString.contains("http://") || urlString.contains("https://")), let url = URL(string: urlString) else {
            showOKAlert(title: "Error", message: "Invalid URL")
            return
        }
        
        UIApplication.shared.openURL(url)
    }
}
