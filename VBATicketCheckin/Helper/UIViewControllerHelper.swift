//
//  UIViewControllerHelper.swift
//  VBATicketCheckin
//
//  Created by Bui Minh Duc on 12/15/17.
//  Copyright © 2017 Dinosys. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    //Show Normal Alert
    func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        self.present(ac, animated: true, completion: nil)
    }
    
    //Show Alert with Action
    func showAlert(title: String, message: String, actionTitles:[String?], actions:[((UIAlertAction) -> Void)?]) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        for (index, title) in actionTitles.enumerated() {
            let action = UIAlertAction(title: title, style: .default, handler: actions[index])
            ac.addAction(action)
        }
        
        self.present(ac, animated: true, completion: nil)
    }
    
    //Show Error Alert
    func showAlert(title: String, error: APIError) {
        let ac = UIAlertController(title: title, message: error.message, preferredStyle: .alert)
        
        self.present(ac, animated: true)
    }
    
    //Show Error Alert with Action
    func showAlert(title: String, error: APIError, actionTitles:[String?], actions:[((UIAlertAction) -> Void)?]) {
        let ac = UIAlertController(title: title, message: error.message, preferredStyle: .alert)
        
        for (index, title) in actionTitles.enumerated() {
            let action = UIAlertAction(title: title, style: .default, handler: actions[index])
            ac.addAction(action)
        }
        
        self.present(ac, animated: true)
    }
}
