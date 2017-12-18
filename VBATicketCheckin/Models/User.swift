//
//  User.swift
//  VBATicketCheckin
//
//  Created by Bui Minh Duc on 11/21/17.
//  Copyright © 2017 Dinosys. All rights reserved.
//

import Foundation
import SwiftyJSON
import GoogleSignIn

class User {
    
    static var sharedInstance = User()
    
    private init() {}
    
    // User Info
    
    // Name
    var Name: String? {
        get {
            let defaults = UserDefaults.standard
            let name = defaults.object(forKey: "name") as? String
            return name
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "name")
            defaults.synchronize()
        }
    }
    
    // Email
    var Email: String? {
        get {
            let defaults = UserDefaults.standard
            let email = defaults.object(forKey: "email") as? String
            return email
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "email")
            defaults.synchronize()
        }
    }
    
    
    // Google Access Token
    var GoogleAccessToken: String? {
        get {
            let defaults = UserDefaults.standard
            let token = defaults.object(forKey: "googleAccessToken") as? String
            return token
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "googleAccessToken")
            defaults.synchronize()
        }
    }
    
    //App Access Token
    var AccessToken: String? {
        get {
            let defaults = UserDefaults.standard
            let token = defaults.object(forKey: "accessToken") as? String
            return token
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "accessToken")
            defaults.synchronize()
        }
    }
    
    var IsAuthorized: Bool {
        get {
            return AccessToken != nil && !AccessToken!.isEmpty
        }
    }
    
    func signOut(){
        self.GoogleAccessToken = ""
        self.Name = ""
        self.Email = ""
        self.AccessToken = ""
        GIDSignIn.sharedInstance().signOut()
    }
}

