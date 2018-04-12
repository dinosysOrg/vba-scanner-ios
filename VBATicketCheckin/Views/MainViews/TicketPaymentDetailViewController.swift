//
//  TicketPaymentDetailViewController.swift
//  VBATicketCheckin
//
//  Created by ngoclam on 3/8/18.
//  Copyright © 2018 Dinosys. All rights reserved.
//

import UIKit

class TicketPaymentDetailViewController: BaseViewController {
    @IBOutlet weak var vOrderInfo: UIView!
    @IBOutlet weak var lblTitleOrder: UILabel!
    @IBOutlet weak var lblMatchInfo: UILabel!
    
    @IBOutlet weak var vPriceInfo: UIView!
    @IBOutlet weak var lblTitleLeft: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblUnitLeft: UILabel!
    
    @IBOutlet weak var lblTitleRight: UILabel!
    @IBOutlet weak var lblPoint: UILabel!
    @IBOutlet weak var lblUnitRight: UILabel!
    
    @IBOutlet weak var btnCashPayment: UIButton!
    @IBOutlet weak var btnScanPayment: UIButton!
    
    private let mainViewModel = MainViewModel.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.getConversionRate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setNavigationTitle("Thông tin đơn hàng")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Setup UI
    func setupUI() {
        let ticket = self.mainViewModel.currentTicket
        
        let matchInfo = "Trận đấu: \(ticket?.match ?? Constants.DEFAULT_STRING_VALUE)\n\nSố lượng vé: \(ticket?.quantity ?? Constants.DEFAULT_INT_VALUE)\n\nLoại vé: \(ticket?.type ?? Constants.DEFAULT_STRING_VALUE)"
        let strPrice = ticket?.displayedPrice ?? Constants.ZERO_STRING
        let strPoint = "\(ticket?.orderPoint?.value ?? Constants.DEFAULT_INT_VALUE)"
        
        self.formatLabel(self.lblTitleOrder, title: "Thông tin đơn hàng", color: UIColor.black)
        self.formatMultipleLinesLabel(self.lblMatchInfo, title: matchInfo, color: UIColor.black)
        self.vPriceInfo.layer.setBorder(2.0, color: UIColor.coolGrey.cgColor)
        self.formatLabel(self.lblTitleLeft, title: "Giá:", color: UIColor.black)
        self.formatExtraLargeBoldLabel(self.lblPrice, title: strPrice, color: UIColor.black)
        self.formatLabel(self.lblUnitLeft, title: "đồng", color: UIColor.black)
        self.formatLabel(self.lblTitleRight, title: "Tương đương", color: UIColor.black)
        self.formatExtraLargeBoldLabel(self.lblPoint, title: strPoint, color: UIColor.black)
        self.formatLabel(self.lblUnitRight, title: "điểm", color: UIColor.black)
        
        self.formatButton(self.btnCashPayment, title: "THANH TOÁN\nTIỀN MẶT")
        self.formatButton(self.btnScanPayment, title: "QUÉT MÃ\nTHANH TOÁN")
        
        // Fit font's size of text to its width
        let fontSize = self.adjustedFontSizeOf(label: self.lblPrice)
        self.lblPrice.font = self.lblPrice.font.withSize(fontSize)
        self.lblPoint.font = self.lblPoint.font.withSize(fontSize)
    }
    
    // MARK: - Process
    private func adjustedFontSizeOf(label: UILabel) -> CGFloat {
        guard let textSize = label.text?.size(withAttributes: [.font: label.font]), textSize.width > label.bounds.width else {
            return label.font.pointSize
        }
        
        let scale = label.bounds.width / textSize.width
        let actualFontSize = scale * label.font.pointSize
        
        return actualFontSize
    }
    
    private func reloadData() {
        self.setupUI()
    }
    
    private func handleConversionRateError(_ error: APIError) {
        self.showAlert(title: "Lấy mã chuyển đổi không thành công", message: error.message!, actionTitles: ["OK"], actions: [{ [weak self] errorAction in
            DispatchQueue.main.async {
                if error.type == APIErrorType.tokenExpired {
                    self?.logOut()
                }
            }}]
        )
    }
    
    private func handlePurchaseTicketSucceed() {
        let title: String? = nil
        let message = "Thanh toán thành công"
        let popupType = PopupViewType.withoutButton
        
        let popup = self.initPopupView(frame: self.view.bounds, type: popupType, delegate: self)
        popup.loadingView(title: title, message: message, titleType: nil, buttonType: nil)
        popup.show(in: (self.navigationController?.view ?? self.view), animated: true)
    }
    
    private func handlePurchaseTicketError(_ error: APIError) {
        self.showAlert(title: "Thanh toán vé không thành công", message: error.message!, actionTitles: ["OK"], actions:[{ [weak self] errorAction in
            DispatchQueue.main.async {
                if error.type == APIErrorType.tokenExpired {
                    self?.logOut()
                }
            }}]
        )
    }
    
    // MARK: - Action
    @IBAction func btnCashPayment_clicked(_ sender: UIButton) {
        self.purchaseTicket()
    }
    
    @IBAction func btnScanPayment_clicked(_ sender: UIButton) {
        let destination = Utils.viewController(withIdentifier: Constants.VIEWCONTROLLER_IDENTIFIER_USER_QRCODE_SCANNING) as! UserQRCodeScanningViewController
        destination.scanningType = .ticket
        self.navigationController?.pushViewController(destination, animated: true)
    }
    
    // MARK: - API
    private func getConversionRate() {
        guard User.authorized else {
            self.logOut()
            return
        }
        
        self.showLoading()
        
        self.mainViewModel.getConversionRateP2M { [weak self] (rate, error) in
            DispatchQueue.main.async {
                self?.hideLoading()
                
                guard error == nil else {
                    self?.handleConversionRateError(error!)
                    return
                }
                
                self?.reloadData()
            }
        }
    }
    
    private func purchaseTicket() {
        guard User.authorized else {
            self.logOut()
            return
        }
        
        self.showLoading()
        
        self.mainViewModel.purchaseTicket { [weak self] error in
            DispatchQueue.main.async {
                self?.hideLoading()
                
                guard error == nil else {
                    self?.handlePurchaseTicketError(error!)
                    return
                }
                
                self?.handlePurchaseTicketSucceed()
            }
        }
    }
}

extension TicketPaymentDetailViewController: PopupViewDelegate {
    // MARK: - PopupViewDelegate
    func didPopupViewRemoveFromSuperview() {
        self.navigationController?.popViewController(animated: true)
    }
}
