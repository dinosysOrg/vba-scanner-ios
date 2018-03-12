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

class LoginViewController: BaseViewController {
    @IBOutlet weak var loginIndicator: UIActivityIndicatorView!
    
    let loginViewModel = LoginViewModel()
    let googleSignInButton = GIDSignInButton()
    var isGoogleButtonSetup = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setViewBackgroundColor(by: .clear)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard User.authorized else {
            self.setupGoogleSignIn()
            return
        }
        
        self.setRootViewController(withType: .tabBar)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.setGoogleSignInButtonHidden(true)
    }
    
    // MARK: - Format
    private func setGoogleSignInButtonHidden(_ isHidden: Bool) {
        self.googleSignInButton.isHidden = isHidden
        self.loginIndicator.isHidden = !isHidden
    }
    
    // MARK: - Process
    private func setupGoogleSignIn() {
        guard self.isGoogleButtonSetup else {
            var error: NSError?
            GGLContext.sharedInstance().configureWithError(&error)
            
            guard error == nil else {
                self.showAlert(title: "Thiết lập Google không thành công", message: error!.localizedDescription, actionTitles: ["OK"], actions: [])
                return
            }
            
            // Adding the delegates
            GIDSignIn.sharedInstance().uiDelegate = self
            GIDSignIn.sharedInstance().delegate = self
            // Getting the signin button and adding it to view
            self.googleSignInButton.center = CGPoint(x: view.center.x, y: (view.center.y + 120))
            self.view.addSubview(self.googleSignInButton)
            
            self.isGoogleButtonSetup = true
            self.setGoogleSignInButtonHidden(false)
            
            return
        }
    }
}

extension LoginViewController: GIDSignInUIDelegate, GIDSignInDelegate {
    // MARK: - GIDSignInDelegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            self.showAlert(title: "Đăng nhập tài khoản Google không thành công", message: error.localizedDescription, actionTitles: ["OK"], actions: [])
            return
        }
        
        self.setGoogleSignInButtonHidden(true)
        
        loginViewModel.loginWith(google: user) { [weak self] (success, error) in
            DispatchQueue.main.async {
                if success {
                    self?.setRootViewController(withType: .tabBar)
                } else if let _ = error {
                    self?.setGoogleSignInButtonHidden(false)
                    self?.showAlert(title: "Đăng nhập không thành công", message: error!.message!, actionTitles: ["OK"], actions: [])
                }
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        User.current?.signOut()
    }
}
