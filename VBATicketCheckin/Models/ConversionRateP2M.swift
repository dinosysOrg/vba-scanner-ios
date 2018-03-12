//
//  ConversionRateP2M.swift
//  VBATicketCheckin
//
//  Created by ngoclam on 3/11/18.
//  Copyright © 2018 Dinosys. All rights reserved.
//

import Foundation
import SwiftyJSON

// {
//   "data": {
//       "id": 1,
//       "code": "P2M",
//       "description": "For each point , user can get 3k",
//       "money": 3000,
//       "point": 1,
//       "active": true,
//       "created_at": "2018-01-31T16:35:07+07:00",
//       "updated_at": "2018-01-31T16:35:07+07:00"
//   }
// }

struct ConversionRateP2M {
    let money: Int
    let point: Int
    
    init(_ jsonData: JSON) {
        money = jsonData["money"].intValue
        point = jsonData["point"].intValue
    }
}
