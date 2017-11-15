//
//  PostViewController.swift
//  OnTheMap
//
//  Created by Vojtěch Böhm on 11/11/2017.
//  Copyright © 2017 Vojtěch Böhm. All rights reserved.
//

import Foundation
import UIKit

class PostViewController: UIViewController {
    
    //MARK: Properties
    
    var keyboardOnScreen: Bool = false
    
    //MARK: Outlets
    
    @IBOutlet var locationField: UITextField!
    @IBOutlet var urlField: UITextField!
    @IBOutlet var debugLabel: UILabel!
    @IBOutlet var findLocationButton: UIButton!
    @IBOutlet var iconImage: UIImageView!
    @IBOutlet var loadingView: UIView!
    
    //MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    //MARK: Actions
    
    @IBAction func didCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func findLocation(_ sender: Any) {
        userDidTapView(self)
        setUIEnabled(false)
        debugLabel.text = ""
        
        guard !locationField.text!.isEmpty && !urlField.text!.isEmpty else {
            debugLabel.text = "Location or URL Empty"
            setUIEnabled(true)
            return
        }
        
        guard urlField.text!.contains("http://") || urlField.text!.contains("https://") else {
            debugLabel.text = "URL must contain http(s)://"
            setUIEnabled(true)
            return
        }
        loadingView.isHidden = false
        ParseClient.shared.geocode(string: locationField.text!) { (success, error) in
            if success {
                self.loadingView.isHidden = true
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "GeoViewController") as! GeoViewController
                vc.mediaURL = self.urlField.text!
                vc.mapString = self.locationField.text!
                self.navigationController?.pushViewController(vc, animated: true)
                self.setUIEnabled(true)
            } else {
                self.debugLabel.text = error?.localizedDescription
                self.loadingView.isHidden = true
                self.setUIEnabled(true)
            }
        }
    }
}

//MARK: - PostViewController (TextField Delegate)

extension PostViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - PostViewController (Configure)

extension PostViewController {
    @IBAction func userDidTapView(_ sender: Any) {
        locationField.resignFirstResponder()
        urlField.resignFirstResponder()
    }
    
    func setUIEnabled(_ enabled: Bool) {
        locationField.isEnabled = enabled
        urlField.isEnabled = enabled
        findLocationButton.isEnabled = enabled
        
        if enabled {
            findLocationButton.alpha = 1.0
        } else {
            findLocationButton.alpha = 0.5
        }
    }
    
    func configure() {
        locationField.delegate = self
        urlField.delegate = self
    }
}
