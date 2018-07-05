//
//  MainViewModel.swift
//  VBATicketCheckin
//
//  Created by Bui Minh Duc on 11/22/17.
//  Copyright © 2017 Dinosys. All rights reserved.
//

import Foundation
import SwiftyJSON

enum TicketScanningType {
    case checkIn
    case payment
}

public class MainViewModel {
    
    static let shared = MainViewModel()
    
    var upcomingMatches = [Match]()
    var currentMatch : Match?
    var currentQRCode : QRCodeContent?
    var currentTicket : Ticket?
    var purchaseSucceed = false
    var ticketScanningType = TicketScanningType.checkIn
    var cameraPermissionGranted = false
    
    private let _service = RequestService.shared
    
    private init() {}
    
    func setCurrentMatch(withIndex index: Int) {
        if index >= 0 && index < self.upcomingMatches.count {
             self.currentMatch = self.upcomingMatches[index]
        }
    }
    
    func setCurrentQRCode(_ qrCode: QRCodeContent) {
        self.currentQRCode = qrCode
    }
    
    func setCurrentTicket(_ ticket: Ticket?) {
        self.currentTicket = ticket
    }
    
    func setTicketScanningType(_ type: TicketScanningType) {
        self.ticketScanningType = type
    }
    
    func setCameraPermissionGranted(_ granted: Bool) {
        self.cameraPermissionGranted = granted
    }
}

//
// MARK: - API Request
//
extension MainViewModel {
    
    func getUpcomingMatches(completion: ((_ matches: [Match]?, _ error: APIError?) -> Void)?) {
        self._service.requestGetUpcomingMatches { (array, error) in
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
    
    func scanTicket(content: String, type: TicketScanningType, completion: ((_ ticket: Ticket?, _ error: APIError?) -> Void)?) {
        let matchId = self.currentMatch!.id
        let ticketJSON = JSON.init(parseJSON: content)
        let ticketQRCode = QRCodeContent(ticketJSON)
        let info: [String : Any] = ["match_id" : matchId, "ticket_qrcode" : ticketQRCode]
        self.currentQRCode = ticketQRCode
        
        self._service.requestScanTicket(info: info, type: type) { (json, error) in
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
        
        self._service.requestPurchaseTicket(info) { error in
            guard let complete = completion else {
                return
            }
            
            self.purchaseSucceed = (error == nil)
            self.currentTicket = (error == nil) ? nil : self.currentTicket
            
            complete(error)
        }
    }
    
    func getConversionRateP2M(completion: ((_ rate: ConversionRateP2M?, _ error: APIError?) -> Void)?) {
        self._service.requestGetConversionRateP2M { (json, error) in
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
        
        self._service.requestPurchaseTicketWithPoint(info) { error in
            guard let complete = completion else {
                return
            }
            
            self.purchaseSucceed = (error == nil)
            self.currentTicket = (error == nil) ? nil : self.currentTicket
            
            complete(error)
        }
    }
    
    func purchaseMerchandise(withPoint point: Int, customerId: String, completion: ((_ error: APIError?) -> Void)?) {
        let info: [String : Any] = ["points" : point, "customer_id" : customerId]
        
        self._service.requestPurchaseMerchandiseWithPoint(info) { error in
            guard let complete = completion else {
                return
            }
            
            complete(error)
        }
    }
}
