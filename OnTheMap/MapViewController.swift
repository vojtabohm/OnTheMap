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
    
    //MARK: Outlets
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var loadingView: UIView!
    
    //MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        ParseClient.shared.delegates.append(self)
        ParseClient.shared.downloadLocations()
    }
    
    //MARK: Functions
    
    func addAnnotationsToMap() {
        var annotations = [MKPointAnnotation]()
        
        for student in StudentLocation.studentLocations! {
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

//MARK: - MapViewController (UI) 

extension MapViewController {
    func setLoading(enabled: Bool) {
        loadingView.isHidden = !(enabled)
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

//MARK: - MapViewController: (ParseClientDelegate)

extension MapViewController: ParseClientDelegate {
    func changedState(_ state: ParseClient.State) {
        switch state {
        case .loading:
            setLoading(enabled: true)
        case .error:
            setLoading(enabled: false)
            showOKAlert(title: "Error", message: ParseClient.shared.error!)
        case .ready:
            setLoading(enabled: false)
        default:
            return
        }
    }
    
    func finishedDownloading() {
        addAnnotationsToMap()
        setLoading(enabled: false)
    }
    
    func finishedPosting() {
        let allAnnotations = mapView.annotations
        mapView.removeAnnotations(allAnnotations)
    }
}
