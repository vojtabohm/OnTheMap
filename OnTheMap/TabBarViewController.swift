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
        ParseClient.shared.delegates.append(self)
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
    
    @IBAction func addLocation(_ sender: Any) {
        ParseClient.shared.downloadUserLocation() { (success, error) in
            if success {
                self.completeAddLocation()
            } else {
                self.showOKAlert(title: "Error", message: (error?.localizedDescription)!)
            }
        }
    }
    
    //MARK: Functions
    
    func completeAddLocation() {
        if ParseClient.shared.objectID != nil {
            let vc = UIAlertController(title: "Wait a second", message: "You have already posted a location", preferredStyle: .alert)
            vc.addAction(UIAlertAction(title: "Overwrite", style: .default, handler: { _ in
                self.presentAddLocation()
            }))
            vc.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(vc, animated: true, completion: nil)
        } else {
            presentAddLocation()
        }
    }
    
    func presentAddLocation() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PostNavigationViewController") as! UINavigationController
        self.present(vc, animated: true, completion: nil)
    }
}

extension TabBarViewController: ParseClientDelegate {
    func changedState(_ state: ParseClient.State) {
        switch state {
        case .loading:
            setUIEnabled(false)
        case .error:
            setUIEnabled(true)
        case .ready:
            setUIEnabled(true)
        default:
            return
        }
    }
    
    func finishedDownloading() {
        setUIEnabled(true)
    }
    
    func finishedPosting() {
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
