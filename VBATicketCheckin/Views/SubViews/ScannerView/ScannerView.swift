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
    
    weak var delegate: ScannerViewDelegate?
    
    private lazy var scannerViewModel = ScannerViewModel(with: self)
    let scannerQueue = DispatchQueue(label: "ScannerQueue", attributes: .concurrent)
    
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
    func setBlurViewHole() {
        let maskView = UIView(frame: self.blurView.bounds)
        maskView.clipsToBounds = true;
        maskView.backgroundColor = UIColor.clear
        
        let outerbezierPath = UIBezierPath.init(roundedRect: self.blurView.bounds, cornerRadius: 0)
        let rect = self.vScannerImage.frame
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
            self.scannerViewModel.startScanner()
            
            guard let session = self.scannerViewModel.initSession() else {
                guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
                    AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                        if granted {
                            log("access allowed")
                        } else {
                            self.delegate?.didReceiveCameraPermissionWarning()
                        }
                    })
                    
                    return
                }
                
                return
            }
            
            DispatchQueue.main.async {
                let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
                videoPreviewLayer.videoGravity = .resizeAspectFill
                videoPreviewLayer.frame = self.vContainer.bounds
                videoPreviewLayer.masksToBounds = false
                videoPreviewLayer.setCornerRadius(10.0, border: 2.0, color: UIColor.darkBlueGrey.cgColor)
                self.vContainer.layer.addSublayer(videoPreviewLayer)
                
                self.setBlurViewHole()
                self.vContainer.bringSubview(toFront: self.blurView)
                self.scannerViewModel.setCapturePreviewLayer(videoPreviewLayer, scanningFrame: self.vScannerImage.frame)
            }
        }
    }
    
    // MARK: - Process
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

