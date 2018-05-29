//
//  ScanTicketViewController.swift
//  VBATicketCheckin
//
//  Created by Bui Minh Duc on 12/15/17.
//  Copyright © 2017 Dinosys. All rights reserved.
//

import UIKit
import AVFoundation

class ScanTicketViewController: BaseViewController {
    private let mainViewModel = MainViewModel.shared
    private var scanner: ScannerView?
    var ticketScanningType = TicketScanningType.checkIn
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setViewBackgroundColor(by: .gunmetal)
        self.addScanner()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setNavigationTitle((self.ticketScanningType == .checkIn) ? "Quét vé" : "Thanh toán vé")
        // Use scanner.start() for next time pop from other view controller
        self.scanner?.start()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Use scanner.start() for first time scanner initiated
        self.scanner?.start()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.scanner?.stop()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            log("isLandscape")
        } else {
            log("isPortrait")
        }
    }
    
    // MARK: - Process
    private func addScanner() {
        self.scanner = ScannerView.initWith(frame: self.view.bounds, delegate: self)
        self.view.addSubview(self.scanner!)
    }
    
    private func handleScan(ticket: Ticket?, error: APIError?) {
        self.hideLoading()
        
        guard error == nil else {
            self.handleScanError(error!)
            return
        }
        
        self.handleScanTicket(ticket!)
    }
    
    private func handleScanTicket(_ ticket: Ticket) {
        let title = ticket.paid ? "Checkin thành công" : "Vé chưa thanh toán"
        let message = "Trận đấu: \(ticket.match)\n\nSố lượng vé: \(ticket.quantity)\n\nLoại vé: \(ticket.type)\n\nOrder: \(ticket.orderId)"
        let popupType = ticket.paid ? PopupViewType.withoutButton : PopupViewType.normal
        let popupTitleType = ticket.paid ? PopupTitleType.green : PopupTitleType.red
        let popupButtonType = ticket.paid ? PopupButtonTitleType.ok : PopupButtonTitleType.payment
        
        let popup = self.initPopupView(frame: self.view.bounds, type: popupType, delegate: self)
        popup.loadingView(title: title, message: message, titleType: popupTitleType, buttonType: popupButtonType)
        popup.show(in: (self.navigationController?.view ?? self.view), animated: true)
        self.setNavigationSwipeEnable(false)
    }
    
    private func handleScanError(_ error: APIError) {
        let title = self.ticketScanningType == .checkIn ? "Check in không thành công" : "Thanh toán không thành công"
        var message = Constants.EMPTY_STRING
        
        if error.ticketErrorType == .used {
            message = "\(error.message!)\nOrder: \(self.mainViewModel.currentQRCode?.orderId ?? Constants.DEFAULT_INT_VALUE)"
        } else if error.ticketErrorType == .invalidMatch {
            message = self.ticketScanningType == .checkIn ? "Check-in không đúng trận đấu." : "Thanh toán không đúng trận đấu."
        } else {
            message = error.message!
        }
        
        self.showAlert(title: title, message: message, actionTitles: ["OK"], actions: [{ [weak self] errorAction in
            DispatchQueue.main.async {
                if error.type == APIErrorType.tokenExpired {
                    self?.logOut()
                } else {
                    self?.scanner?.start()
                }
            }}]
        )
    }
    
    // MARK: - API
    private func scanTicket(_ content: String) {
        guard User.authorized else {
            self.logOut()
            return
        }
        
        self.showLoading()
        
        self.mainViewModel.scanTicket(content: content, type: self.ticketScanningType) { [weak self] (ticket, error) in
            DispatchQueue.main.async {
                self?.handleScan(ticket: ticket, error: error)
            }
        }
    }
}

extension ScanTicketViewController: ScannerViewDelegate, PopupViewDelegate {
    // MARK: - ScannerViewDelegate
    func didReceiveCameraPermissionWarning() {
        self.showCameraPermissionError()
    }
    
    func didReceiveScanningOutput(_ output: String) {
        self.scanTicket(output)
    }
    
    // MARK: - PopupViewDelegate
    func didPopupViewRemoveFromSuperview() {
        self.setNavigationSwipeEnable(true)
        
        guard let ticket = self.mainViewModel.currentTicket else {
            self.scanner?.start()
            return
        }
        
        guard ticket.paid else {
            let destination = Utils.viewController(withIdentifier: Constants.VIEWCONTROLLER_IDENTIFIER_TICKET_PAYMENT) as! TicketPaymentDetailViewController
            self.navigationController?.pushViewController(destination, animated: true)
            
            return
        }
        
        self.scanner?.start()
    }
}
