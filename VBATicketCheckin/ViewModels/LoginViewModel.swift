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
    func loginWith(google user: GIDGoogleUser, completion: @escaping (Bool, APIError?) -> Void){
        apiService.request(APIService.login(user.authentication.idToken)) { result in
            switch result {
            case let .success(response):
                let data = response.data
                let statusCode = response.statusCode
                
                if statusCode >= 200 && statusCode <= 300 {
                    let jsonData = JSON(data)
                    let info: JSON = ["name" : user.profile.name, "email" : user.profile.email, "accessToken" : jsonData["token"].stringValue, "googleAccessToken" : user.authentication.idToken];
                    let current = User(json: info)
                    User.save(current)
                    
                    completion(true, nil)
                } else {
                    let requestError = APIError(statusCode)
                    completion(false, requestError)
                }
                break
            case let .failure(error):
                var requestError = APIError()
                requestError.message = error.errorDescription
                completion(false, requestError)
                break
            }
        }
    }
}
