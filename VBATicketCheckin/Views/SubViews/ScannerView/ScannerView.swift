//
//  ScannerView.swift
//  VBATicketCheckin
//
//  Created by ngoclam on 3/7/18.
//  Copyright © 2018 Dinosys. All rights reserved.
//

import UIKit
import AVFoundation

protocol ScannerViewDelegate: class {
    // #required
    func didReceiveCameraPermissionWarning()
    
    // #optional
    func didReceiveScanningOutput(_ output: String)
}

extension ScannerViewDelegate {
    func didReceiveScanningOutput(_ output: String) {}
}

class ScannerView: BaseView {
    @IBOutlet weak var vContainer: UIView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var vScannerImage: UIView!
    @IBOutlet weak var constraintVScannerImageWidth: NSLayoutConstraint!
    
    weak var delegate: ScannerViewDelegate?
    
    private lazy var scannerViewModel = ScannerViewModel(with: self)
    let scannerQueue = DispatchQueue(label: "ScannerQueue", attributes: .concurrent)
    
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    class func initWith(frame: CGRect, delegate: ScannerViewDelegate) -> ScannerView {
        let view = loadNib(of: ScannerView(frame: frame)) as! ScannerView
        view.frame = frame
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = UIColor.clear
        view.delegate = delegate
        
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setupUI()
    }
    
    // MARK: - Setup UI
    func setupBlurScanningView() {
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
    
    private func setupUI() {
        // Scanner
        scannerQueue.async {
            self.requestDeviceAccess()
            self.scannerViewModel.startScanner()
            
            guard let session = self.scannerViewModel.initSession() else {
                return
            }
            
            DispatchQueue.main.async {
                if self.videoPreviewLayer == nil {
                    self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
                    self.videoPreviewLayer!.videoGravity = .resizeAspectFill
                    self.videoPreviewLayer!.masksToBounds = false
                    self.videoPreviewLayer!.setCornerRadius(10.0, border: 2.0, color: UIColor.darkBlueGrey.cgColor)
                    self.vContainer.layer.addSublayer(self.videoPreviewLayer!)
                }
                
                self.videoPreviewLayer?.frame = self.frame
                
                self.setupBlurScanningView()
                self.vContainer.bringSubview(toFront: self.blurView)
                
                if let videoPreviewLayer = self.videoPreviewLayer {
                    let scanningFrame = self.getScanningFrame()
                    self.scannerViewModel.setCapturePreviewLayer(videoPreviewLayer, scanningFrame: scanningFrame)
                }
            }
        }
    }
    
    // MARK: - Process
    private func requestDeviceAccess() {
        self.scannerViewModel.requestAVCaptureDeviceAccess { [weak self] requestGranted in
            if (!requestGranted) {
                DispatchQueue.main.async {
                    self?.delegate?.didReceiveCameraPermissionWarning()
                }
            }
        }
    }
    
    private func getScanningFrame() -> CGRect {
        if Utils.is_iPad {
            let multiplier: CGFloat = Utils.is_iPad ? 0.45 : 0.78
            let containerRect = self.frame
            let containerCenter = self.center
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
            self.videoPreviewLayer?.frame = self.frame
            
            self.setupBlurScanningView()
            self.vContainer.bringSubview(toFront: self.blurView)
            
            if let videoPreviewLayer = self.videoPreviewLayer {
                let scanningFrame = self.getScanningFrame()
                self.scannerViewModel.setCapturePreviewLayer(videoPreviewLayer, scanningFrame: scanningFrame)
            }
        }
    }
    
    func start() {
        self.scannerViewModel.startScanner()
    }
    
    func stop() {
        self.scannerViewModel.stopScanner()
    }
}

extension ScannerView: ScannerViewModelDelegate {
    // MARK: - ScannerViewModelDelegate
    func didExportMetadataOutput(_ output: String) {
        self.delegate?.didReceiveScanningOutput(output)
    }
}

