//
//  CustomLayer.swift
//  VBATicketCheckin
//
//  Created by ngoclam on 3/7/18.
//  Copyright © 2018 Dinosys. All rights reserved.
//

import Foundation
import UIKit

extension CALayer {
    
    func setBorder(_ border: CGFloat, color: CGColor?) {
        self.borderWidth = border
        self.borderColor = color
    }
    
    func setCornerRadius(_ cornerRadius: CGFloat, border: CGFloat, color: CGColor?) {
        self.cornerRadius = cornerRadius
        self.borderWidth = border
        self.borderColor = color
    }
}
