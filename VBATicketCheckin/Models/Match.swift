//
//  Match.swift
//  VBATicketCheckin
//
//  Created by Bui Minh Duc on 11/21/17.
//  Copyright © 2017 Dinosys. All rights reserved.
//

import Foundation
import SwiftyJSON

//{
//    "id" : 16,
//    "home_team_id" : 4,
//    "away_team_id" : 1,
//    "home_team_score" : 0,
//    "active" : true,
//    "created_at" : "2017-11-20T10:41:54+07:00",
//    "stadium_id" : 4,
//    "start_time" : "2017-11-30T10:41:00+07:00",
//    "season_id" : null,
//    "away_team_score" : 0,
//    "updated_at" : "2017-11-20T10:41:54+07:00",
//    "round" : "",
//    "name" : "Saigon Heat vs Hanoi Buffaloes"
//}

struct Match {
    let id: Int
    let name: String
    let startTime: String
    //let homeTeamId: Int
    //let awayTeamId: Int
    //let homeTeamScore: Int
    //let awayTeamScore: Int
    //let active: Bool
    //let stadiumId: Int
    //let seasonId: Int?
    //let round: String
    //let startTime: String
    //let createdTime: String
    //let updatedTime: String
    
    init(_ jsonData: JSON) {
        id = jsonData["id"].intValue
        name = jsonData["name"].stringValue
        startTime = jsonData["start_time"].stringValue
    }    
}
