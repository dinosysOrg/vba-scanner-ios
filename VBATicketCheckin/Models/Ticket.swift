//
//  Ticket.swift
//  VBATicketCheckin
//
//  Created by Bui Minh Duc on 11/21/17.
//  Copyright © 2017 Dinosys. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Ticket {
    
    let orderId: Int
    let orderPrice: Double
    let displayedPrice: String
    let quantity: Int
    let kind: String
    let paid: Bool
    let type: String
    let name: String
    let used: Bool
    let match: String
    var orderPoint: LoyaltyPoint?
    
    init(_ jsonData: JSON) {
        orderId = jsonData["order_id"].intValue
        orderPrice = Double(jsonData["order_price"].stringValue) ?? 0.0
        displayedPrice = Utils.thousandedString(from: orderPrice)
        quantity = jsonData["quantity"].intValue
        kind = jsonData["kind"].stringValue
        paid = jsonData["paid"].boolValue
        type = jsonData["ticket_type"].stringValue
        name = jsonData["name"].stringValue
        let status = jsonData["use_status="].stringValue
        used = status == "Used" ? true : false
        match = jsonData["home_team"].stringValue + " vs " + jsonData["away_team"].stringValue
    }
}

