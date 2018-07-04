//
//  PopupView.swift
//  VBATicketCheckin
//
//  Created by ngoclam on 3/8/18.
//  Copyright © 2018 Dinosys. All rights reserved.
//

import UIKit

enum PopupViewType: Int {
    case normal = 0
    case withoutButton
}

enum PopupTitleType {
    case normal
    case green
    case red
}

enum PopupButtonTitleType {
    case payment
    case retry
    case ok
}

protocol PopupViewDelegate: class {
    // #required
    
    // #optional
    func didPopupViewRemoveFromSuperview()
}

extension PopupViewDelegate {
    
    func didPopupViewRemoveFromSuperview() {}
}

class PopupView: BaseView {
    
    @IBOutlet weak var vContainer: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var btnComplete: UIButton!
    
    @IBOutlet weak var constraintVContainerWidthRatio: NSLayoutConstraint!
    @IBOutlet weak var constraintLblTitleBottom: NSLayoutConstraint!
    
    weak var delegate: PopupViewDelegate?
    private var popupType = PopupViewType.normal
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    class func initWith(frame: CGRect, type: PopupViewType, delegate: PopupViewDelegate?) -> PopupView {
        let view = loadNib(of: PopupView(frame: frame) , at: type.rawValue) as! PopupView
        view.frame = frame
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = UIColor.clear
        view.popupType = type
        view.delegate = delegate
        
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    private func setAutoDismiss() {
        switch self.popupType {
        case .withoutButton:
            Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.dismissAnimated), userInfo: nil, repeats: false)
        default:
            break
        }
    }
    
    func loadingView(title: String?, message: String, titleType: PopupTitleType?, buttonType: PopupButtonTitleType?) {
        self.lblTitle.text = title
        self.constraintLblTitleBottom.isActive = title != nil
        self.lblMessage.text = message
        self.setTitleColorBy(type: titleType ?? .normal)
        self.setButtonTitleBy(type: buttonType ?? .ok)
        self.setAutoDismiss()
    }
    
    //
    // MARK: - Setup UI
    //
    private func setupUI() {
        self.constraintVContainerWidthRatio.constant = Constants.DEFAULT_POPUPVIEW_WIDTH_RATIO
        self.vContainer.layer.setCornerRadius(10.0, border: 0.0, color: nil)
        self.formatLabel(self.lblTitle, title: Constants.EMPTY_STRING, color: UIColor.black)
        self.formatMultipleLinesLabel(self.lblMessage, title: Constants.EMPTY_STRING, color: UIColor.black)
        self.formatButton(self.btnComplete, title: Constants.EMPTY_STRING)
    }
    
    func setTitleColorBy(type: PopupTitleType) {
        var titleColor = UIColor.black
        
        switch type {
        case .normal:
            titleColor = UIColor.black
        case .green:
            titleColor = UIColor.seaweedGreen
        case .red:
            titleColor = UIColor.reddish
        }
        
        self.lblTitle.textColor = titleColor
    }
    
    func setButtonTitleBy(type: PopupButtonTitleType) {
        var title = Constants.EMPTY_STRING
        
        switch type {
        case .payment:
            title = "THANH TOÁN VÉ"
        case .retry:
            title = "THỬ LẠI"
        case .ok:
            title = "OK"
        }
        
        self.formatButton(self.btnComplete, title: title)
    }
    
    //
    // MARK: - Actions
    //
    override func viewDidDismiss() {
        self.delegate?.didPopupViewRemoveFromSuperview()
    }
    
    @IBAction func btnComplete_clicked(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
