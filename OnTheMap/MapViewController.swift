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
                //smth
            } else {
                //smth
            }
        }
        
        // ParseClient.shared.downloadLocations()
        // Parse Locations into StudentLocations array of dictionaries
        // Convert the array of dictionaries to array of annotations
        // Add annotations to the map
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
