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
    static let shared = MainViewModel()
    private let service = RequestService.shared
    
    var upcomingMatches = [Match]()
    var currentMatch : Match?
    var currentQRCode : QRCodeContent?
    var currentTicket : Ticket?
    
    private init() {}
    
    func setCurrentMatch(withIndex index: Int) {
        if index >= 0 && index < self.upcomingMatches.count {
             self.currentMatch = self.upcomingMatches[index]
        }
    }
    
    func setCurrentQRCode(_ qrCode: QRCodeContent) {
        self.currentQRCode = qrCode
    }
    
    // MARK: - API
    func getUpcomingMatches(completion: ((_ matches: [Match]?, _ error: APIError?) -> Void)?) {
        service.requestGetUpcomingMatches { (array, error) in
            guard let complete = completion else {
                return
            }
            
            if let _ = error {
                complete(nil, error)
            } else {
                self.upcomingMatches = array!.map { json in
                    return Match(json)
                }
                
                complete(self.upcomingMatches, nil)
            }
        }
    }
    
    func scanTicket(_ content: String, completion: ((_ ticket: Ticket?, _ error: APIError?) -> Void)?) {
        let matchId = self.currentMatch!.id
        let ticketJSON = JSON.init(parseJSON: content)
        let ticketQRCode = QRCodeContent(ticketJSON)
        let info: [String : Any] = ["match_id" : matchId, "ticket_qrcode" : ticketQRCode]
        self.currentQRCode = ticketQRCode
        
        service.requestScanTicket(info) { (json, error) in
            guard let complete = completion else {
                return
            }
            
            if let _ = error {
                complete(nil, error)
            } else {
                let ticket = Ticket(json!)
                self.currentTicket = ticket
                
                complete(ticket, nil)
            }
        }
    }
    
    func purchaseTicket(completion: ((_ error: APIError?) -> Void)?) {
        let id = String(self.currentQRCode!.id)
        let paidValue = self.currentTicket!.orderPrice
        let info: [String : Any] = ["id" : id, "paid_value" : paidValue]
        
        service.requestPurchaseTicket(info) { error in
            guard let complete = completion else {
                return
            }
            
            complete(error)
        }
    }
    
    func getConversionRateP2M(completion: ((_ rate: ConversionRateP2M?, _ error: APIError?) -> Void)?) {
        service.requestGetConversionRateP2M { (json, error) in
            guard let complete = completion else {
                return
            }
            
            if let _ = error {
                complete(nil, error)
            } else {
                let rate = ConversionRateP2M(json!)
                let point = LoyaltyPoint(price: self.currentTicket?.orderPrice ?? Constants.DEFAULT_DOUBLE_VALUE, rate: rate)
                self.currentTicket?.orderPoint = point
                complete(rate, nil)
            }
        }
    }
    
    func purchaseTicket(withCustomerId customerId: String, completion: ((_ error: APIError?) -> Void)?) {
        let info: [String : Any] = ["order_id" : String(self.currentTicket!.orderId), "customer_id" : customerId]
        
        service.requestPurchaseTicketWithPoint(info) { error in
            guard let complete = completion else {
                return
            }
            
            complete(error)
        }
    }
    
    func purchaseMerchandise(withPoint point: Int, customerId: String, completion: ((_ error: APIError?) -> Void)?) {
        let info: [String : Any] = ["points" : point, "customer_id" : customerId]
        
        service.requestPurchaseMerchandiseWithPoint(info) { error in
            guard let complete = completion else {
                return
            }
            
            complete(error)
        }
    }
}
