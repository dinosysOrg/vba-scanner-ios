//
//  File.swift
//  VBATicketCheckin
//
//  Created by Bui Minh Duc on 11/21/17.
//  Copyright © 2017 Dinosys. All rights reserved.
//

import Foundation
import Moya

let serviceEndpointClosure = { (target: APIService) -> Endpoint in
    let defaultEndpoint = MoyaProvider<APIService>.defaultEndpointMapping(for: target)
    
    if User.authorized {
        let token = User.current?.accessToken
        return defaultEndpoint.adding(newHTTPHeaderFields: ["Accept":"application/json", "token": token!])
    }
    
    return defaultEndpoint
}

let provider = MoyaProvider<APIService>(endpointClosure: serviceEndpointClosure)

// MARK: - Provider support
// Delcaration of Ticket Checkin APIs
enum APIService  {
    case login(String) // Signin with google access token
    case getUpcomingMatches() // Get upcoming matches
    case scanTicket(Int, QRCodeContent) // Verify ticket (Could scan for payment and checkin)
    case scanTicketPayment(Int, QRCodeContent) // Scan ticket payment (Only scan for payment)
    case purchaseTicket(String, Double) // Purchase unpaid ticket
    case getRateP2M() // Get conversion rate for changing order price --> loyalty point
    case purchaseTicketWithPoint(String, String) // Purchase ticket with loyalty point
    case purchaseMerchandise(Int, String) // Purchase merchandise with loyalty point
}

enum BaseUrlType: String {
    case local = "http://192.168.4.87:3000/api"
    case debug = ""
    case staging = "https://vba-ticket-staging.herokuapp.com/api"
    case product = "https://vba-ticket-production.herokuapp.com/api"
}

// https://github.com/Moya/Moya/tree/master/docs/MigrationGuides
extension APIService : TargetType {
    var headers: [String : String]? {
        return ["Content-Type" : "application/json"]
    }
    
    public var baseURL: URL {
        return URL(string: BaseUrlType.staging.rawValue)!
    }
    
    // Path for each API
    public var path: String {
        switch self {
        case .login(_):
            return "/admins/auth"
        case .getUpcomingMatches():
            return "/matches/upcoming"
        case .scanTicket(_,_):
            return "/qrcode/scan"
        case .scanTicketPayment(_,_):
            return "/qrcode_payment/scan"
        case .purchaseTicket(_,_):
            return "/purchase"
        case .getRateP2M():
            return "/p2m"
        case .purchaseTicketWithPoint(_,_):
            return "/orders/point_paid_scanner"
        case .purchaseMerchandise(_,_):
            return "/purchase_merchandise"
        }
    }
    
    // HTTP Method for each API
    public var method: Moya.Method {
        switch self {
        case .getUpcomingMatches(), .getRateP2M():
            return .get
        default:
            return .post
        }
    }
    
    // Parameters & ParameterEncoding of request
    public var task: Task {
        switch self {
        case .login(let token):
            let params = ["code": token]
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        case .scanTicket(let matchId, let qrCodeContent), .scanTicketPayment(let matchId, let qrCodeContent):
            let params: [String : Any] = ["match_id" : matchId,
                                          "id": qrCodeContent.id,
                                          "hash_key": qrCodeContent.hashKey]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .purchaseTicket(let id, let paidValue):
            let params: [String : Any] = ["id" : id,
                                          "paid_value" : paidValue]
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        case .purchaseTicketWithPoint(let customerId, let orderId):
            let params: [String : Any] = ["customer_id" : customerId,
                                          "order_id" : orderId]
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        case .purchaseMerchandise(let points, let customerId):
            let params: [String : Any] = ["customer_id" : customerId,
                                          "points" : points]
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        default:
            return .requestPlain
        }
    }
    
    public var validationType: ValidationType {
        return .none
    }
    
    public var sampleData: Data {
        return Data()
    }
}

