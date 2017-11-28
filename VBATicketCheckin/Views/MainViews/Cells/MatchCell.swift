//
//  MatchCell.swift
//  VBATicketCheckin
//
//  Created by Bui Minh Duc on 11/23/17.
//  Copyright © 2017 Dinosys. All rights reserved.
//

import UIKit

class MatchCell: UITableViewCell {
    
    @IBOutlet weak var matchInfoLabel: UILabel!
    
    @IBOutlet weak var matchTimeLabel: UILabel!
    
    @IBOutlet weak var bottomBorderView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setMatchInfoWith(match: Match) {
        
        let matchName = match.name
        
        let matchRawTime = match.startTime
        
        let matchDate = matchRawTime.dateFromISO8601
        
        let matchTime = matchDate?.matchTime
        
        self.matchInfoLabel.text = matchName
        
        self.matchTimeLabel.text = matchTime!
    }
}
