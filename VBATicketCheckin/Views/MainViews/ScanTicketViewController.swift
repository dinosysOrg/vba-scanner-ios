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
    
    @IBOutlet weak var vScannerContainer: UIView!
    
    private let _mainViewModel = MainViewModel.shared
    private var _scanner: ScannerView?
    private var _popUpAlertWindow: UIWindow?
    private var _popUpAlert: PopupView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setViewBackgroundColor(by: .normal)
        self.setupScannerIfNeeded(!Utils.Device.isPad || (self._mainViewModel.ticketScanningType == .payment))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setTabBarHidden(!Utils.Device.isPad)
        self.setNavigationTitle((self._mainViewModel.ticketScanningType == .checkIn) ? "Quét vé" : "Thanh toán vé")
        self.updateScanScreenAfterPurchaseIfNeeded()
        self._scanner?.updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setupScannerIfNeeded(Utils.Device.isPad)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self._scanner?.stop()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        self._popUpAlert?.updatePopupViewRect(Utils.Device.bounds)
        self._scanner?.updateUI()
    }
    
    //
    // MARK: - Setup UI
    //
    private func setupScannerIfNeeded(_ needed: Bool) {
        guard needed else {
            self.startScanner()
            return
        }
        
        self.addScanner()
        self.startScanner()
    }
    
    //
    // MARK: - Process
    //
    private func addScanner() {
        guard let _ = self._scanner else {
            var scanRect = self.view.frame
            
            if Utils.Device.isPad && (self._mainViewModel.ticketScanningType == .checkIn) {
                scanRect = self.vScannerContainer.frame
                scanRect = CGRect(x: 0.0, y: 0.0, width: scanRect.width, height: scanRect.height + scanRect.origin.y)
            }
            
            self._scanner = ScannerView.initWith(frame: scanRect, delegate: self)
            self.view.addSubview(self._scanner!)
            
            return
        }
    }
    
    @objc func startScanner() {
        self._scanner?.start()
    }
    
    
    /// Restart scanner after number of seconds
    ///
    /// - Parameter time: delay time for restarting the scanner in second
    private func restartScanner(after time: TimeInterval) {
        Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(self.startScanner), userInfo: nil, repeats: false)
    }
    
    private func updateScanningInfo(withTicket ticket: Ticket) {
        self._scanner?.updateUIWithTicketInfo(ticket)
        self.restartScanner(after: 1.5)
    }
    
    private func pushTicketPaymentDetailViewController() {
        if let destination = Utils.viewController(withIdentifier: Constants.VIEWCONTROLLER_IDENTIFIER_TICKET_PAYMENT) as? TicketPaymentDetailViewController {
            self.navigationController?.pushViewController(destination, animated: true)
        }
    }
    
    private func updateScanScreenAfterPurchaseIfNeeded() {
        if self._mainViewModel.purchaseSucceed {
            self._scanner?.updateUIWithTicketInfo()
        }
    }
    
    private func handleScan(ticket: Ticket?, error: APIError?) {
        self.hideLoading()
        
        guard error == nil else {
            self.handleScanError(error!)
            return
        }
        
        //        self.handleScanTicket(ticket!)
        self.updateScanningInfo(withTicket: ticket!)
    }
    
    private func handleScanTicket(_ ticket: Ticket) {
        let title = ticket.paid ? "Check in thành công" : "Vé chưa thanh toán"
        let message = "Trận đấu: \(ticket.match)\n\nSố lượng vé: \(ticket.quantity)\n\nLoại vé: \(ticket.type)\n\nOrder: \(ticket.orderId)"
        let popupType = ticket.paid ? PopupViewType.withoutButton : PopupViewType.normal
        let popupTitleType = ticket.paid ? PopupTitleType.green : PopupTitleType.red
        let popupButtonType = ticket.paid ? PopupButtonTitleType.ok : PopupButtonTitleType.payment
        
        self._popUpAlertWindow = Utils.popUpAlertWindow()
        
        self._popUpAlert = self.initPopupView(frame: self._popUpAlertWindow!.bounds, type: popupType, delegate: self)
        self._popUpAlert?.loadingView(title: title, message: message, titleType: popupTitleType, buttonType: popupButtonType)
        self._popUpAlert?.showAnimated(in: (self._popUpAlertWindow!.rootViewController?.view ?? self.view))
        
        self.setNavigationSwipeEnable(false)
    }
    
    private func handleScanError(_ error: APIError) {
        let title = (self._mainViewModel.ticketScanningType == .checkIn) ? "Check in không thành công" : "Thanh toán không thành công"
        var message = Constants.EMPTY_STRING
        
        if error.ticketErrorType == .used {
            message = "\((self._mainViewModel.ticketScanningType == .checkIn) ? "Vé đã được check in" : "Vé đã được thanh toán")\nOrder: \(self._mainViewModel.currentQRCode?.orderId ?? Constants.DEFAULT_INT_VALUE)"
        } else if error.ticketErrorType == .invalidMatch {
            message = self._mainViewModel.ticketScanningType == .checkIn ? "Check in không đúng trận đấu." : "Thanh toán không đúng trận đấu."
        } else {
            message = error.message!
        }
        
        self.showAlert(title: title, message: message, actionTitles: ["OK"], actions: [{ [weak self] errorAction in
            DispatchQueue.main.async {
                if error.type == APIErrorType.tokenExpired {
                    self?.logOut()
                } else {
                    self?.startScanner()
                }
            }}]
        )
    }
}

//
// MARK: - ScannerViewDelegate
//
extension ScanTicketViewController: ScannerViewDelegate {
    
    func didReceiveCameraPermissionWarning() {
        self.showCameraPermissionError()
    }
    
    func didReceiveScanningOutput(_ output: String) {
        self.scanTicket(output)
    }
    
    func didSelectTicketStatus() {
        self.pushTicketPaymentDetailViewController()
    }
}

//
// MARK: - PopupViewDelegate
//
extension ScanTicketViewController: PopupViewDelegate {
    
    func didPopupViewRemoveFromSuperview() {
        self._popUpAlertWindow = nil
        
        self.setNavigationSwipeEnable(true)
        
        guard let ticket = self._mainViewModel.currentTicket else {
            self.startScanner()
            return
        }
        
        guard ticket.paid else {
            self.pushTicketPaymentDetailViewController()
            
            return
        }
        
        self.startScanner()
    }
}

//
// MARK: - API Request
//
extension ScanTicketViewController {
    
    private func scanTicket(_ content: String) {
        self._scanner?.updateUIWithTicketInfo()
        
        guard User.authorized else {
            self.logOut()
            return
        }
        
        self.showLoading()
        
        self._mainViewModel.scanTicket(content: content, type: self._mainViewModel.ticketScanningType) { [weak self] (ticket, error) in
            DispatchQueue.main.async {
                self?.handleScan(ticket: ticket, error: error)
            }
        }
    }
}
