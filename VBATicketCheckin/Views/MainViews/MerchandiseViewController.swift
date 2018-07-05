//
//  MerchandiseViewController.swift
//  VBATicketCheckin
//
//  Created by ngoclam on 3/8/18.
//  Copyright © 2018 Dinosys. All rights reserved.
//

import UIKit

class MerchandiseViewController: BaseViewController {
    
    @IBOutlet weak var vContainer: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tfPoint: UITextField!
    @IBOutlet weak var btnScan: UIButton!
    
    private var _point: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setNavigationTitle("Merchandise")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //
    // MARK: - Setup UI
    //
    func setupUI() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.endEditing))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        
        self.formatLabel(self.lblTitle, title: "Nhập số điểm cần để nhận vật phẩm", color: UIColor.white)
        self.formatTextField(self.tfPoint, placeHolder: Constants.EMPTY_STRING, keyboardType: .numberPad, active: true)
        self.tfPoint.delegate = self
        
        self.formatButton(self.btnScan, title: "QUYÉT MÃ THANH TOÁN")
        self.setBtnScanEnabled(false)
    }
    
    //
    // MARK: - Format
    //
    private func setBtnScanEnabled(_ isEnabled: Bool) {
        self.btnScan.isEnabled = isEnabled
    }
    
    //
    // MARK: - Actions
    //
    @IBAction func btnScan_Pressed(_ sender: UIButton) {
        if let destination = Utils.viewController(withIdentifier: Constants.VIEWCONTROLLER_IDENTIFIER_USER_QRCODE_SCANNING) as? UserQRCodeScanningViewController {
            destination.scanningType = .merchandise
            destination.merchandisePoint = self._point
            self.navigationController?.pushViewController(destination, animated: true)
        }
    }
}

//
// MARK: - UIGestureRecognizerDelegate
//
extension MerchandiseViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let view = touch.view, view.isKind(of: UIButton.classForCoder()) else {
            return true
        }
        
        return false
    }
}

//
// MARK: - UITextFieldDelegate
//
extension MerchandiseViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let isValidInput = !((range.location == 0) && (string == Constants.ZERO_STRING)) && (Utils.isNumeric(string) || Utils.isBackSpace(string))
        let buttonEnabled = isValidInput || !Utils.isEmpty(self._point)
        
        self.setBtnScanEnabled(buttonEnabled)
        
        if isValidInput {
            let sourceText = textField.text as NSString?
            let text = sourceText?.replacingCharacters(in: range, with: string)
            self._point = Utils.removeWhiteSpaces(of: text ?? Constants.EMPTY_STRING)
        }
        
        return isValidInput
    }
}
