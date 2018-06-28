//
//  Match.swift
//  VBATicketCheckin
//
//  Created by Bui Minh Duc on 11/21/17.
//  Copyright © 2017 Dinosys. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Match {
    
    let id: Int
    let name: String
    let startTime: String
    
    init(_ jsonData: JSON) {
        id = jsonData["id"].intValue
        name = jsonData["name"].stringValue
        startTime = jsonData["start_time"].stringValue
    }    
}
