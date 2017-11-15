//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Vojtěch Böhm on 05/11/2017.
//  Copyright © 2017 Vojtěch Böhm. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    //MARK: Properties
    
    var keyboardOnScreen: Bool = false

    //MARK: Outlets
    
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var debugLabel: UILabel!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var facebookButton: FBSDKLoginButton!
    
    //MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeFromAllNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        facebookButton.setNeedsDisplay()        
    }
    
    //MARK: Actions
    
    @IBAction func loginPressed(_ sender: Any) {
        userDidTapView(self)
        setUIEnabled(false)
        
        guard !usernameField.text!.isEmpty && !passwordField.text!.isEmpty else {
            debugLabel.text = "Username or Password empty"
            setUIEnabled(true)
            return
        }
        
        UdacityClient.shared.loginUser(username: usernameField.text!, password: passwordField.text!) { (success, error) in
            if success {
                self.completeLogin()
            } else {
                self.displayError(error?.localizedDescription)
            }
        }
    }
    
    @IBAction func signUpPressed(_ sender: Any) {
        UdacityClient.shared.signUp()
    }
    
    //MARK: Functions
    
    func completeLogin() {
        debugLabel.text = ""
        let vc = storyboard?.instantiateViewController(withIdentifier: "MainNavigationViewController") as! UINavigationController
        present(vc, animated: true, completion: nil)
        setUIEnabled(true)
    }
    
    func displayError(_ errorString: String?) {
        setUIEnabled(true)
        debugLabel.text = errorString
    }
}

//MARK: - LoginViewController (FBSDKLoginButtonDelegate)

extension LoginViewController: FBSDKLoginButtonDelegate {
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        return
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        setUIEnabled(false)
        
        guard error == nil else {
            debugLabel.text = error.localizedDescription
            setUIEnabled(true)
            return
        }
        
        guard let token = result.token?.tokenString else {
            setUIEnabled(true)
            debugLabel.text = "User cancelled logging in"
            return
        }
        
        UdacityClient.shared.logInWithFacebook(token: token) { (success, error) in
            if success {
                self.completeLogin()
            } else {
                self.displayError(error?.localizedDescription)
            }
        }
    }
}

//MARK: - LoginViewController (TextField Delegate)

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if !keyboardOnScreen {
            self.view.frame.origin.y -= self.keyboardHeight(notification)
            self.logoImageView.isHidden = true
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if keyboardOnScreen {
            self.view.frame.origin.y += self.keyboardHeight(notification)
            self.logoImageView.isHidden = false
        }
    }
    
    @objc func keyboardDidShow() {
        keyboardOnScreen = true
    }
    
    @objc func keyboardDidHide() {
        keyboardOnScreen = false
    }
    
    func keyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue
        
        guard let height = keyboardSize?.cgRectValue.height else {
            return 0
        }
        
        return height
    }
}

//MARK: - LoginViewController (Configure)

extension LoginViewController {
    func configure() {
        usernameField.delegate = self
        passwordField.delegate = self
        facebookButton.delegate = self
        
        subscribeToNotification(.UIKeyboardWillShow, selector: #selector(keyboardWillShow))
        subscribeToNotification(.UIKeyboardWillHide, selector: #selector(keyboardWillHide))
        subscribeToNotification(.UIKeyboardDidShow, selector: #selector(keyboardDidShow))
        subscribeToNotification(.UIKeyboardDidHide, selector: #selector(keyboardDidHide))
    }
    
    @IBAction func userDidTapView(_ sender: Any) {
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
    
    func setUIEnabled(_ enabled: Bool) {
        usernameField.isEnabled = enabled
        passwordField.isEnabled = enabled
        loginButton.isEnabled = enabled
        signUpButton.isEnabled = enabled
        facebookButton.isEnabled = enabled
        
        if enabled {
            loginButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
        }
    }
}

//MARK: - LoginViewController (Notification)

extension LoginViewController {
    func subscribeToNotification(_ notification: Notification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}

