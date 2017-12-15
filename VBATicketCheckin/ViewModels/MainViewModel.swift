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
    
    var upcomingMatches = [Match]()
    
    var selectedMatch : Match?
    
    var currentQRCode : CheckInContent?
    
    var currentTicket : Ticket?
    
    func setSelectedMatchWith(index: Int) {
        if index >= 0 && index < self.upcomingMatches.count {
             self.selectedMatch = self.upcomingMatches[index]
        }
    }
    
    func getUpcomingMatches(completion: @escaping (Bool, APIError?) -> Void){
        ticketCheckInAPIProvider.request(TicketCheckInAPI.getUpcomingMatches()) { result in
            switch result {
            case let .success(response):
                let data = response.data
                let statusCode = response.statusCode
                
                if statusCode == 200 {
                    let jsonData = JSON(data)
                    
                    let matches = jsonData.arrayValue
                        .map { jsonObject in
                            return Match(jsonObject)
                    }

                    self.upcomingMatches = matches
                    
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
    
    //Sample ticket json string "{\"id\":99,\"number\":0,\"m_id\":98637,\"key\":98720}"
    func verifyTicket(ticketJsonString : String, completion: @escaping (Ticket?, APIError?) -> Void){
        
        let matchId = self.selectedMatch!.id
                
        let ticketJSON = JSON.init(parseJSON: ticketJsonString)
        
        self.currentQRCode = CheckInContent(ticketJSON)
        
        if let qrCode = self.currentQRCode  {
            ticketCheckInAPIProvider.request(TicketCheckInAPI.verifyTicket(matchId, qrCode)) { result in
                switch result {
                case let .success(response):
                    let data = response.data
                    let statusCode = response.statusCode
                    
                    if statusCode == 200 {
                        let jsonData = JSON(data)
                        
                        let ticket = Ticket(jsonData)
                        
                        completion(ticket, nil)
                    } else {
                        let apiError = APIError(statusCode)
                        completion(nil, apiError)
                    }
                    break
                case let .failure(error):
                    var apiError = APIError()
                    apiError.message = error.errorDescription
                    completion(nil, apiError)
                    break
                }
            }
        }
    }
    
    func purchaseTicket(completion: @escaping (Bool, APIError?) -> Void){
        if let ticketInfo = self.currentTicket, let qrCode = self.currentQRCode {
            let id = String(qrCode.id)
            let paidValue = Double(ticketInfo.orderPrice)
            
            ticketCheckInAPIProvider.request(TicketCheckInAPI.purchaseTicket(id, paidValue!)) { result in
                switch result {
                case let .success(response):
                    let data = response.data
                    let statusCode = response.statusCode
                    
                    if statusCode == 200 {
                        let jsonData = JSON(data)
                        
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
}
