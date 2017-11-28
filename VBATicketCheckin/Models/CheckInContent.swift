//
//  QRCodeTicket.swift
//  VBATicketCheckin
//
//  Created by Bui Minh Duc on 11/21/17.
//  Copyright © 2017 Dinosys. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct CheckInContent {
    let id: Int
    let mId: Int
    let key: Int
    
    init(_ jsonData: JSON) {
        id = jsonData["id"].intValue
        mId = jsonData["m_id"].intValue
        key = jsonData["key"].intValue
    }
}
