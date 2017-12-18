//
//  ScanResultViewController.swift
//  VBATicketCheckin
//
//  Created by Bui Minh Duc on 12/15/17.
//  Copyright © 2017 Dinosys. All rights reserved.
//

import UIKit
import SwiftyJSON

class ScanResultViewController: UIViewController {
    
    let mainViewModel = MainViewModel.sharedInstance
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var quantityLabel: UILabel!
    
    @IBOutlet weak var ticketTypeLabel: UILabel!
    
    @IBOutlet weak var paymentStatusLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var payButton: UIButton!
    
    @IBOutlet weak var checkInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Thông tin vé"
        
        self.updateTicketUI()
    }
    
    @IBAction func paid(_ sender: UIButton) {
        self.mainViewModel.purchaseTicket { (succeed, error) in
            if (succeed) {
                self.paymentStatusLabel.text = "Đã thanh toán"
                self.statusLabel.text = "Đã sử dụng"
                
                self.payButton.isHidden = true
                self.checkInButton.isHidden = false
                
            } else if let paidError = error {
                self.showAlert(title:  "Thanh toán vé không thành công", error: paidError, actionTitles: ["OK"], actions:[{errorAction in
                    if paidError.type == APIErrorType.tokenExpired {
                        User.sharedInstance.signOut()
                        self.dismiss(animated: true, completion: nil)
                    }}])
            }
        }
    }
    
    func updateTicketUI() {
        if let ticket = self.mainViewModel.currentTicket {
            self.nameLabel.text = ticket.name
            self.quantityLabel.text = String(ticket.quantity)
            self.ticketTypeLabel.text = ticket.ticketType
            self.paymentStatusLabel.text = ticket.paid ? "Đã thanh toán" : "Chưa thanh toán"
            self.statusLabel.text = ticket.used ? "Đã sử dụng" : "Chưa sử dụng"
            
            self.payButton.isHidden = true
            self.checkInButton.isHidden = true
            
            if !ticket.paid {
                self.payButton.isHidden = false
            } else if ticket.used {
                self.checkInButton.isHidden = false
            }
        }
    }
    
    
    @IBAction func rescanned(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

