//
//  TabBarController.swift
//  VBATicketCheckin
//
//  Created by ngoclam on 3/7/18.
//  Copyright © 2018 Dinosys. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    static var shared = TabBarController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.setupTabBarItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Setup UI
    private func setupTabBarItem() {
        let defaultColor = UIColor.coolGrey
        let selectedColor = UIColor.black
        let titleFont = UIFont.bold.M
        
        let normalAtt = [ NSAttributedStringKey.foregroundColor : defaultColor,
                          NSAttributedStringKey.font : titleFont ]
        
        let selectedAtt = [ NSAttributedStringKey.foregroundColor : selectedColor,
                            NSAttributedStringKey.font : titleFont ]
        
        UITabBarItem.appearance().setTitleTextAttributes(normalAtt, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(selectedAtt, for: .selected)
    }
    
    // MARK: - UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transitioningObject: TransitioningObject = TransitioningObject()
        transitioningObject.tabBarController = self
        return transitioningObject
    }
}

class TransitioningObject: NSObject, UIViewControllerAnimatedTransitioning {
    weak var tabBarController: TabBarController!
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromView: UIView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let fromViewController: UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toView: UIView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        let toViewController: UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        
        transitionContext.containerView.addSubview(fromView)
        transitionContext.containerView.addSubview(toView)
        
        let fromViewControllerIndex = (self.tabBarController.viewControllers! as [UIViewController]).index { (vc) -> Bool in
            vc == fromViewController
        }
        
        let toViewControllerIndex = (self.tabBarController.viewControllers! as [UIViewController]).index { (vc) -> Bool in
            vc == toViewController
        }
        
        // 1 will slide left, -1 will slide right
        var directionInteger: CGFloat!
        if fromViewControllerIndex! < toViewControllerIndex! {
            directionInteger = 1
        } else {
            directionInteger = -1
        }
        
        toView.frame = CGRect(x: directionInteger * toView.frame.width, y: 0, width: toView.frame.width, height: toView.frame.height)
        let fromNewFrame = CGRect(x: -1 * directionInteger * fromView.frame.width, y: 0, width: fromView.frame.width, height: fromView.frame.height)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { () -> Void in
            toView.frame = fromView.frame
            fromView.frame = fromNewFrame
        }) { (Bool) -> Void in
            transitionContext.completeTransition(true)
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
}
