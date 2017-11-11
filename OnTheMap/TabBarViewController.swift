//
//  TabBarViewController.swift
//  OnTheMap
//
//  Created by Vojtěch Böhm on 11/11/2017.
//  Copyright © 2017 Vojtěch Böhm. All rights reserved.
//

import Foundation
import UIKit

class TabBarViewController: UITabBarController {
    
    //MARK: Outlets
    
    @IBOutlet var logOutButton: UIBarButtonItem!
    @IBOutlet var refreshButton: UIBarButtonItem!
    @IBOutlet var addButton: UIBarButtonItem!
    
    //MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    @IBAction func reloadData(_ sender: Any) {
        ParseClient.shared.downloadLocations()
    }
}

//MARK: - TabBarViewController (Configure)
extension TabBarViewController {
    func setUIEnabled(_ enabled: Bool) {
        logOutButton.isEnabled = enabled
        refreshButton.isEnabled = enabled
        addButton.isEnabled = enabled
        self.tabBarController?.tabBar.items?[1].isEnabled = enabled
    }
}
