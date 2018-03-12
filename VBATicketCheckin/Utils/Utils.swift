//
//  Utils.swift
//  VBATicketCheckin
//
//  Created by ngoclam on 3/6/18.
//  Copyright © 2018 Dinosys. All rights reserved.
//

import Foundation
import UIKit

struct Utils {
    // MARK: - UIViewController
    static func viewController(withIdentifier identifier: String) -> UIViewController {
        return Constants.STORYBOARD.instantiateViewController(withIdentifier: identifier)
    }
    
    // MARK: - Format
    static func setView(_ view: UIView, transparentWith color: UIColor, alpha: CGFloat) {
        view.backgroundColor = UIColor.color(color, alpha: alpha)
        view.isOpaque = false
    }
    
    // MARK: - Validation
    static func isEmpty(_ object: Any?) -> Bool {
        guard let _ = object else {
            return true
        }
        
        if (object as AnyObject).isKind(of: NSNull.classForCoder()) || (object is NSNull) {
            return true
        } else {
            if object is String, let string = (object as? String) {
                if string.isEmpty || (string == Constants.EMPTY_STRING) ||
                    (string.lowercased() == "(null)") || (string.lowercased() == "<null>") || (string.lowercased() == "null") {
                    return true
                }
            }
        }
        
        return false
    }
    
    // MARK: - String
    static func removeWhiteSpaces(of str: String) -> String {
        return str.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Number
    static func thousandedString(from number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = Constants.PERIOD
        formatter.groupingSize = 3
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        
        return formatter.string(from: NSNumber.init(value: number)) ?? Constants.ZERO_STRING
    }
}

