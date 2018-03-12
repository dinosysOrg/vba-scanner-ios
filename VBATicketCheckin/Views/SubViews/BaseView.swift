//
//  BaseView.swift
//  VBATicketCheckin
//
//  Created by ngoclam on 3/8/18.
//  Copyright © 2018 Dinosys. All rights reserved.
//

import UIKit

class BaseView: UIView {
    var parentView: UIView?
    var backgroundView: UIView?
    
    // MARK: - load UINib
    
    class func loadNib(of owner: UIView) -> UIView {
        let bundle = Bundle(for: type(of: owner))
        let nib = UINib(nibName: String(describing: type(of: owner)), bundle: bundle)
        let view = nib.instantiate(withOwner: owner, options: nil).first as! UIView
        
        return view
    }
    
    class func loadNib(of owner: UIView, at index: Int) -> UIView {
        let bundle = Bundle(for: type(of: owner))
        let nib = UINib(nibName: String(describing: type(of: owner)), bundle: bundle)
        let view = nib.instantiate(withOwner: owner, options: nil)[index] as! UIView
        
        return view
    }
    
    // MARK: - Format
    private func formatDefaultLabel(_ lbl: UILabel?) {
        lbl?.textColor = UIColor.black
        lbl?.font = UIFont.bold.S
    }
    
    func formatLabel(_ lbl: UILabel?, title: String?, color: UIColor) {
        self.formatDefaultLabel(lbl)
        lbl?.textColor = color
        lbl?.text = title
    }
    
    func formatMultipleLinesLabel(_ lbl: UILabel?, title: String?, color: UIColor) {
        self.formatLabel(lbl, title: title, color: color)
        lbl?.textAlignment = .center
        lbl?.lineBreakMode = .byWordWrapping
        lbl?.numberOfLines = 0
    }
    
    private func formatDefaultButton(_ btn: UIButton?) {
        btn?.titleLabel?.font = UIFont.bold.M
        btn?.setTitleColor(UIColor.white, for: .normal)
        btn?.backgroundColor = UIColor.gunmetal
        btn?.layer.setCornerRadius(10.0, border: 0.0, color: nil)
    }
    
    func formatButton(_ btn: UIButton?, title: String) {
        self.formatDefaultButton(btn)
        btn?.setTitle(title, for: .normal)
    }
    
    // MARK: - Virtual
    func viewDidDismiss() {
        // Will be overrided in its derived classes
    }
    
    // MARK: - Process
    // NOTE**: Show/dismiss popup view from its parent view. The following show(in:animated:) method ONLY USED for Popup View
    func show(in parent: UIView, animated: Bool) {
        self.parentView = parent
        self.backgroundView = UIView(frame: UIScreen.main.bounds)
        self.backgroundView!.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        self.parentView!.addSubview(self.backgroundView!)
        self.center = self.parentView!.center
        self.parentView!.addSubview(self)
        
        self.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        self.alpha = 0.0
        
        guard animated else {
            self.alpha = 1.0
            self.transform = .identity
            return
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 1.0
            self.transform = .identity
        }, completion: nil)
    }
    
    func dismiss(animated: Bool) {
        guard animated else {
            self.alpha = 0.0
            self.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            self.removeFromSuperview()
            self.backgroundView!.removeFromSuperview()
            
            self.viewDidDismiss()
            
            return
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0.0
            self.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        }) { (finished) in
            self.removeFromSuperview()
            self.backgroundView?.removeFromSuperview()
            self.viewDidDismiss()
        }
    }
    
    @objc func showWithAnimation(in parent: UIView) {
        self.show(in: parent, animated: true)
    }
    
    @objc func dismissWithAnimation() {
        self.dismiss(animated: true)
    }
}

extension BaseView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let view = touch.view, view.isKind(of: UIButton.classForCoder()) else {
            return true
        }
        
        return false
    }
}
