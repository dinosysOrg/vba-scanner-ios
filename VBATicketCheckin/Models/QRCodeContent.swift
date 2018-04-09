//
//  QRCodeContent.swift
//  VBATicketCheckin
//
//  Created by ngoclam on 3/11/18.
//  Copyright © 2018 Dinosys. All rights reserved.
//

import Foundation
import SwiftyJSON

//{
//    "id":2381,
//    "number":1,
//    "hash_key":"WqLi4BbgddIuduqD+s85Vw=="
//}

struct QRCodeContent {
    let customerId: String
    let id: Int
    let orderId: Int
    let number: Int
    let hashKey: String
    
    init(_ jsonData: JSON) {
        // This variable used for customer qrcode scanning
        customerId = jsonData["customer_id"].stringValue
        // These variables used for ticket qrcode scanning
        id = jsonData["id"].intValue
        orderId = jsonData["order_id"].intValue
        number = jsonData["number"].intValue
        hashKey = jsonData["hash_key"].stringValue
    }
}
