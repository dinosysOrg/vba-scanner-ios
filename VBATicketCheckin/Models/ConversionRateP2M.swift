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
        money = jsonData["money"].intValue
        point = jsonData["point"].intValue
    }
}
