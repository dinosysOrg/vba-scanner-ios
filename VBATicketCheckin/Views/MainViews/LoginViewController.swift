//
//  LoginViewController.swift
//  VBATicketCheckin
//
//  Created by Bui Minh Duc on 11/21/17.
//  Copyright © 2017 Dinosys. All rights reserved.
//

import UIKit
import Google
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    
    let loginViewModel = LoginViewModel()
    
    var isGoogleButtonSetup = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if User.sharedInstance.IsAuthorized {
            presentMainViewController()
        } else {
            self.setupGoogleSignIn()
        }
    }
    
    func presentMainViewController(){
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        
        let mainViewController = storyBoard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        
        self.present(mainViewController, animated:true, completion:nil)
    }
    
    func showError(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(ac, animated: true)
    }
    
    func setupGoogleSignIn(){
        
        if self.isGoogleButtonSetup {
            return
        }
        
        // Error object
        var error : NSError?
        
        // Setting the error
        GGLContext.sharedInstance().configureWithError(&error)
        
        // If any error stop execution and print error
        if error != nil{
            print(error ?? "google error")
            return
        }
        
        // Adding the delegates
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        // Getting the signin button and adding it to view
        let googleSignInButton = GIDSignInButton()
        
        googleSignInButton.center = CGPoint(x: view.center.x, y: (view.center.y + 120))
        
        view.addSubview(googleSignInButton)
        
        self.isGoogleButtonSetup = true
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        // If any error stop and print the error
        if error != nil{
            print(error ?? "google error")
            return
        }
        
        User.sharedInstance.GoogleAccessToken = user.authentication.idToken
        User.sharedInstance.Name = user.profile.name
        User.sharedInstance.Email = user.profile.email
        
        loginViewModel.loginWith(google: user.authentication.idToken) { (success, error) in
            if success {
                self.presentMainViewController()
            } else if let loginError = error {
                self.showError(title: "Đăng nhập không thành công", message: loginError.message!)
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        User.sharedInstance.GoogleAccessToken = ""
        User.sharedInstance.Name = ""
        User.sharedInstance.Email = ""
    }
}

