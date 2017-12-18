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

class ScanTicketViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    let mainViewModel = MainViewModel.sharedInstance
    
    var captureSession: AVCaptureSession!
    
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    // QR Code
    
    @IBOutlet weak var qrCodeContainerView: UIView!
    
    @IBOutlet weak var scannerImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        
        self.setupScanner()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Scan Vé"
        
        self.startScanner()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.title = ""
        
        self.stopScanner()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    func setupScanner(){
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            setupScannerFailed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr, .ean8, .ean13, .pdf417]
        } else {
            self.setupScannerFailed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = self.qrCodeContainerView.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        
        self.qrCodeContainerView.layer.addSublayer(previewLayer)
    }
    
    
    func startScanner(){
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    func stopScanner(){
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    // Callback qr code scanned
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            self.stopScanner()
            
            codeScanned(code: stringValue)
        }
    }
    
    // Display error if scanner setup failed
    func setupScannerFailed() {
        let title = "Thiết lập trình quét mã không thành công"
        let message = "Thiết bị của bạn không hỗ trợ quét mã. Xin hãy sử dụng thiết bị khác."
        
        self.showAlert(title: title, message: message)
        
        captureSession = nil
    }
    
    // Code scanned, verify ticket with that code
    func codeScanned(code : String) {
        self.mainViewModel.verifyTicket(ticketJsonString: code) { (ticket, error) in
            if (ticket != nil) {
                self.showScanResultView()
            } else if let verifyTicketError = error {
                self.showAlert(title: "Check in vé không thành công", error: verifyTicketError, actionTitles: ["OK"], actions:[{errorAction in
                    if verifyTicketError.type == APIErrorType.tokenExpired {
                        User.sharedInstance.signOut()
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        self.startScanner()
                    }}])
            }
        }
    }
    
    func showScanResultView() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let destination = storyboard.instantiateViewController(withIdentifier: "ScanResultViewController") as! ScanResultViewController
        
        self.navigationController?.pushViewController(destination, animated: true)
    }
}
