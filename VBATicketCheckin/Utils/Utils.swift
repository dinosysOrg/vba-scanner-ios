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
    
    //
    // MARK: - UIViewController
    //
    static func popUpAlertWindow() -> UIWindow {
        let window = UIWindow(frame: Utils.Device.bounds)
        window.backgroundColor = UIColor.clear
        window.windowLevel = UIWindowLevelAlert
        window.rootViewController = UIViewController()
        window.makeKeyAndVisible()
        
        return window
    }
    
    static func viewController(withIdentifier identifier: String) -> UIViewController {
        return Constants.STORYBOARD.instantiateViewController(withIdentifier: identifier)
    }
    
    //
    // MARK: - Format
    //
    static func setView(_ view: UIView, transparentWith color: UIColor, alpha: CGFloat) {
        view.backgroundColor = UIColor.color(color, alpha: alpha)
        view.isOpaque = false
    }
    
    //
    // MARK: - Validation
    //
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
    
    //
    // MARK: - String
    //
    static func removeWhiteSpaces(of str: String) -> String {
        return str.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    static func isNumeric(_ string: String) -> Bool {
        let scanner = Scanner(string: string)
        var intNumber = 0
        
        return scanner.scanInt(&intNumber) && scanner.isAtEnd
    }
    
    static func isBackSpace(_ str: String) -> Bool {
        let char = str.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        
        return isBackSpace == -92
    }
    
    static func attributedString(_ formattedStr: String, in str: String, font: UIFont = UIFont.bold.XL, color: UIColor = UIColor.gunmetal) -> NSAttributedString {
        let attributedStr = NSMutableAttributedString(string: str, attributes: [.foregroundColor : UIColor.gunmetal,
                                                                                .font : UIFont.regular.XL])
        let formattedRange = (str as NSString).range(of: formattedStr, options: .caseInsensitive)
        attributedStr.addAttribute(.foregroundColor, value: color, range: formattedRange)
        attributedStr.addAttribute(.font, value: font, range: formattedRange)
        
        return attributedStr
    }
    
    static func appendStrings(_ strings: [String], separatedBy separated: String = Constants.WHITE_SPACE) -> String {
        var result = Constants.EMPTY_STRING
        
        for string in strings {
            result += string + separated
        }
        
        return result
    }
    
    static func appendAttributedStrings(_ attributedStrings: [NSAttributedString], separatedBy separated: String = Constants.WHITE_SPACE) -> NSAttributedString {
        let result = NSMutableAttributedString()
        let separatedString = NSAttributedString(string: separated)
        
        for attributed in attributedStrings {
            result.append(attributed)
            result.append(separatedString)
        }
        
        return result
    }
    
    //
    // MARK: - Number
    //
    static func thousandedString(from number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = Constants.PERIOD
        formatter.groupingSize = 3
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        
        return formatter.string(from: NSNumber.init(value: number)) ?? Constants.ZERO_STRING
    }
    
    //
    // MARK: - Device
    //
    struct Device {
        static var bounds: CGRect {
            get {
                return UIScreen.main.bounds
            }
        }
        
        static var size: CGSize {
            get {
                return UIScreen.main.bounds.size
            }
        }
        
        static var isPad: Bool {
            get {
                return Constants.CURRENT_DEVICE == .pad
            }
        }
        
        static var name: String {
            get {
                var size = 0
                sysctlbyname("hw.machine", nil, &size, nil, 0)
                var machine = [CChar](repeating: 0, count: Int(size))
                sysctlbyname("hw.machine", &machine, &size, nil, 0)
                let code = String(cString: machine)
                
                let deviceCodeDic = [
                    /* Simulator */
                    "i386"      :"Simulator",
                    "x86_64"    :"Simulator",
                    /* iPod */
                    "iPod1,1"   :"iPod Touch 1st",            // iPod Touch 1st Generation
                    "iPod2,1"   :"iPod Touch 2nd",            // iPod Touch 2nd Generation
                    "iPod3,1"   :"iPod Touch 3rd",            // iPod Touch 3rd Generation
                    "iPod4,1"   :"iPod Touch 4th",            // iPod Touch 4th Generation
                    "iPod5,1"   :"iPod Touch 5th",            // iPod Touch 5th Generation
                    "iPod7,1"   :"iPod Touch 6th",            // iPod Touch 6th Generation
                    /* iPhone */
                    "iPhone1,1"   :"iPhone 2G",                 // iPhone 2G
                    "iPhone1,2"   :"iPhone 3G",                 // iPhone 3G
                    "iPhone2,1"   :"iPhone 3GS",                // iPhone 3GS
                    "iPhone3,1"   :"iPhone 4",                  // iPhone 4 GSM
                    "iPhone3,2"   :"iPhone 4",                  // iPhone 4 GSM 2012
                    "iPhone3,3"   :"iPhone 4",                  // iPhone 4 CDMA For Verizon,Sprint
                    "iPhone4,1"   :"iPhone 4S",                 // iPhone 4S
                    "iPhone5,1"   :"iPhone 5",                  // iPhone 5 GSM
                    "iPhone5,2"   :"iPhone 5",                  // iPhone 5 Global
                    "iPhone5,3"   :"iPhone 5c",                 // iPhone 5c GSM
                    "iPhone5,4"   :"iPhone 5c",                 // iPhone 5c Global
                    "iPhone6,1"   :"iPhone 5s",                 // iPhone 5s GSM
                    "iPhone6,2"   :"iPhone 5s",                 // iPhone 5s Global
                    "iPhone7,1"   :"iPhone 6 Plus",             // iPhone 6 Plus
                    "iPhone7,2"   :"iPhone 6",                  // iPhone 6
                    "iPhone8,1"   :"iPhone 6S",                 // iPhone 6S
                    "iPhone8,2"   :"iPhone 6S Plus",            // iPhone 6S Plus
                    "iPhone8,4"   :"iPhone SE" ,                // iPhone SE
                    "iPhone9,1"   :"iPhone 7",                  // iPhone 7 A1660,A1779,A1780
                    "iPhone9,3"   :"iPhone 7",                  // iPhone 7 A1778
                    "iPhone9,2"   :"iPhone 7 Plus",             // iPhone 7 Plus A1661,A1785,A1786
                    "iPhone9,4"   :"iPhone 7 Plus",             // iPhone 7 Plus A1784
                    "iPhone10,1"  :"iPhone 8",                  // iPhone 8 A1863,A1906,A1907
                    "iPhone10,4"  :"iPhone 8",                  // iPhone 8 A1905
                    "iPhone10,2"  :"iPhone 8 Plus",             // iPhone 8 Plus A1864,A1898,A1899
                    "iPhone10,5"  :"iPhone 8 Plus",             // iPhone 8 Plus A1897
                    "iPhone10,3"  :"iPhone X",                  // iPhone X A1865,A1902
                    "iPhone10,6"  :"iPhone X",                  // iPhone X A1901
                    
                    /* iPad */
                    "iPad1,1"   :"iPad 1 ",                   // iPad 1
                    "iPad2,1"   :"iPad 2 WiFi",               // iPad 2
                    "iPad2,2"   :"iPad 2 Cell",               // iPad 2 GSM
                    "iPad2,3"   :"iPad 2 Cell",               // iPad 2 CDMA (Cellular)
                    "iPad2,4"   :"iPad 2 WiFi",               // iPad 2 Mid2012
                    "iPad2,5"   :"iPad Mini WiFi",            // iPad Mini WiFi
                    "iPad2,6"   :"iPad Mini Cell",            // iPad Mini GSM (Cellular)
                    "iPad2,7"   :"iPad Mini Cell",            // iPad Mini Global (Cellular)
                    "iPad3,1"   :"iPad 3 WiFi",               // iPad 3 WiFi
                    "iPad3,2"   :"iPad 3 Cell",               // iPad 3 CDMA (Cellular)
                    "iPad3,3"   :"iPad 3 Cell",               // iPad 3 GSM (Cellular)
                    "iPad3,4"   :"iPad 4 WiFi",               // iPad 4 WiFi
                    "iPad3,5"   :"iPad 4 Cell",               // iPad 4 GSM (Cellular)
                    "iPad3,6"   :"iPad 4 Cell",               // iPad 4 Global (Cellular)
                    "iPad4,1"   :"iPad Air WiFi",             // iPad Air WiFi
                    "iPad4,2"   :"iPad Air Cell",             // iPad Air Cellular
                    "iPad4,3"   :"iPad Air China",            // iPad Air ChinaModel
                    "iPad4,4"   :"iPad Mini 2 WiFi",          // iPad mini 2 WiFi
                    "iPad4,5"   :"iPad Mini 2 Cell",          // iPad mini 2 Cellular
                    "iPad4,6"   :"iPad Mini 2 China",         // iPad mini 2 ChinaModel
                    "iPad4,7"   :"iPad Mini 3 WiFi",          // iPad mini 3 WiFi
                    "iPad4,8"   :"iPad Mini 3 Cell",          // iPad mini 3 Cellular
                    "iPad4,9"   :"iPad Mini 3 China",         // iPad mini 3 ChinaModel
                    "iPad5,1"   :"iPad Mini 4 WiFi",          // iPad Mini 4 WiFi
                    "iPad5,2"   :"iPad Mini 4 Cell",          // iPad Mini 4 Cellular
                    "iPad5,3"   :"iPad Air 2 WiFi",           // iPad Air 2 WiFi
                    "iPad5,4"   :"iPad Air 2 Cell",           // iPad Air 2 Cellular
                    "iPad6,3"   :"iPad Pro 9.7inch WiFi",     // iPad Pro 9.7inch WiFi
                    "iPad6,4"   :"iPad Pro 9.7inch Cell",     // iPad Pro 9.7inch Cellular
                    "iPad6,7"   :"iPad Pro 12.9inch WiFi",    // iPad Pro 12.9inch WiFi
                    "iPad6,8"   :"iPad Pro 12.9inch Cell"]    // iPad Pro 12.9inch Cellular
                
                if let deviceName = deviceCodeDic[code] {
                    return deviceName
                } else {
                    if code.range(of: "iPod") != nil {
                        return "iPod Touch"
                    } else if code.range(of: "iPad") != nil {
                        return "iPad"
                    } else if code.range(of: "iPhone") != nil {
                        return "iPhone"
                    } else {
                        return "unknownDevice"
                    }
                }
            }
        }
    }
    
    //
    // MARK: - Date & Time
    //
    static func dateOfCurrentTimeZone(fromTimeString string: String, format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = format
        formatter.timeZone = .current
        
        return formatter.date(from: string)
    }
    
    static func date(fromTimeString string: String, format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return formatter.date(from: string)
    }
    
    static func timeStringOfCurrentTimeZone(fromDate date: Date, format: String) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = .current
        
        return formatter.string(from: date)
    }
    
    static func timeString(fromDate date: Date, format: String) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return formatter.string(from: date)
    }
}

