//
//  ProgressView.swift
//  VBATicketCheckin
//
//  Created by ngoclam on 3/9/18.
//  Copyright © 2018 Dinosys. All rights reserved.
//

import UIKit

class ProgressView {
    private var containerView = UIView()
    private var progressView = UIView()
    private var activityIndicator = UIActivityIndicatorView()
    private var pIsLoading = false
    
    static var shared: ProgressView {
        struct Static {
            static let instance: ProgressView = ProgressView()
        }
        
        return Static.instance
    }
    
    var isLoading: Bool {
        get {
            return pIsLoading
        }
    }
    
    func show(_ view: UIView) {
        containerView.frame = view.frame
        containerView.center = view.center
        Utils.setView(containerView, transparentWith: UIColor.viewBackgroundTwo, alpha: Constants.COLOR_ALPHA_VIEW)
        
        progressView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        progressView.center = view.center
        progressView.backgroundColor = UIColor.color(UIColor.gunmetal, alpha: Constants.COLOR_ALPHA_VIEW)
        progressView.clipsToBounds = true
        progressView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.center = CGPoint(x: progressView.bounds.width / 2, y: progressView.bounds.height / 2)
        
        progressView.addSubview(activityIndicator)
        containerView.addSubview(progressView)
        view.addSubview(containerView)
        
        activityIndicator.startAnimating()
        pIsLoading = true
    }
    
    func hide() {
        activityIndicator.stopAnimating()
        containerView.removeFromSuperview()
        pIsLoading = false
    }
}

extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat) {
        let red = CGFloat((hex & 0xFF0000) >> 16)/256.0
        let green = CGFloat((hex & 0xFF00) >> 8)/256.0
        let blue = CGFloat(hex & 0xFF)/256.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
