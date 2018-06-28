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
    
    private let _loginViewModel = LoginViewModel()
    private let _btnGoogle = GIDSignInButton()
    private var _isBtnGoogleSetup = false
    
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
        
        self.setBtnGoogleHidden(true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //
    // MARK: - Format
    //
    private func setBtnGoogleHidden(_ isHidden: Bool) {
        self._btnGoogle.isHidden = isHidden
        self.loginIndicator.isHidden = !isHidden
    }
    
    //
    // MARK: - Process
    //
    private func setupGoogleSignIn() {
        guard self._isBtnGoogleSetup else {
            var error: NSError?
            GGLContext.sharedInstance().configureWithError(&error)
            
            guard error == nil else {
                self.showAlert(title: "Thiết lập Google không thành công", message: error!.localizedDescription, actionTitles: ["OK"], actions: []
                )
                return
            }
            
            // Adding the delegates
            GIDSignIn.sharedInstance().uiDelegate = self
            GIDSignIn.sharedInstance().delegate = self
            // Getting the signin button and adding it to view
            self._btnGoogle.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(self._btnGoogle)
            let xConstraint = NSLayoutConstraint(item: self._btnGoogle, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0)
            let yConstraint = NSLayoutConstraint(item: self._btnGoogle, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 120.0)
            NSLayoutConstraint.activate([xConstraint, yConstraint])
            self.view.addConstraint(xConstraint)
            self.view.addConstraint(yConstraint)
            
            self._isBtnGoogleSetup = true
            self.setBtnGoogleHidden(false)
            
            return
        }
    }
}

//
// MARK: - GIDSignInUIDelegate, GIDSignInDelegate
//
extension LoginViewController: GIDSignInUIDelegate, GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            self.setBtnGoogleHidden(false)
            
            let message = error.localizedDescription
            
            if message != Constants.GOOGLE_CANCELED_SIGN_IN_FLOW {
                self.showAlert(title: "Đăng nhập tài khoản Google không thành công", message: message, actionTitles: ["OK"], actions: []
                )
            }
            
            return
        }
        
        self.setBtnGoogleHidden(true)
        self.loginGoogleAccount(user)
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        User.current?.signOut()
    }
}

//
// MARK: - API Request
//
extension LoginViewController {
    
    private func loginGoogleAccount(_ account: GIDGoogleUser) {
        self._loginViewModel.login(withGoogleUser: account) { [weak self] error in
            DispatchQueue.main.async {
                guard error == nil else {
                    self?.setBtnGoogleHidden(false)
                    self?.showAlert(title: "Đăng nhập không thành công", message: error!.message!, actionTitles: ["OK"], actions: [{ ok in
                        }]
                    )
                    
                    GIDSignIn.sharedInstance().signOut()
                    
                    return
                }
                
                self?.setRootViewController(withType: .tabBar)
            }
        }
    }
}
