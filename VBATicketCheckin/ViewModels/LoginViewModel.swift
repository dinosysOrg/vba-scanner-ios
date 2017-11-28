//
//  LoginViewModel.swift
//  VBATicketCheckin
//
//  Created by Bui Minh Duc on 11/22/17.
//  Copyright © 2017 Dinosys. All rights reserved.
//

import Foundation
import SwiftyJSON

public class LoginViewModel {
    func loginWith(google accesstoken: String, completion: @escaping (Bool, APIError?) -> Void){
        ticketCheckInAPIProvider.request(TicketCheckInAPI.login(accesstoken)) { result in
            switch result {
            case let .success(response):
                let data = response.data
                let statusCode = response.statusCode
                
                if statusCode == 200 {
                    let jsonData = JSON(data)
                    
                    User.sharedInstance.AccessToken = jsonData["token"].stringValue
                    
                    completion(true, nil)
                } else {
                    let apiError = APIError(statusCode)
                    completion(false, apiError)
                }
                break
            case let .failure(error):
                var apiError = APIError()
                apiError.message = error.errorDescription
                completion(false, apiError)
                break
            }
        }
    }
}
