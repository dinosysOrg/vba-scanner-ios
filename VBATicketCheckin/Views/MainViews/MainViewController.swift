//
//  MainViewController.swift
//  VBATicketCheckin
//
//  Created by Bui Minh Duc on 11/21/17.
//  Copyright © 2017 Dinosys. All rights reserved.
//

import UIKit
import AVFoundation

class MainViewController: UIViewController {
    
    let mainViewModel = MainViewModel()
    
    let cell = "cell"
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    @IBOutlet weak var matchesContainerView: UIView!
    
    @IBOutlet weak var matchesHeaderView: UIView!
    
    @IBOutlet weak var matchesLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var qrCodeContainerView: UIView!
    
    @IBOutlet weak var scannerImageView: UIImageView!
    
    @IBOutlet weak var scannerContainnerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if User.sharedInstance.IsAuthorized {
            self.getUpcomingMatches()
        }
        setupScanner()
        hideQRCodeScanner()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startScanner()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopScanner()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    func showError(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(ac, animated: true)
    }
    
    func showQRCodeScanner(){
        self.qrCodeContainerView.isHidden = false
    }
    
    func hideQRCodeScanner(){
        self.qrCodeContainerView.isHidden = true
    }
}

extension MainViewController : UITableViewDelegate, UITableViewDataSource {
    
    func getUpcomingMatches() {
        self.mainViewModel.getUpcomingMatches(completion: { (success, error) in
            if success {
                self.tableView.reloadData()
            } else if let getMatchError = error {
                self.showError(title: "Lấy danh sách trận đấu không thành công", message: getMatchError.message!)
            }
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mainViewModel.upcomingMatches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let matchIndex = indexPath.row
        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cell)
        
        cell!.textLabel!.text = self.mainViewModel.upcomingMatches[matchIndex].name
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.showQRCodeScanner()
    }
}


extension MainViewController : AVCaptureMetadataOutputObjectsDelegate {
    
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
        previewLayer.frame = self.scannerContainnerView.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        self.scannerContainnerView.layer.addSublayer(previewLayer)
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
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            codeScanned(code: stringValue)
        }
    }
    
    func setupScannerFailed() {
        let title = "Thiết lập trình quét mã không thành công"
        let message = "Thiết bị của bạn không hỗ trỡ quét mã. Xin hãy sử dụng thiết bị khác."
        
        self.showError(title: title, message: message)
        
        captureSession = nil
    }
    
    func codeScanned(code : String) {
        
    }
}
