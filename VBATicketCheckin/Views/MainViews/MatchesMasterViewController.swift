//
//  MatchesMasterViewController.swift
//  VBATicketCheckin
//
//  Created by lamnguyen on 6/27/18.
//  Copyright © 2018 Dinosys. All rights reserved.
//

import UIKit

class MatchesMasterViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.delegate = self
        self.preferredDisplayMode = .allVisible
        self.setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //
    // MARK: - Setup UI
    //
    func setupUI() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.didTapScreen))
        tap.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(tap)
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    //
    // MARK: - Process
    //
    @objc func didTapScreen() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension MatchesMasterViewController: UISplitViewControllerDelegate {
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        // Return true to prevent UIKit from applying its default behavior
        return true
    }
}
