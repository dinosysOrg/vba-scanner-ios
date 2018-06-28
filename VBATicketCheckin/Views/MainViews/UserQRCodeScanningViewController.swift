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
    
    private let _mainViewModel = MainViewModel.shared
    private var _scanner: ScannerView?
    private var _popUpAlertWindow: UIWindow?
    private var _popUpAlert: PopupView?
    
    var scanningType = ScanningType.merchandise
    var merchandisePoint: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setViewBackgroundColor(by: .normal)
        self.addScanner()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setNavigationTitle("Quét mã QR")
        self._scanner?.start()
        
        if Utils.Device.isPad {
            self.setTabBarHidden(self._mainViewModel.ticketScanningType != .checkIn)
        }
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
    // MARK: - Process
    //
    private func addScanner() {
        self._scanner = ScannerView.initWith(frame: self.view.bounds, delegate: self, qrCodeType: .other)
        self.view.addSubview(self._scanner!)
    }
    
    private func handlePurchaseSucceed() {
        let title: String? = nil
        let message = "Thanh toán thành công"
        let popupType = PopupViewType.withoutButton
        
        self._popUpAlertWindow = Utils.popUpAlertWindow()
        
        self._popUpAlert = self.initPopupView(frame: self._popUpAlertWindow!.bounds, type: popupType, delegate: self)
        self._popUpAlert?.loadingView(title: title, message: message, titleType: nil, buttonType: nil)
        self._popUpAlert?.show(in: (self._popUpAlertWindow!.rootViewController?.view ?? self.view), animated: true)
    }
    
    private func handlePurchaseError(_ error: APIError) {
        if error.type == APIErrorType.notEnoughPoint {
            let title: String? = nil
            let message = error.message!
            let popupType = PopupViewType.normal
            let popupButtonType = PopupButtonTitleType.ok
            
            self._popUpAlertWindow = Utils.popUpAlertWindow()
            
            self._popUpAlert = self.initPopupView(frame: self._popUpAlertWindow!.bounds, type: popupType, delegate: self)
            self._popUpAlert?.loadingView(title: title, message: message, titleType: nil, buttonType: popupButtonType)
            self._popUpAlert?.show(in: (self._popUpAlertWindow!.rootViewController?.view ?? self.view), animated: true)
            self.setNavigationSwipeEnable(false)
        } else {
            self.showAlert(title: "Thanh toán không thành công", message: error.message!, actionTitles: ["OK"], actions: [{ [weak self] errorAction in
                DispatchQueue.main.async {
                    if error.type == APIErrorType.tokenExpired {
                        self?.logOut()
                    } else {
                        self?._scanner?.start()
                    }
                }}]
            )
        }
    }
}

//
// MARK: - ScannerViewDelegate
//
extension UserQRCodeScanningViewController: ScannerViewDelegate {
    
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
}

//
// MARK: - PopupViewDelegate
//
extension UserQRCodeScanningViewController: PopupViewDelegate {
    
    func didPopupViewRemoveFromSuperview() {
        self._popUpAlertWindow = nil
        
        // If purchase ticket successfully navigate back to ScanTicket
        if (self.scanningType == .ticket) && self._mainViewModel.purchaseSucceed {
            self.popToScanTicket()
            return
        }
        
        self.setNavigationSwipeEnable(true)
        self._scanner?.start()
    }
}

//
// MARK: - API Request
//
extension UserQRCodeScanningViewController {
    
    private func purchaseMerchandise(withPoint point: Int, customerId: String) {
        guard User.authorized else {
            self.logOut()
            return
        }
        
        self.showLoading()
        
        self._mainViewModel.purchaseMerchandise(withPoint: point, customerId: customerId) { [weak self] error in
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
        
        self._mainViewModel.purchaseTicket(withCustomerId: customerId) { [weak self] error in
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
