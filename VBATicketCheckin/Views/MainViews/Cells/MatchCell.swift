//
//  MatchCell.swift
//  VBATicketCheckin
//
//  Created by Bui Minh Duc on 11/23/17.
//  Copyright © 2017 Dinosys. All rights reserved.
//

import UIKit

class MatchCell: UITableViewCell {
    @IBOutlet weak var vContainer: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setupUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.gunmetal
        self.selectedBackgroundView = backgroundView
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        
        self.vContainer.backgroundColor = UIColor.white
        self.vContainer.layer.setCornerRadius(10.0, border: 0.0, color: nil)
        
        self.lblName.textColor = UIColor.black
        self.lblName.font = UIFont.regular.XL
        self.lblName.lineBreakMode = .byWordWrapping
        self.lblName.numberOfLines = 0
        
        self.lblTime.textColor = UIColor.coolGrey
        self.lblTime.font = UIFont.regular.L
    }
    
    // MARK: - Load Match data
    func setInfoWith(_ match: Match) {
        let matchRawTime = match.startTime
        let matchDate = matchRawTime.dateFromISO8601
        let matchTime = matchDate?.matchTime
        
        self.lblName.text = match.name
        self.lblTime.text = matchTime
    }
}
