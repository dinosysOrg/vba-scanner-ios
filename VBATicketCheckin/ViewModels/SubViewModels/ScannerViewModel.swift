//
//  ScannerViewModel.swift
//  VBATicketCheckin
//
//  Created by ngoclam on 3/7/18.
//  Copyright © 2018 Dinosys. All rights reserved.
//

import Foundation
import AVFoundation

protocol ScannerViewModelDelegate: class {
    
    // #required
    
    // #optional
    func didExportMetadataOutput(_ output: String)
}

extension ScannerViewModelDelegate {
    
    func didExportMetadataOutput(_ output: String) {}
}

class ScannerViewModel: NSObject {
    
    weak var delegate: ScannerViewModelDelegate?
    
    var session: AVCaptureSession? {
        get {
            return _pSession
        }
    }
    
    private let _mainViewModel = MainViewModel.shared
    
    private var _pSession: AVCaptureSession!
    private var _videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private var _scanningRect = CGRect()
    private let _supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                       AVMetadataObject.ObjectType.code39,
                                       AVMetadataObject.ObjectType.code39Mod43,
                                       AVMetadataObject.ObjectType.code93,
                                       AVMetadataObject.ObjectType.code128,
                                       AVMetadataObject.ObjectType.ean8,
                                       AVMetadataObject.ObjectType.ean13,
                                       AVMetadataObject.ObjectType.aztec,
                                       AVMetadataObject.ObjectType.pdf417,
                                       AVMetadataObject.ObjectType.itf14,
                                       AVMetadataObject.ObjectType.dataMatrix,
                                       AVMetadataObject.ObjectType.interleaved2of5,
                                       AVMetadataObject.ObjectType.qr]
    
    init(with delegate: ScannerViewModelDelegate) {
        super.init()
        self.delegate = delegate
    }
    
    func initSession() -> AVCaptureSession? {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            log("Cannot create AVCaptureDevice")
            return nil
        }
        
        self._pSession = AVCaptureSession()
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            guard self._pSession.canAddInput(videoInput) else {
                return nil
            }
            
            self._pSession.addInput(videoInput)
            
            let metadataOutput = AVCaptureMetadataOutput()
            guard self._pSession.canAddOutput(metadataOutput) else {
                return nil
            }
            
            self._pSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = self._supportedCodeTypes
        } catch {
            log("Cannot create AVCaptureDeviceInput")
            return nil
        }
        
        return self._pSession
    }
    
    func setCapturePreviewLayer(_ previewLayer: AVCaptureVideoPreviewLayer, scanningFrame: CGRect) {
        self._videoPreviewLayer = previewLayer
        self._scanningRect = scanningFrame
    }
    
    //
    // MARK: - Process
    //
    func startScanner() {
        if let session = self._pSession, session.isRunning == false {
            session.startRunning()
        }
    }
    
    func stopScanner() {
        if let session = self._pSession, session.isRunning == true {
            session.stopRunning()
        }
    }
    
    func requestAVCaptureDeviceAccess(_ completion: ((_ requestGranted: Bool) -> Void)? = nil) {
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { [weak self] (granted: Bool) in
                self?._mainViewModel.setCameraPermissionGranted(granted)
                
                guard let complete = completion else {
                    return
                }
                
                complete(granted)
            })
            
            return
        }
        
        self._mainViewModel.setCameraPermissionGranted(true)
        
        if let complete = completion {
            complete(true)
        }
    }
}

extension ScannerViewModel: AVCaptureMetadataOutputObjectsDelegate {
    
    private func isFittedCodeObject(_ barCodeObject: AVMetadataObject) -> Bool {
        let barCodeObjectX = barCodeObject.bounds.origin.x
        let barCodeObjectY = barCodeObject.bounds.origin.y
        let barCodeObjectMaxX = barCodeObject.bounds.maxX
        let barCodeObjectMaxY = barCodeObject.bounds.maxY
        
        let scanningRectMinX = self._scanningRect.minX
        let scanningRectMinY = self._scanningRect.minY
        let scanningRectMaxX = scanningRectMinX + self._scanningRect.size.width
        let scanningRectMaxY = scanningRectMinY + self._scanningRect.size.height
        
        return (((barCodeObjectX >= scanningRectMinX) && (barCodeObjectMaxX <= scanningRectMaxX)) &&
            ((barCodeObjectY >= scanningRectMinY) && (barCodeObjectMaxY <= scanningRectMaxY)))
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            
            if self._supportedCodeTypes.contains(readableObject.type) {
                guard let videoPreviewLayer = self._videoPreviewLayer, let barCodeObject = videoPreviewLayer.transformedMetadataObject(for: readableObject) else {
                    return
                }
                
                if self.isFittedCodeObject(barCodeObject) {
                    guard let value = readableObject.stringValue else { return }
                    
                    self.stopScanner()
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                    self.delegate?.didExportMetadataOutput(value)
                }
            }
        }
    }
}
