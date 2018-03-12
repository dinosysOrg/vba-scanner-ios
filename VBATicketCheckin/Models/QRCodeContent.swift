//
//  QRCodeContent.swift
//  VBATicketCheckin
//
//  Created by ngoclam on 3/11/18.
//  Copyright © 2018 Dinosys. All rights reserved.
//

import Foundation
import SwiftyJSON

struct QRCodeContent {
    let customerId: String
    let id: Int
    let mId: Int
    let key: Int
    
    init(_ jsonData: JSON) {
        customerId = jsonData["customer_id"].stringValue
        id = jsonData["id"].intValue
        mId = jsonData["m_id"].intValue
        key = jsonData["key"].intValue
    }
}
