//
//  File.swift
//  VBATicketCheckin
//
//  Created by Bui Minh Duc on 11/21/17.
//  Copyright © 2017 Dinosys. All rights reserved.
//

import Foundation
import Moya


let ticketCheckInAPIEndpointClosure = { (target: TicketCheckInAPI) -> Endpoint<TicketCheckInAPI> in
    let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
    return defaultEndpoint.adding(newHTTPHeaderFields: ["token":"KEY_SESSION_TOKEN", "Accept":"application/json"])
}

let ticketCheckInAPIProvider = MoyaProvider<TicketCheckInAPI>(endpointClosure: ticketCheckInAPIEndpointClosure)

// MARK: - Provider support
//Delcaration of Ticket Checkin APIs
public enum TicketCheckInAPI  {
    case login(String) //Signin with google access token
    case getUpcomingMatches() //Get upcoming matches
    case verifyTicket(CheckInContent) //Verify ticket
    case purchaseTicket(String,String) //Purchase unpaid ticket
}

extension TicketCheckInAPI : TargetType {
    public var baseURL: URL { return URL(string: "")! }
    
    //Path for each API
    public var path: String {
        switch self {
        case .login(_):
            return "/api/admins/auth"
        case .getUpcomingMatches():
            return "/api/matches/upcoming"
        case .verifyTicket(_):
            return "/api/qrcode/scan"
        case .purchaseTicket:
            return "/api/purchase"
        }
    }
    
    //HTTP Method for each API
    public var method: Moya.Method {
        switch self {
        case .login(_):
            return .post
        case .getUpcomingMatches():
            return .get
        case .verifyTicket(_):
            return .post
        case .purchaseTicket:
            return .post
        }
    }
    
    //Parameters for each API
    public var parameters: [String: Any]? {
        switch self {
        case .login(let token):
            return ["code": token]
        case .verifyTicket(let checkInContent):
            return ["id": checkInContent.id,
                    "m_id": checkInContent.mId,
                    "key": checkInContent.key]
        case .purchaseTicket(let id, let paidValue):
            return ["id" : id,
                    "paid_value" : paidValue]
        default:
            return nil
        }
    }
    
    public var parameterEncoding: ParameterEncoding {   
        switch self {
        case .verifyTicket(_):
            return JSONEncoding.default
        default:
            return URLEncoding.default
        }
    }
    
    public var task: Task {
        return .request
    }
    
    public var validate: Bool {
        return false
    }
    
    public var sampleData: Data {
        return Data()
    }
}
