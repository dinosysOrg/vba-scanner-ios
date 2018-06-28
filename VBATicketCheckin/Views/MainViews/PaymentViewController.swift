//
//  PaymentViewController.swift
//  VBATicketCheckin
//
//  Created by ngoclam on 3/7/18.
//  Copyright © 2018 Dinosys. All rights reserved.
//

import UIKit

class PaymentViewController: BaseViewController {
    
    @IBOutlet weak var vContainer: UIView!
    @IBOutlet weak var btnMerchandise: UIButton!
    @IBOutlet weak var btnTicket: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setTabBarHidden(false)
        self.setNavigationTitle("Thanh toán")
        self.setNavigationHidden(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //
    // MARK: - Setup UI
    //
    func setupUI() {
        self.formatButton(self.btnMerchandise, title: "MERCHANDISE")
        self.formatButton(self.btnTicket, title: "VÉ")
    }
    
    //
    // MARK: - Actions
    //
    @IBAction func btnMerchandise_clicked(_ sender: UIButton) {
    }
    
    @IBAction func btnTicket_clicked(_ sender: UIButton) {
        guard !Utils.Device.isPad else {
            if let destination = Utils.viewController(withIdentifier: Constants.VIEWCONTROLLER_IDENTIFIER_MATCHESMASTER) as? MatchesMasterViewController {
                self.present(destination, animated: true)
            }
            
            return
        }
        
        if let destination = Utils.viewController(withIdentifier: Constants.VIEWCONTROLLER_IDENTIFIER_MATCHES) as? MatchesViewController {
            self.navigationController?.pushViewController(destination, animated: true)
        }
    }
}
