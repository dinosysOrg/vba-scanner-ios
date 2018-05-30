//
//  UserQRCodeScanningViewController.swift
//  VBATicketCheckin
//
//  Created by ngoclam on 3/8/18.
//  Copyright © 2018 Dinosys. All rights reserved.
//

import UIKit
import SwiftyJSON

enum ScanningType {
    case merchandise
    case ticket
}

class UserQRCodeScanningViewController: BaseViewController {
    private let mainViewModel = MainViewModel.shared
    
    private var scanner: ScannerView?
    var scanningType = ScanningType.merchandise
    var merchandisePoint: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addScanner()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setNavigationTitle("Quét mã QR")
        // Use scanner.start() for next time pop from other view controller
        self.scanner?.start()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Use scanner.start() for first time scanner initiated
        self.scanner?.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        self.scanner?.updateUI()
    }
    
    // MARK: - Process
    private func addScanner() {
        self.scanner = ScannerView.initWith(frame: self.view.bounds, delegate: self)
        self.view.addSubview(self.scanner!)
    }
    
    private func handlePurchaseSucceed() {
        let title: String? = nil
        let message = "Thanh toán thành công"
        let popupType = PopupViewType.withoutButton
        
        let popup = self.initPopupView(frame: self.view.bounds, type: popupType, delegate: self)
        popup.loadingView(title: title, message: message, titleType: nil, buttonType: nil)
        popup.show(in: (self.navigationController?.view ?? self.view), animated: true)
    }
    
    private func handlePurchaseError(_ error: APIError) {
        if error.type == APIErrorType.notEnoughPoint {
            let title: String? = nil
            let message = error.message!
            let popupType = PopupViewType.normal
            let popupButtonType = PopupButtonTitleType.ok
            
            let popup = self.initPopupView(frame: self.view.bounds, type: popupType, delegate: self)
            popup.loadingView(title: title, message: message, titleType: nil, buttonType: popupButtonType)
            popup.show(in: (self.navigationController?.view ?? self.view), animated: true)
            self.setNavigationSwipeEnable(false)
        } else {
            self.showAlert(title: "Thanh toán không thành công", message: error.message!, actionTitles: ["OK"], actions: [{ [weak self] errorAction in
                DispatchQueue.main.async {
                    if error.type == APIErrorType.tokenExpired {
                        self?.logOut()
                    } else {
                        self?.scanner?.start()
                    }
                }}]
            )
        }
    }
    
    // MARK: - API
    private func purchaseMerchandise(withPoint point: Int, customerId: String) {
        guard User.authorized else {
            self.logOut()
            return
        }
        
        self.showLoading()
        
        self.mainViewModel.purchaseMerchandise(withPoint: point, customerId: customerId) { [weak self] error in
            DispatchQueue.main.async {
                self?.hideLoading()
                
                guard error == nil else {
                    self?.handlePurchaseError(error!)
                    return
                }
                
                self?.handlePurchaseSucceed()
            }
        }
    }
    
    private func purchaseTicket(withCustomerId customerId: String) {
        guard User.authorized else {
            self.logOut()
            return
        }
        
        self.showLoading()
        
        self.mainViewModel.purchaseTicket(withCustomerId: customerId) { [weak self] error in
            DispatchQueue.main.async {
                self?.hideLoading()
                
                guard error == nil else {
                    self?.handlePurchaseError(error!)
                    return
                }
                
                self?.handlePurchaseSucceed()
            }
        }
    }
}

extension UserQRCodeScanningViewController: ScannerViewDelegate, PopupViewDelegate {
    // MARK: - ScannerViewDelegate
    func didReceiveCameraPermissionWarning() {
        self.showCameraPermissionError()
    }
    
    func didReceiveScanningOutput(_ output: String) {
        if self.scanningType == .merchandise {
            self.purchaseMerchandise(withPoint: Int(self.merchandisePoint!)!, customerId: output)
        } else {
            self.purchaseTicket(withCustomerId: output)
        }
    }
    
    // MARK: - PopupViewDelegate
    func didPopupViewRemoveFromSuperview() {
        // If purchase ticket successfully navigate back to ScanTicket
        if (self.scanningType == .ticket) && self.mainViewModel.purchaseSucceed {
            self.popToScanTicket()
            return
        }
        
        self.setNavigationSwipeEnable(true)
        self.scanner?.start()
    }
}
