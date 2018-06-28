//
//  ProgressView.swift
//  VBATicketCheckin
//
//  Created by ngoclam on 3/9/18.
//  Copyright © 2018 Dinosys. All rights reserved.
//

import UIKit

class ProgressView {
    
    private var _containerView = UIView()
    private var _progressView = UIView()
    private var _activityIndicator = UIActivityIndicatorView()
    private var _pIsLoading = false
    
    static var shared: ProgressView {
        struct Static {
            static let instance = ProgressView()
        }
        
        return Static.instance
    }
    
    var isLoading: Bool {
        get {
            return _pIsLoading
        }
    }
    
    func show(_ view: UIView) {
        self._containerView.frame = view.frame
        self._containerView.center = view.center
        Utils.setView(self._containerView, transparentWith: UIColor.viewBackgroundTwo, alpha: Constants.COLOR_ALPHA_VIEW)
        
        self._progressView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        self._progressView.center = view.center
        self._progressView.backgroundColor = UIColor.color(UIColor.gunmetal, alpha: Constants.COLOR_ALPHA_VIEW)
        self._progressView.clipsToBounds = true
        self._progressView.layer.cornerRadius = 10
        
        self._activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        self._activityIndicator.activityIndicatorViewStyle = .whiteLarge
        self._activityIndicator.center = CGPoint(x: self._progressView.bounds.width / 2, y: self._progressView.bounds.height / 2)
        
        self._progressView.addSubview(self._activityIndicator)
        self._containerView.addSubview(self._progressView)
        view.addSubview(self._containerView)
        
        self._activityIndicator.startAnimating()
        self._pIsLoading = true
    }
    
    func hide() {
        self._activityIndicator.stopAnimating()
        self._containerView.removeFromSuperview()
        self._pIsLoading = false
    }
}

extension UIColor {
    
    convenience init(hex: UInt32, alpha: CGFloat) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 256.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 256.0
        let blue = CGFloat(hex & 0xFF) / 256.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
