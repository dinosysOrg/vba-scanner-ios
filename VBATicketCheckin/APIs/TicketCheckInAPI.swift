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
    
    if User.sharedInstance.IsAuthorized {
        let token = User.sharedInstance.AccessToken
        return defaultEndpoint.adding(newHTTPHeaderFields: ["Accept":"application/json", "token": token!])
    }
    
    return defaultEndpoint
}

let ticketCheckInAPIProvider = MoyaProvider<TicketCheckInAPI>(endpointClosure: ticketCheckInAPIEndpointClosure)

// MARK: - Provider support
//Delcaration of Ticket Checkin APIs
public enum TicketCheckInAPI  {
    case login(String) //Signin with google access token
    case getUpcomingMatches() //Get upcoming matches
    case verifyTicket(Int, CheckInContent) //Verify ticket
    case purchaseTicket(String,Double) //Purchase unpaid ticket
}

//let endpoint = "http://vba-ticket.herokuapp.com/api"
let endpoint = "https://vba-ticket-production.herokuapp.com/api"
//let endpoint = "https://vba-ticket-staging.herokuapp.com/api"
//let endpoint = "http://09bfb966.ngrok.io/api"

extension TicketCheckInAPI : TargetType {
    
    public var baseURL: URL { return URL(string: endpoint)! }
    
    //Path for each API
    public var path: String {
        switch self {
        case .login(_):
            return "/admins/auth"
        case .getUpcomingMatches():
            return "/matches/upcoming"
        case .verifyTicket(_):
            return "/qrcode/scan"
        case .purchaseTicket(_,_):
            return "/purchase"
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
        case .verifyTicket(let matchId, let checkInContent):
            return [ "match_id" : matchId,
                     "id": checkInContent.id,
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
