//
//  LoginViewModel.swift
//  VBATicketCheckin
//
//  Created by Bui Minh Duc on 11/22/17.
//  Copyright © 2017 Dinosys. All rights reserved.
//

import Foundation
import SwiftyJSON
import Google
import GoogleSignIn

public class LoginViewModel {
    private let service = RequestService.shared
    
    func login(withGoogleUser user: GIDGoogleUser, completion: ((_ error: APIError?) -> Void)?) {
        let info: [String : Any] = ["gaccess_token" : user.authentication.idToken]
        
        service.requestLogin(info) { (json, error) in
            guard let complete = completion else {
                return
            }
            
            if let _ = error {
                complete(error)
            } else {
                let userInfo: JSON = ["name" : user.profile.name, "email" : user.profile.email, "accessToken" : json!["token"].stringValue, "googleAccessToken" : user.authentication.idToken]
                let current = User(json: userInfo)
                User.save(current)
                
                complete(nil)
            }
        }
    }
}
