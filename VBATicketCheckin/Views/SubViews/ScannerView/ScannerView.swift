//
//  ScannerView.swift
//  VBATicketCheckin
//
//  Created by ngoclam on 3/7/18.
//  Copyright © 2018 Dinosys. All rights reserved.
//

import UIKit
import AVFoundation

enum QRCodeScanningType {
    case ticket
    case other
}

protocol ScannerViewDelegate: class {
    
    // #required
    func didReceiveCameraPermissionWarning()
    
    // #optional
    func didReceiveScanningOutput(_ output: String)
    func didSelectTicketStatus()
}

extension ScannerViewDelegate {
    
    func didReceiveScanningOutput(_ output: String) {}
    func didSelectTicketStatus() {}
}

class ScannerView: BaseView {
    
    @IBOutlet weak var vContainer: UIView!
    @IBOutlet weak var vScanner: UIView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var vScannerImage: UIView!
    
    @IBOutlet weak var vBottomInfo: UIView!
    @IBOutlet weak var btnTicketStatus: UIButton!
    @IBOutlet weak var txtTicketInfo: UITextView!
    
    weak var delegate: ScannerViewDelegate?
    
    private var _lblTicketStatus = UILabel()
    
    private lazy var _scannerViewModel = ScannerViewModel(with: self)
    private var _videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var _qrCodeType = QRCodeScanningType.ticket
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    class func initWith(frame: CGRect, delegate: ScannerViewDelegate, qrCodeType: QRCodeScanningType = .ticket) -> ScannerView {
        let view = loadNib(of: ScannerView(frame: frame)) as! ScannerView
        view.frame = frame
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = UIColor.clear
        view.delegate = delegate
        view._qrCodeType = qrCodeType
        
        view.setupUI()
        
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //
    // MARK: - Setup UI
    //
    private func setupUI() {
        self.setupBottomInfoViewIfNeeded()
        // Scanner
        self.setupScannerScreen()
    }
    
    private func setupScannerScreen() {
        self.requestDeviceAccess(withCompletion: {
            guard let session = self._scannerViewModel.initSession() else {
                return
            }
            
            DispatchQueue.main.async {
                if self._videoPreviewLayer == nil {
                    self._videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
                    self._videoPreviewLayer!.videoGravity = .resizeAspectFill
                    self._videoPreviewLayer!.masksToBounds = false
                    self.vScanner.layer.addSublayer(self._videoPreviewLayer!)
                }
                
                self._videoPreviewLayer?.frame = self.vScanner.frame
                
                self.setupBlurScanningView()
                self.vScanner.bringSubview(toFront: self.blurView)
                
                if let videoPreviewLayer = self._videoPreviewLayer {
                    let scanningFrame = self.getScanningFrame()
                    self._scannerViewModel.setCapturePreviewLayer(videoPreviewLayer, scanningFrame: scanningFrame)
                    self._scannerViewModel.startScanner()
                }
            }
        })
    }
    
    private func setupBlurScanningView() {
        let containerRect = self.frame
        let scanningFrame = self.getScanningFrame()
        let maskView = UIView(frame: containerRect)
        maskView.clipsToBounds = true;
        maskView.backgroundColor = UIColor.clear
        
        let outerbezierPath = UIBezierPath.init(roundedRect: containerRect, cornerRadius: 0)
        let rect = scanningFrame
        let innerPath = UIBezierPath.init(roundedRect: rect, cornerRadius: 10)
        outerbezierPath.append(innerPath)
        outerbezierPath.usesEvenOddFillRule = true
        
        let fillLayer = CAShapeLayer()
        fillLayer.fillRule = kCAFillRuleEvenOdd
        fillLayer.fillColor = UIColor.green.cgColor
        fillLayer.path = outerbezierPath.cgPath
        maskView.layer.addSublayer(fillLayer)
        
        self.blurView.mask = maskView
        Utils.setView(self.blurView, transparentWith: UIColor.white, alpha: Constants.COLOR_ALPHA_VIEW_SCAN)
    }
    
    private func setupBottomInfoViewIfNeeded(){
        guard self._qrCodeType == .ticket else {
            self.vBottomInfo.removeFromSuperview()
            return
        }
        
        self.formatBtnTicketStatus()
        self.formatTicketInfoTextView()
        
        self.updateUIWithTicketInfo()
    }
    
    func updateUIWithTicketInfo(_ ticket: Ticket? = nil) {
        let titleMatchName = "Trận đấu:"
        let titleTicketsCount = "Số lượng vé:"
        let titleTicketType = "Loại vé:"
        let titleOrder = "Order:"
        let pMatchName = (ticket != nil) ? titleMatchName + " " + ticket!.match : titleMatchName
        let pTicketsCount = (ticket != nil) ? titleTicketsCount + " " + String(ticket!.quantity) : titleTicketsCount
        let pTicketType = (ticket != nil) ? titleTicketType + " " + ticket!.type : titleTicketType
        let pOrder = (ticket != nil) ? titleOrder + " " + String(ticket!.orderId) : titleOrder
        
        let matchName: NSAttributedString = Utils.attributedString(titleMatchName, in: pMatchName)
        let ticketsCount: NSAttributedString = Utils.attributedString(titleTicketsCount, in: pTicketsCount)
        let ticketType: NSAttributedString = Utils.attributedString(titleTicketType, in: pTicketType)
        let order: NSAttributedString = Utils.attributedString(titleOrder, in: pOrder)
        let attributedStrings: [NSAttributedString] = [matchName, ticketsCount, ticketType, order]
        let ticketInfo = Utils.appendAttributedStrings(attributedStrings, separatedBy: "\n\n")
        
        let buttonTitle = (ticket != nil) ? (ticket!.paid ? "Check in thành công" : "Vé chưa thanh toán") : Constants.EMPTY_STRING
        self.btnTicketStatus.backgroundColor = (ticket != nil) ? (ticket!.paid ? UIColor.seaweedGreen : UIColor.reddish) : UIColor.gunmetal
        self.btnTicketStatus.isEnabled = (ticket != nil) ? (ticket!.paid ? false : true) : false
        
        self._lblTicketStatus.text = buttonTitle.uppercased()
        
        self.txtTicketInfo.attributedText = ticketInfo
    }
    
    //
    // MARK: - Format
    //
    private func formatTicketInfoTextView() {
        self.txtTicketInfo.textColor = UIColor.gunmetal
        self.txtTicketInfo.font = UIFont.regular.XL
        self.txtTicketInfo.text = Constants.EMPTY_STRING
    }
    
    private func formatBtnTicketStatus() {
        self.btnTicketStatus.setTitle(Constants.EMPTY_STRING, for: .normal)
        self.btnTicketStatus.backgroundColor = UIColor.gunmetal
        self.btnTicketStatus.isEnabled = false
        
        let buttonRect = self.btnTicketStatus.bounds
        self._lblTicketStatus.textAlignment = .center
        self._lblTicketStatus.numberOfLines = 2
        self._lblTicketStatus.font = UIFont.bold.XL
        self._lblTicketStatus.transform = CGAffineTransform(rotationAngle: -.pi / 2)
        self._lblTicketStatus.textColor = .white
        self._lblTicketStatus.backgroundColor = .clear
        self._lblTicketStatus.frame = CGRect(x: 0.0, y: 10.0, width: buttonRect.width, height: buttonRect.height - 20.0)
        self.btnTicketStatus.addSubview(self._lblTicketStatus)
    }
    
    @objc func setGrayTicketStatus() {
        self._lblTicketStatus.textColor = .lightGray
    }
    
    @objc func setWhiteTicketStatus() {
        self._lblTicketStatus.textColor = .white
    }
    
    private func setOpacityEffectForTicketStatus() {
        self.setGrayTicketStatus()
        Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.setWhiteTicketStatus), userInfo: nil, repeats: false)
    }
    
    //
    // MARK: - Process
    //
    private func requestDeviceAccess(withCompletion complete: @escaping(() -> Void)) {
        self._scannerViewModel.requestAVCaptureDeviceAccess { [weak self] requestGranted in
            guard requestGranted else {
                DispatchQueue.main.async {
                    self?.delegate?.didReceiveCameraPermissionWarning()
                }
                
                return
            }
            
            complete()
        }
    }
    
    private func getScanningFrame() -> CGRect {
        if Utils.Device.isPad {
            let multiplier: CGFloat = Utils.Device.isPad ? 0.45 : 0.78
            let containerRect = self.vScanner.frame
            let containerCenter = self.vScanner.center
            var x: CGFloat = containerCenter.x
            var y: CGFloat = containerCenter.y
            var width: CGFloat = containerRect.width
            var height: CGFloat = containerRect.height
            
            if width < height {
                width = multiplier * width
                height = width
            } else {
                width = multiplier * height
                height = width
            }
            
            x = x - width / 2
            y = y - height / 2
            
            let scanningFrame = CGRect(x: x, y: y, width: width, height: height)
            return scanningFrame
        }
        
        return self.vScannerImage.frame
    }
    
    func updateUI() {
        DispatchQueue.main.async {
            self._videoPreviewLayer?.frame = self.vScanner.frame
            
            self.setupBlurScanningView()
            self.vScanner.bringSubview(toFront: self.blurView)
            
            if let videoPreviewLayer = self._videoPreviewLayer {
                let scanningFrame = self.getScanningFrame()
                self._scannerViewModel.setCapturePreviewLayer(videoPreviewLayer, scanningFrame: scanningFrame)
            }
        }
    }
    
    @objc func start() {
        self._scannerViewModel.startScanner()
    }
    
    @objc func stop() {
        self._scannerViewModel.stopScanner()
    }
    
    //
    // MARK: - Actions
    //
    @IBAction func btnTicketStatus_clicked(_ sender: UIButton) {
        self.setOpacityEffectForTicketStatus()
        self.delegate?.didSelectTicketStatus()
    }
}

//
// MARK: - ScannerViewModelDelegate
//
extension ScannerView: ScannerViewModelDelegate {
    
    func didExportMetadataOutput(_ output: String) {
        self.delegate?.didReceiveScanningOutput(output)
    }
}

