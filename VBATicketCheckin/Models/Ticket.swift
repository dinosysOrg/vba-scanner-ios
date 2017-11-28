//
//  Ticket.swift
//  VBATicketCheckin
//
//  Created by Bui Minh Duc on 11/21/17.
//  Copyright © 2017 Dinosys. All rights reserved.
//

import Foundation
import SwiftyJSON


public enum TicketStatusType : String {
    case unuse = "Unused"
    case used = "Used"
}
//{
//    "away_team" : "Hanoi Buffaloes",
//    "start_time" : 1512013260,
//    "order_id" : 99,
//    "use_status=" : "Unused",
//    "kind" : "sell",
//    "name" : "Chương Hồ",
//    "phone" : null,
//    "ticket_type" : "VIP B",
//    "quantity" : 1,
//    "order_price" : "500000.0",
//    "paid" : false,
//    "home_team" : "Saigon Heat"
//}

struct Ticket {
    let orderId: Int
    let orderPrice: String
    let quantity: Int
    let kind: String
    let paid: Bool
    let ticketType: String
    let name: String
    let used: Bool
    
    init(_ jsonData: JSON) {
        orderId = jsonData["order_id"].intValue
        orderPrice = jsonData["order_price"].stringValue
        quantity = jsonData["quantity"].intValue
        kind = jsonData["kind"].stringValue
        paid = jsonData["paid"].boolValue
        ticketType = jsonData["ticket_type"].stringValue
        name = jsonData["name"].stringValue
        let status = jsonData["use_status="].stringValue
        used = status == "Used" ? true : false
    }
}

