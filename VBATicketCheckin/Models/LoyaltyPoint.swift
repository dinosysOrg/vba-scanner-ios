//
//  LoyaltyPoint.swift
//  VBATicketCheckin
//
//  Created by ngoclam on 3/11/18.
//  Copyright © 2018 Dinosys. All rights reserved.
//

import Foundation

struct LoyaltyPoint {
    let value: Int
    var price: Double?
    var conversionRate: ConversionRateP2M?
    
    init(_ value: Int) {
        self.value = value
    }
    
    init(price: Double, rate: ConversionRateP2M) {
        self.price = price
        self.conversionRate = rate
        self.value = Int(ceil(price * Double(rate.point) / Double(rate.money)))
    }
}
