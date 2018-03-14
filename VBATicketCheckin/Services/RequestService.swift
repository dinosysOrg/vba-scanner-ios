//
//  RequestService.swift
//  VBATicketCheckin
//
//  Created by ngoclam on 3/12/18.
//  Copyright © 2018 Dinosys. All rights reserved.
//

import Foundation
import SwiftyJSON

class RequestService {
    static let shared = RequestService()
    
    func requestLogin(_ info: [String : Any], completion: ((_ json: JSON?, _ error: APIError?) -> Void)?) {
        let gAccessToken = info["gaccess_token"] as! String
        
        provider.request(.login(gAccessToken)) { result in
            guard let complete = completion else {
                return
            }
            
            switch result {
            case let .success(response):
                ServiceHelper.handleResponse(response, json: { (json, error) in
                    complete(json, error)
                })
            case let .failure(error):
                let error = ServiceHelper.serviceError(from: error)
                complete(nil, error)
            }
        }
    }
    
    func requestGetUpcomingMatches(completion: ((_ array: [JSON]?, _ error: APIError?) -> Void)?) {
        provider.request(.getUpcomingMatches()) { result in
            guard let complete = completion else {
                return
            }
            
            switch result {
            case let .success(response):
                ServiceHelper.handleResponse(response, array: { (array, error) in
                    complete(array, error)
                })
            case let .failure(error):
                let error = ServiceHelper.serviceError(from: error)
                complete(nil, error)
            }
        }
    }
    
    func requestScanTicket(_ info: [String : Any], completion: ((_ json: JSON?, _ error: APIError?) -> Void)?) {
        let matchId = info["match_id"] as! Int
        let ticketQRCode = info["ticket_qrcode"] as! QRCodeContent
        
        provider.request(.scanTicket(matchId, ticketQRCode)) { result in
            guard let complete = completion else {
                return
            }
            
            switch result {
            case let .success(response):
                ServiceHelper.handleResponse(response, json: { (json, error) in
                    complete(json, error)
                })
            case let .failure(error):
                let error = ServiceHelper.serviceError(from: error)
                complete(nil, error)
            }
        }
    }
    
    func requestPurchaseTicket(_ info: [String : Any], completion: ((_ error: APIError?) -> Void)?) {
        let id = info["id"] as! String
        let paidValue = info["paid_value"] as! Double
        
        provider.request(.purchaseTicket(id, paidValue)) { result in
            guard let complete = completion else {
                return
            }
            
            switch result {
            case let .success(response):
                ServiceHelper.handleResponse(response, error: { error in
                    complete(error)
                })
            case let .failure(error):
                let error = ServiceHelper.serviceError(from: error)
                complete(error)
            }
        }
    }
    
    func requestGetConversionRateP2M(completion: ((_ json: JSON?, _ error: APIError?) -> Void)?) {
        provider.request(.getRateP2M()) { result in
            guard let complete = completion else {
                return
            }
            
            switch result {
            case let .success(response):
                ServiceHelper.handleResponse(response, json: { (json, error) in
                    complete(json, error)
                })
                break
            case let .failure(error):
                let error = ServiceHelper.serviceError(from: error)
                complete(false, error)
            }
        }
    }
    
    func requestPurchaseTicketWithPoint(_ info: [String : Any], completion: ((_ error: APIError?) -> Void)?) {
        let orderId = info["order_id"] as! String
        let customerId = info["customer_id"] as! String
        
        provider.request(.purchaseTicketWithPoint(customerId, orderId)) { result in
            guard let complete = completion else {
                return
            }
            
            switch result {
            case let .success(response):
                ServiceHelper.handleResponse(response, error: { error in
                    complete(error)
                })
            case let .failure(error):
                let error = ServiceHelper.serviceError(from: error)
                complete(error)
            }
        }
    }
    
    func requestPurchaseMerchandiseWithPoint(_ info: [String : Any], completion: ((_ error: APIError?) -> Void)?) {
        let point = info["points"] as! Int
        let customerId = info["customer_id"] as! String
        
        provider.request(.purchaseMerchandise(point, customerId)) { result in
            guard let complete = completion else {
                return
            }
            
            switch result {
            case let .success(response):
                ServiceHelper.handleResponse(response, error: { error in
                    complete(error)
                })
            case let .failure(error):
                let error = ServiceHelper.serviceError(from: error)
                complete(error)
            }
        }
    }
}
