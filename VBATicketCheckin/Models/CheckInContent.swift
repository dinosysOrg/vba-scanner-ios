//
//  QRCodeTicket.swift
//  VBATicketCheckin
//
//  Created by Bui Minh Duc on 11/21/17.
//  Copyright © 2017 Dinosys. All rights reserved.
//

import Foundation
import SwiftyJSON

struct QRCodeTicket {
    private var matchId: String
    let id: String
    let mId: String
    let key: String
    
    init(_ jsonData: JSON) {
        id = jsonData["id"].stringValue
        mId = jsonData["m_id"].stringValue
        key = jsonData["name"].stringValue
    }
    
    mutating func setMatchId(matchId: String) {
        self.matchId = matchId
    }
}
