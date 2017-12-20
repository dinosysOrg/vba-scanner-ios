//
//  DateTime+Extension.swift
//  VBATicketCheckin
//
//  Created by Bui Minh Duc on 11/23/17.
//  Copyright © 2017 Dinosys. All rights reserved.
//

import Foundation

extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
}

extension Date {
    
    //Converter
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
    
    //Display
    var matchTime: String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "dd-MM-yyyy, HH:mm"
        
        return dateFormatter.string(from: self)
    }
}

extension String {
    var dateFromISO8601: Date? {
        return Formatter.iso8601.date(from: self)   // "Mar 22, 2017, 10:22 AM"
    }
}

