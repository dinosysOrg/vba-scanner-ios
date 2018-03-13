//
//  MainViewModel.swift
//  VBATicketCheckin
//
//  Created by Bui Minh Duc on 11/22/17.
//  Copyright © 2017 Dinosys. All rights reserved.
//

import Foundation
import SwiftyJSON

public class MainViewModel {
    static var shared = MainViewModel()
    
    private init() {}
    
    var upcomingMatches = [Match]()
    var currentMatch : Match?
    var currentQRCode : QRCodeContent?
    var currentTicket : Ticket?
    
    func setCurrentMatch(withIndex index: Int) {
        if index >= 0 && index < self.upcomingMatches.count {
             self.currentMatch = self.upcomingMatches[index]
        }
    }
    
    func setCurrentQRCode(_ qrCode: QRCodeContent) {
        self.currentQRCode = qrCode
    }
    
    // MARK: - API
    func getUpcomingMatches(completion: @escaping (Bool, APIError?) -> Void){
        apiService.request(APIService.getUpcomingMatches()) { result in
            switch result {
            case let .success(response):
                let data = response.data
                let statusCode = response.statusCode
                
                if statusCode >= 200 && statusCode <= 300 {
                    let jsonData = JSON(data)
                    let matches = jsonData.arrayValue.map { jsonObject in
                            return Match(jsonObject)
                    }

                    self.upcomingMatches = matches
                    
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
    
    // Sample ticket json string "{\"id\":99,\"number\":0,\"m_id\":98637,\"key\":98720}"
    func verifyTicket(ticketJsonString : String, completion: @escaping (Ticket?, APIError?) -> Void) {
        let matchId = self.currentMatch!.id
        let ticketJSON = JSON.init(parseJSON: ticketJsonString)
        self.currentQRCode = QRCodeContent(ticketJSON)
        
        if let qrCode = self.currentQRCode  {
            apiService.request(APIService.verifyTicket(matchId, qrCode)) { result in
                switch result {
                case let .success(response):
                    let data = response.data
                    let statusCode = response.statusCode
                    let jsonData = JSON(data)
                    
                    if statusCode >= 200 && statusCode <= 300 {
                        let ticket = Ticket(jsonData)
                        self.currentTicket = ticket
                        
                        completion(ticket, nil)
                    } else {
                        let requestError = APIError(statusCode, errorData: jsonData)
                        completion(nil, requestError)
                    }
                    break
                case let .failure(error):
                    var requestError = APIError()
                    requestError.message = error.errorDescription
                    completion(nil, requestError)
                    break
                }
            }
        }
    }
    
    func purchaseTicket(completion: @escaping (Bool, APIError?) -> Void){
        if let ticket = self.currentTicket, let qrCode = self.currentQRCode {
            let id = String(qrCode.id)
            let paidValue = ticket.orderPrice
            
            apiService.request(APIService.purchaseTicket(id, paidValue)) { result in
                switch result {
                case let .success(response):
                    let data = response.data
                    let statusCode = response.statusCode
                    
                    if statusCode >= 200 && statusCode <= 300 {
                        let jsonData = JSON(data)
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
    
    func getConversionRateP2M(completion: @escaping (ConversionRateP2M?, APIError?) -> Void){
        apiService.request(APIService.getRateP2M()) { result in
            switch result {
            case let .success(response):
                let data = response.data
                let statusCode = response.statusCode
                
                if statusCode >= 200 && statusCode <= 300 {
                    let jsonData = JSON(data)
                    let rate = ConversionRateP2M(jsonData["data"])
                    
                    completion(rate, nil)
                } else {
                    let requestError = APIError(statusCode)
                    completion(nil, requestError)
                }
                break
            case let .failure(error):
                var requestError = APIError()
                requestError.message = error.errorDescription
                completion(nil, requestError)
                break
            }
        }
    }
    
    func purchaseLoyaltyPointTicket(completion: @escaping (Bool, APIError?) -> Void){
        if let ticket = self.currentTicket, let qrCode = self.currentQRCode {
            let orderId = String(ticket.orderId)
            let customerId = String(qrCode.customerId)
            
            apiService.request(APIService.purchaseLoyaltyPointTicket(customerId, orderId)) { result in
                switch result {
                case let .success(response):
                    let data = response.data
                    let statusCode = response.statusCode
                    let jsonData = JSON(data)
                    
                    if statusCode >= 200 && statusCode <= 300 {
                        completion(true, nil)
                    } else {
                        let requestError = APIError(statusCode, errorData: jsonData)
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
    
    func purchaseMerchandiseWithPoint(_ point: Int, completion: @escaping (Bool, APIError?) -> Void){
        if let qrCode = self.currentQRCode {
            let customerId = String(qrCode.customerId)
            
            apiService.request(APIService.purchaseMerchandise(point, customerId)) { result in
                switch result {
                case let .success(response):
                    let data = response.data
                    let statusCode = response.statusCode
                    let jsonData = JSON(data)
                    
                    if statusCode >= 200 && statusCode <= 300 {
                        completion(true, nil)
                    } else {
                        let requestError = APIError(statusCode, errorData: jsonData)
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
}
