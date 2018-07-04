//
//  ConversionRateP2M.swift
//  VBATicketCheckin
//
//  Created by ngoclam on 3/11/18.
//  Copyright © 2018 Dinosys. All rights reserved.
//

import Foundation
import SwiftyJSON

struct ConversionRateP2M {
    
    let money: Int
    let point: Int
    
    init(_ jsonData: JSON) {
        money = (jsonData["money"].intValue != 0) ? jsonData["money"].intValue : 1
        point = (jsonData["point"].intValue != 0) ? jsonData["point"].intValue : 1
    }
}
