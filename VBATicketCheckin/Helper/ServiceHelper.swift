//
//  ServiceHelper.swift
//  VBATicketCheckin
//
//  Created by ngoclam on 3/14/18.
//  Copyright © 2018 Dinosys. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON

struct ServiceHelper {
    /// Handle Moya response with completion closure of a JSON and a APIError.
    ///
    /// - Parameters:
    ///   - response: response data from request with type Response.
    ///   - complete: closure of a JSON and a APIError.
    static func handleResponse(_ response: Response, json complete: @escaping(_ json: JSON?, _ error: APIError?) -> Void) {
        let data = response.data
        let statusCode = response.statusCode
        let json = JSON(data)
        
        if statusCode >= 200 && statusCode <= 300 {
            guard json[Constants.ResponseKey.DATA] != JSON.null else {
                complete(json, nil)
                return
            }
            
            complete(json[Constants.ResponseKey.DATA], nil)
        } else {
            guard json[Constants.ResponseKey.ERROR] != JSON.null else {
                let error = APIError(statusCode)
                complete(nil, error)
                return
            }
            
            let error = APIError(statusCode, errorData: json[Constants.ResponseKey.ERROR])
            complete(nil, error)
        }
    }
    
    
    /// Handle Moya response with completion closure of an array of JSON and a APIError.
    ///
    /// - Parameters:
    ///   - response: response data from request with type Response.
    ///   - complete: closure of an array of JSON and a APIError.
    static func handleResponse(_ response: Response, array complete: @escaping(_ array: [JSON]?, _ error: APIError?) -> Void) {
        let data = response.data
        let statusCode = response.statusCode
        let json = JSON(data)
        
        if statusCode >= 200 && statusCode <= 300 {
            complete(json.array, nil)
        } else {
            guard json[Constants.ResponseKey.ERROR] != JSON.null else {
                let error = APIError(statusCode)
                complete(nil, error)
                return
            }
            
            let error = APIError(statusCode, errorData: json[Constants.ResponseKey.ERROR])
            complete(nil, error)
        }
    }
    
    
    /// Handle Moya response with completion closure of a APIError.
    ///
    /// - Parameters:
    ///   - response: response data from request with type Response.
    ///   - complete: closure of a APIError.
    static func handleResponse(_ response: Response, error complete: @escaping(_ error: APIError?) -> Void) {
        let data = response.data
        let statusCode = response.statusCode
        let json = JSON(data)
        
        if statusCode >= 200 && statusCode <= 300 {
            complete(nil)
        } else {
            guard json[Constants.ResponseKey.ERROR] != JSON.null else {
                let error = APIError(statusCode)
                complete(error)
                return
            }
            
            let error = APIError(statusCode, errorData: json[Constants.ResponseKey.ERROR])
            complete(error)
        }
    }
    
    /// Return a APIError object from Moya response.
    ///
    /// - Parameter error: MoyaError from service request.
    /// - Returns: an APIError from request
    static func serviceError(from error: MoyaError) -> APIError {
        return APIError(error.errorDescription)
    }
}
