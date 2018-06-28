//
//  BaseViewController.swift
//  VBATicketCheckin
//
//  Created by ngoclam on 3/8/18.
//  Copyright © 2018 Dinosys. All rights reserved.
//

import UIKit

enum RootViewControllerType {
    case login
    case tabBar
}

enum ViewBackgroundColorType {
    case normal
    case clear
    case gunmetal
}

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setViewBackgroundColor(by: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setTabBarHidden(true)
        self.setNavigationHidden(false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    //
    // MARK: - Format
    //
    func setNavigationHidden(_ isHidden: Bool) {
        self.navigationController?.navigationBar.layer.zPosition = isHidden ? -1 : 0
    }
    
    func setTabBarHidden(_ isHidden: Bool) {
        self.tabBarController?.tabBar.isHidden = isHidden
    }
    
    func setViewBackgroundColor(by type: ViewBackgroundColorType) {
        switch type {
        case .gunmetal:
            self.view.backgroundColor = UIColor.gunmetal
        case .clear:
            self.view.backgroundColor = UIColor.clear
        default:
            self.view.backgroundColor = UIColor.viewBackground
        }
    }
    
    private func formatDefaultLabel(_ lbl: UILabel?) {
        lbl?.textColor = UIColor.black
        lbl?.font = UIFont.bold.S
    }
    
    func formatLabel(_ lbl: UILabel?, title: String?, color: UIColor) {
        self.formatDefaultLabel(lbl)
        lbl?.textColor = color
        lbl?.text = title
    }
    
    func formatExtraLargeBoldLabel(_ lbl: UILabel?, title: String?, color: UIColor) {
        self.formatLabel(lbl, title: title, color: color)
        lbl?.font = UIFont.bold.XXXXL
    }
    
    func formatMultipleLinesLabel(_ lbl: UILabel?, title: String?, color: UIColor) {
        self.formatLabel(lbl, title: title, color: color)
        lbl?.textAlignment = .center
        lbl?.lineBreakMode = .byWordWrapping
        lbl?.numberOfLines = 0
    }
    
    private func formatDefaultButton(_ btn: UIButton?) {
        btn?.setTitleColor(UIColor.white, for: .normal)
        btn?.backgroundColor = UIColor.gunmetal
        btn?.layer.setCornerRadius(10.0, border: 0.0, color: nil)
        btn?.titleLabel?.font = UIFont.bold.M
        btn?.titleLabel?.textAlignment = .center
        btn?.titleLabel?.lineBreakMode = .byWordWrapping
        btn?.titleLabel?.numberOfLines = 2
    }
    
    func formatButton(_ btn: UIButton?, title: String) {
        self.formatDefaultButton(btn)
        btn?.setTitle(title, for: .normal)
    }
    
    func formatTextField(_ tf: UITextField, placeHolder: String, keyboardType: UIKeyboardType, active: Bool) {
        tf.text = Constants.EMPTY_STRING
        tf.font = UIFont.bold.XXXXXL
        tf.textColor = UIColor.white
        tf.tintColor = UIColor.white
        tf.keyboardType = keyboardType
        tf.attributedPlaceholder = NSAttributedString(string: placeHolder,
                                                      attributes: [ NSAttributedStringKey.foregroundColor: UIColor.white ])
        
        if active {
            tf.becomeFirstResponder()
        }
    }
    
    func formatView(_ view: UIView) {
        view.backgroundColor = UIColor.gunmetal
        view.layer.setCornerRadius(10.0, border: 0.0, color: nil)
    }
    
    //
    // MARK: - Process
    //
    @objc func endEditing() {
        self.view.endEditing(true)
    }
    
    func showLoading() {
        ProgressView.shared.show(self.view)
    }
    
    func hideLoading() {
        ProgressView.shared.hide()
    }
    
    func isProgressLoading() -> Bool {
        return ProgressView.shared.isLoading
    }
    
    func setNavigationTitle(_ title: String) {
        self.navigationItem.title = title
    }
    
    func setRootViewController(withType type: RootViewControllerType) {
        let root: UIViewController?
        
        switch type {
        case .login:
            root = Utils.viewController(withIdentifier: Constants.VIEWCONTROLLER_IDENTIFIER_LOGIN) as! LoginViewController
        case .tabBar:
            root = Utils.viewController(withIdentifier: Constants.VIEWCONTROLLER_IDENTIFIER_TAB_BAR) as! TabBarController
        }
        
        Constants.APP_DELEGATE.window?.rootViewController = root
        Constants.APP_DELEGATE.window?.makeKeyAndVisible()
    }
    
    /// Enable/Disable navigation's PopGestureRecognizer when popup shown
    ///
    /// - Parameter enable: boolean
    func setNavigationSwipeEnable(_ enable: Bool) {
        self.view.isUserInteractionEnabled = !enable
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = enable
    }
    
    func gotoAppSetting() {
        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    log("Settings opened: \(success)")
                })
            } else {
                UIApplication.shared.openURL(settingsUrl)
            }
        }
    }
    
    func showCameraPermissionError() {
        self.showAlert(title: "Truy cập camera không thành công", message: "Vui lòng cho phép ứng dụng truy cập camera", actionTitles: ["Cancel", "OK"], actions: [{ cancel in
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }}, { [weak self] ok in
                DispatchQueue.main.async {
                    self?.gotoAppSetting()
                }
            }]
        )
    }
    
    func popToScanTicket() {
        for vc in (self.navigationController?.viewControllers ?? []) {
            if vc is ScanTicketViewController {
                _ = self.navigationController?.popToViewController(vc, animated: true)
                return
            }
        }
    }
    
    func logOut() {
        User.current?.signOut()
        self.setRootViewController(withType: .login)
    }
    
    //
    // MARK: - Components initialization
    //
    func initPopupView(frame: CGRect, type: PopupViewType, delegate: PopupViewDelegate?) -> PopupView {
        return PopupView.initWith(frame: frame, type: type, delegate: delegate)
    }
}
