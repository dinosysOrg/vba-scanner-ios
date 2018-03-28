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
    
    private var pSession: AVCaptureSession!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private var scanningRect = CGRect()
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
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
        
        pSession = AVCaptureSession()
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            guard pSession.canAddInput(videoInput) else {
                return nil
            }
            
            pSession.addInput(videoInput)
            
            let metadataOutput = AVCaptureMetadataOutput()
            guard pSession.canAddOutput(metadataOutput) else {
                return nil
            }
            
            pSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = self.supportedCodeTypes
        } catch {
            log("Cannot create AVCaptureDeviceInput")
            return nil
        }
        
        return pSession
    }
    
    func setCapturePreviewLayer(_ previewLayer: AVCaptureVideoPreviewLayer, scanningFrame: CGRect) {
        self.videoPreviewLayer = previewLayer
        self.scanningRect = scanningFrame
    }
    
    // MARK: - Process
    func startScanner() {
        if self.pSession?.isRunning == false {
            self.pSession.startRunning()
        }
    }
    
    func stopScanner() {
        if self.pSession?.isRunning == true {
            self.pSession.stopRunning()
        }
    }
    
    func requestAVCaptureDeviceAccess(_ completion: ((_ requestGranted: Bool) -> Void)?) {
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                guard let complete = completion else {
                    return
                }
                
                complete(granted)
            })
            
            return
        }
    }
}

extension ScannerViewModel: AVCaptureMetadataOutputObjectsDelegate {
    private func isFittedCodeObject(_ barCodeObject: AVMetadataObject) -> Bool {
        let barCodeObjectX = barCodeObject.bounds.origin.x
        let barCodeObjectY = barCodeObject.bounds.origin.y
        let barCodeObjectMaxX = barCodeObject.bounds.maxX
        let barCodeObjectMaxY = barCodeObject.bounds.maxY
        
        let scanningRectMinX = self.scanningRect.minX
        let scanningRectMinY = self.scanningRect.minY
        let scanningRectMaxX = scanningRectMinX + self.scanningRect.size.width
        let scanningRectMaxY = scanningRectMinY + self.scanningRect.size.height
        
        return (((barCodeObjectX >= scanningRectMinX) && (barCodeObjectMaxX <= scanningRectMaxX)) &&
            ((barCodeObjectY >= scanningRectMinY) && (barCodeObjectMaxY <= scanningRectMaxY)))
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            
            if self.supportedCodeTypes.contains(readableObject.type) {
                guard let barCodeObject = self.videoPreviewLayer!.transformedMetadataObject(for: readableObject) else {
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
