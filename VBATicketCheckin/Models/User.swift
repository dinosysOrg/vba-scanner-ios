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

class User: NSObject, NSCoding {
    
    var name: String?
    var email: String?
    // App Access Token
    var accessToken: String?
    // GoogleSignIn Access Token
    var googleAccessToken: String?
    
    required init(coder decoder: NSCoder) {
        name = decoder.decodeObject(forKey: "name") as? String
        email = decoder.decodeObject(forKey: "email") as? String
        accessToken = decoder.decodeObject(forKey: "accessToken") as? String
        googleAccessToken = decoder.decodeObject(forKey: "googleAccessToken") as? String
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(email, forKey: "email")
        coder.encode(accessToken, forKey: "accessToken")
        coder.encode(googleAccessToken, forKey: "googleAccessToken")
    }
    
    //
    // MARK: - Initialization
    //
    /**
     * Init User from json data
     * {
     *      name: "abc",
     *      email: "abc@bcd.com",
     *      accessToken: "123456sfdfoisjd",
     *      googleAccessToken: "sadflsodf7s98df79s8dfkj12lkjlwkj1lk3j123"
     * }
     */
    init(json: JSON) {
        name = json["name"].stringValue
        email = json["email"].stringValue
        accessToken = json["accessToken"].stringValue
        googleAccessToken = json["googleAccessToken"].stringValue
    }
    
    // MARK: - Processes
    /**
     * Return User from UserDefaults if available otherwise returl nil
     */
    static var current: User? {
        get {
            guard let data = Constants.USER_DEFAULTS.object(forKey: "current") as? Data else {
                return nil
            }
            
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? User
        }
    }
    
    /**
     * Return true if user is authorized otherwise returl false
     */
    static var authorized: Bool {
        get {
            guard let user = User.current else {
                return false
            }
            
            return !Utils.isEmpty(user.accessToken)
        }
    }
    
    // Save current user to UserDefaults
    static func save(_ user: User) {
        let encodeObject = NSKeyedArchiver.archivedData(withRootObject: user)
        Constants.USER_DEFAULTS.set(encodeObject, forKey: "current")
        Constants.USER_DEFAULTS.synchronize()
    }
    
    /**
     * Remove current user from UserDefaults.
     */
    func remove() {
        Constants.USER_DEFAULTS.removeObject(forKey: "current")
        Constants.USER_DEFAULTS.synchronize()
    }
    
    func signOut() {
        remove()
        GIDSignIn.sharedInstance().signOut()
    }
}

