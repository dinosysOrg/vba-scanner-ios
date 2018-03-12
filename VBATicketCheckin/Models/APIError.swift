//
//  Error.swift
//  VBATicketCheckin
//
//  Created by Bui Minh Duc on 11/21/17.
//  Copyright © 2017 Dinosys. All rights reserved.
//

import Foundation
import SwiftyJSON

enum TicketErrorType: Int {
    case used = 1
    case invalidQRCode = 2
    case invalidMatch = 3
    case notFound = -1
}

enum APIErrorType: Int {
    case ok = 200
    case ticketError = 400
    case tokenExpired = 403
    case notEnoughPoint = 422
    case internalServer = 500
    case unknown = 999
}

//▿ {
//    "error" : {
//        "message" : "invalid qr code",
//        "code" : 2
//    }
//}

//▿ {
//    "error" : {
//        "message" : "invalid match",
//        "code" : 3
//    }
//}

struct APIError {
    private var _message: String? = "Lỗi không xác định."
    
    private var ticketErrorType: TicketErrorType?
    let type: APIErrorType
    var message: String? {
        get {
            switch type {
            case .ticketError:
                guard let ticketError = ticketErrorType else {
                    return _message
                }
                
                switch ticketError {
                case .used:
                    return "Vé đã được sử dụng."
                case .invalidQRCode:
                    return "Mã QR không hợp lệ."
                case .invalidMatch:
                    return "Check-in không đúng trận đấu."
                default:
                    return _message
                }
            case .tokenExpired:
                return "Phiên làm việc hết hạn. Vui lòng đăng nhập lại."
            case .notEnoughPoint:
                return "Người dùng không đủ điểm để thanh toán."
            case .internalServer:
                return "Lỗi máy chủ."
            default:
                return _message
            }
        }
        set {
            _message = newValue
        }
    }
    
    init() {
        type = APIErrorType.unknown
    }
    
    init(_ statusCode: Int) {
        if let errorType = APIErrorType(rawValue: statusCode) {
            type = errorType
        } else {
            type = APIErrorType.unknown
        }
    }
    
    init(_ statusCode: Int, errorData: JSON) {
        if let errorType = APIErrorType(rawValue: statusCode) {
            type = errorType
            
            if let ticketError = TicketErrorType(rawValue: (errorData["error"])["code"].intValue) {
                ticketErrorType = ticketError
            }
        } else {
            type = APIErrorType.unknown
        }
    }
}

