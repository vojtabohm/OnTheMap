//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Vojtěch Böhm on 07/11/2017.
//  Copyright © 2017 Vojtěch Böhm. All rights reserved.
//

import Foundation
import UIKit

class MapViewController: UIViewController {
    
    //MARK: Properties
    
    //MARK: Outlets
    
    @IBOutlet var logOutButton: UIBarButtonItem!
    @IBOutlet var refreshButton: UIBarButtonItem!
    @IBOutlet var addButton: UIBarButtonItem!
    
    //MARK: Life Cycle
    
    
    
    //MARK: Actions
    
    @IBAction func logOut(_ sender: Any) {
        setUIEnabled(false)
        
        UdacityClient.shared.logOut() { (success, error) in
            if success {
                self.dismiss(animated: true, completion: nil)
            } else {
                let vc = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                vc.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(vc, animated: true, completion: nil)
                self.setUIEnabled(true)
            }
        }
    }
    
    //MARK: Functions
    
    
    
}


//MARK: - MapViewController (Configure)
extension MapViewController {
    func setUIEnabled(_ enabled: Bool) {
        logOutButton.isEnabled = enabled
        refreshButton.isEnabled = enabled
        addButton.isEnabled = enabled
        self.tabBarController?.tabBar.items?[1].isEnabled = enabled
    }
}
