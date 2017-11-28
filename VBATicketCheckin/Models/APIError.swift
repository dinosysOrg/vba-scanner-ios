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
    case invalidTicked = 400
    case tokenExpired = 403
    case unknown = 999
}

public struct APIError {
    let type: APIErrorType
    
    private var _message: String? = "Lỗi không xác định."
    
    public var message: String? {
        get {
            switch type {
            case .invalidTicked:
                return "Vé đã được sử dụng."
            case .tokenExpired:
                return "Phiên làm việc hết hạn. Vui lòng đăng nhập lại."
            default:
                return _message
            }
        }
        set {
            _message = newValue
        }
    }
    
    init(){
        type = APIErrorType.unknown
    }
    
    init(_ statusCode: Int) {
        if let errorType = APIErrorType(rawValue: statusCode) {
            type = errorType
        } else {
            type = APIErrorType.unknown
        }
    }
}

