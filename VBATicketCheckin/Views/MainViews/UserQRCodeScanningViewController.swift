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
    lazy var scanner = ScannerView.initWith(frame: self.view.bounds, delegate: self)
    
    let mainViewModel = MainViewModel.shared
    var scanningType = ScanningType.merchandise
    var loyaltyPoint: LoyaltyPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationTitle("Quét mã QR")
        self.addScanner()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Process
    private func addScanner() {
        self.view.addSubview(self.scanner)
    }
    
    private func handlePurchaseSucceed() {
        let title: String? = nil
        let message = "Thanh toán thành công"
        let popupType = PopupViewType.withoutButton
        
        let popup = self.initPopupView(frame: self.view.bounds, type: popupType, delegate: self)
        popup.loadingView(title: title, message: message, titleType: nil, buttonType: nil)
        popup.show(in: self.view, animated: true)
    }
    
    private func handlePurchaseError(_ error: APIError) {
        if error.type == APIErrorType.notEnoughPoint {
            let title: String? = nil
            let message = error.message!
            let popupType = PopupViewType.normal
            let popupButtonType = PopupButtonTitleType.ok
            
            let popup = self.initPopupView(frame: self.view.bounds, type: popupType, delegate: self)
            popup.loadingView(title: title, message: message, titleType: nil, buttonType: popupButtonType)
            popup.show(in: self.view, animated: true)
        } else {
            self.showAlert(title: "Thanh toán không thành công", error: error, actionTitles: ["OK"], actions:[{ [weak self] errorAction in
                DispatchQueue.main.async {
                    if error.type == APIErrorType.tokenExpired {
                        self?.logOut()
                    } else {
                        self?.scanner.start()
                    }
                }}])
        }
    }
    
    // MARK: - API
    private func purchaseMerchandise(_ point: LoyaltyPoint) {
        guard User.authorized else {
            self.logOut()
            return
        }
        
        self.showLoading()
        
        self.mainViewModel.purchaseMerchandiseWithPoint(point.value) { [weak self] (succeed, error) in
            DispatchQueue.main.async {
                self?.hideLoading()
                
                if (succeed) {
                    self?.handlePurchaseSucceed()
                } else if let _ = error {
                    self?.handlePurchaseError(error!)
                }
            }
        }
    }
    
    private func purchasePointTicket() {
        guard User.authorized else {
            self.logOut()
            return
        }
        
        self.showLoading()
        
        self.mainViewModel.purchaseLoyaltyPointTicket { [weak self] (succeed, error) in
            DispatchQueue.main.async {
                self?.hideLoading()
                
                if (succeed) {
                    self?.handlePurchaseSucceed()
                } else if let _ = error {
                    self?.handlePurchaseError(error!)
                }
            }
        }
    }
}

extension UserQRCodeScanningViewController: ScannerViewDelegate, PopupViewDelegate {
    // MARK: - ScannerViewDelegate
    func didReceiveScanningOutput(_ output: String) {
        let jsonData: JSON = ["customer_id" : output]
        let qrCodeContent = QRCodeContent(jsonData)
        self.mainViewModel.setCurrentQRCode(qrCodeContent)
        
        if self.scanningType == .merchandise {
            self.purchaseMerchandise(self.loyaltyPoint!)
        } else {
            self.purchasePointTicket()
        }
    }
    
    // MARK: - PopupViewDelegate
    func didPopupViewRemoveFromSuperview() {
        self.scanner.start()
    }
}
