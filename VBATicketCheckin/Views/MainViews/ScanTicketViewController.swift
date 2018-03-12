//
//  ScanTicketViewController.swift
//  VBATicketCheckin
//
//  Created by Bui Minh Duc on 12/15/17.
//  Copyright © 2017 Dinosys. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyJSON

class ScanTicketViewController: BaseViewController {
    lazy var scanner = ScannerView.initWith(frame: self.view.bounds, delegate: self)
    let mainViewModel = MainViewModel.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setViewBackgroundColor(by: .gunmetal)
        self.setNavigationTitle("Quét vé")
        self.addScanner()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.scanner.start()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.scanner.stop()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Process
    private func addScanner() {
        self.view.addSubview(self.scanner)
    }
    
    private func handleScanTicket(_ ticket: Ticket) {
        let title = ticket.paid ? "Checkin thành công" : "Vé chưa thanh toán"
        let message = "Trận đấu: \(ticket.match)\n\nSố lượng vé: \(ticket.quantity)\n\nLoại vé: \(ticket.type)"
        let popupType = ticket.paid ? PopupViewType.withoutButton : PopupViewType.normal
        let popupTitleType = ticket.paid ? PopupTitleType.green : PopupTitleType.red
        let popupButtonType = ticket.paid ? PopupButtonTitleType.ok : PopupButtonTitleType.payment
        
        let popup = self.initPopupView(frame: self.view.bounds, type: popupType, delegate: self)
        popup.loadingView(title: title, message: message, titleType: popupTitleType, buttonType: popupButtonType)
        popup.show(in: self.view, animated: true)
    }
    
    private func handleScanError(_ error: APIError) {
        self.showAlert(title: "Check in không thành công", error: error, actionTitles: ["OK"], actions:[{ [weak self] errorAction in
            DispatchQueue.main.async {
                if error.type == APIErrorType.tokenExpired {
                    self?.logOut()
                } else {
                    self?.scanner.start()
                }}}])
    }
    
    // MARK: - API
    private func scanTicket(code : String) {
        guard User.authorized else {
            self.logOut()
            return
        }
        
        self.showLoading()
        
        self.mainViewModel.verifyTicket(ticketJsonString: code) { [weak self] (ticket, error) in
            DispatchQueue.main.async {
                self?.hideLoading()
                
                if ticket != nil {
                    self?.handleScanTicket(ticket!)
                } else if let _ = error {
                    self?.handleScanError(error!)
                }
            }
        }
    }
}

extension ScanTicketViewController: ScannerViewDelegate, PopupViewDelegate {
    // MARK: - ScannerViewDelegate
    func didReceiveScanningOutput(_ output: String) {
        self.scanTicket(code: output)
    }
    
    // MARK: - PopupViewDelegate
    func didPopupViewRemoveFromSuperview() {
        guard let ticket = self.mainViewModel.currentTicket else {
            return
        }
        
        guard ticket.paid else {
            let destination = Utils.viewController(withIdentifier: Constants.VIEWCONTROLLER_IDENTIFIER_TICKET_PAYMENT) as! TicketPaymentDetailViewController
            self.navigationController?.pushViewController(destination, animated: true)
            
            return
        }
        
        self.scanner.start()
    }
}
