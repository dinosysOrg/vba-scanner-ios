//
//  MainViewController.swift
//  VBATicketCheckin
//
//  Created by Bui Minh Duc on 11/21/17.
//  Copyright © 2017 Dinosys. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyJSON

class MainViewController: UIViewController {
    
    let mainViewModel = MainViewModel()
    
    let cell = "matchCell"
    
    let cellHeight : CGFloat = 60
    
    var captureSession: AVCaptureSession!
    
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    // Match
    
    @IBOutlet weak var matchesContainerView: UIView!
    
    @IBOutlet weak var matchesHeaderView: UIView!
    
    @IBOutlet weak var matchesLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var selectMatchButton: UIButton!
    
    // QR Code
    
    @IBOutlet weak var qrCodeContainerView: UIView!
    
    @IBOutlet weak var scannerImageView: UIImageView!
    
    @IBOutlet weak var scannerContainnerView: UIView!
    
    // Check In
    
    @IBOutlet weak var checkInViewContainer: UIView!
    
    @IBOutlet weak var checkInView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var quantityLabel: UILabel!
    
    @IBOutlet weak var ticketTypeLabel: UILabel!
    
    @IBOutlet weak var paidLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var payButton: UIButton!
    
    @IBOutlet weak var checkInButton: UIButton!
    
    @IBOutlet weak var rescanButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateUI()
        
        if User.sharedInstance.IsAuthorized {
            self.getUpcomingMatches()
        }
        hideQRCodeScanner()
        hideCheckInView()
        hideCheckInButton()
        hideReScanButton()
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
    
    func updateUI(){
        // Match
        self.matchesContainerView.layer.cornerRadius = 10
        self.matchesContainerView.clipsToBounds = true
        
        // Check In View
        self.checkInView.layer.cornerRadius = 10
        self.checkInView.clipsToBounds = true
    }
    
    func showError(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.startScanner()
        }))
        present(ac, animated: true)
    }
    
    func showError(title: String, error: APIError) {
        let ac = UIAlertController(title: title, message: error.message, preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if error.type == APIErrorType.tokenExpired {
                User.sharedInstance.signOut()
                self.dismiss(animated: true, completion: nil)
            } else
            {
                self.startScanner()
            }
        }))
        present(ac, animated: true)
    }
    
    @IBAction func cancelled(_ sender: UIButton) {
        self.hideCheckInView()
        self.hideCheckInButton()
        self.hideReScanButton()
    }
    
    @IBAction func paid(_ sender: UIButton) {
        self.mainViewModel.purchaseTicket { (succeed, error) in
            if (succeed) {
                self.paidLabel.text = "Đã thanh toán"
                self.statusLabel.text = "Đã sử dụng"
                self.showReScanButton()
            } else if let paidError = error {
                self.showError(title: "Thanh toán vé không thành công", error: paidError)
            }
        }
    }
    
    @IBAction func matchSelected(_ sender: UIButton) {
        self.stopScanner()
        self.hideCheckInView()
        self.hideQRCodeScanner()
    }
}

extension MainViewController : UITableViewDelegate, UITableViewDataSource {
    
    func getUpcomingMatches() {
        self.mainViewModel.getUpcomingMatches(completion: { (success, error) in
            if success {
                self.tableView.reloadData()
                self.setupScanner()
            } else if let getMatchError = error {
                self.showError(title: "Lấy danh sách trận đấu không thành công", error: getMatchError)
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
        let matchCount = self.mainViewModel.upcomingMatches.count
        
        if  matchCount > 0 && matchIndex < matchCount {
            let match = self.mainViewModel.upcomingMatches[matchIndex]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: self.cell) as! MatchCell
            
            cell.setMatchInfoWith(match: match)
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let matchIndex = indexPath.row
        
        self.mainViewModel.setSelectedMatchWith(index: matchIndex)
        
        self.showQRCodeScanner()
    }
    
    func showSelectMatchButton(){
        self.selectMatchButton.isHidden = false
    }
    
    func hideSelectMatchButton(){
        self.selectMatchButton.isHidden = true
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
    
    func showQRCodeScanner(){
        self.showSelectMatchButton()
        self.startScanner()
        self.qrCodeContainerView.isHidden = false
    }
    
    func hideQRCodeScanner(){
        self.qrCodeContainerView.isHidden = true
        self.hideSelectMatchButton()
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
        let message = "Thiết bị của bạn không hỗ trỡ quét mã. Xin hãy sử dụng thiết bị khác."
        
        self.showError(title: title, message: message)
        
        captureSession = nil
    }
    
    // Code scanned, verify ticket with that code
    func codeScanned(code : String) {
        self.mainViewModel.verifyTicket(ticketJsonString: code) { (ticket, error) in
            if (ticket != nil) {
                self.showCheckinViewWith(ticket: ticket!)
            } else if let getMatchError = error {
                self.showError(title: "Check in vé không thành công", error: getMatchError)
            }
        }
    }
}

extension MainViewController {
    
    func showCheckInView(){
        self.hideSelectMatchButton()
        self.checkInViewContainer.isHidden = false
    }
    
    func hideCheckInView(){
        self.showSelectMatchButton()
        self.checkInViewContainer.isHidden = true
        self.startScanner()
    }
    
    func showCheckInButton(){
        self.checkInButton.isHidden = false
    }
    
    func hideCheckInButton(){
        self.checkInButton.isHidden = true
    }
    
    func showReScanButton(){
        self.rescanButton.isHidden = false
    }
    
    func hideReScanButton(){
        self.rescanButton.isHidden = true
    }
    
    func updateTicketUI() {
        if let ticket = self.mainViewModel.currentTicket {
            self.nameLabel.text = ticket.name
            self.quantityLabel.text = String(ticket.quantity)
            self.ticketTypeLabel.text = ticket.ticketType
            self.paidLabel.text = ticket.paid ? "Đã thanh toán" : "Chưa thanh toán"
            self.statusLabel.text = ticket.used ? "Đã sử dụng" : "Chưa sử dụng"
            
            if ticket.used && ticket.paid {
                self.showCheckInButton()
            } else {
                self.hideCheckInButton()
            }
        }
    }
    
    // Show Check In View with Verified Ticket
    func showCheckinViewWith(ticket: Ticket) {
        self.mainViewModel.currentTicket = ticket
        self.updateTicketUI()
        self.showCheckInView()
    }
}
