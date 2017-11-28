//
//  Error.swift
//  VBATicketCheckin
//
//  Created by Bui Minh Duc on 11/21/17.
//  Copyright © 2017 Dinosys. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum APIErrorType : Int {
    case ok = 200
    case notFound = 404
    case unknown = 999
}

public struct APIError {
    let type: APIErrorType
    
    var message: String? {
        get {
            switch type {
            case .notFound:
                return "Không thể kết nối đến Server"
            default:
                return "Lỗi không xác định"
            }
        }
    }
    
    init(_ statusCode: Int) {
        if let errorType = APIErrorType(rawValue: statusCode) {
            
        } else {
            type = APIErrorType.unknown
        }
    }
}

