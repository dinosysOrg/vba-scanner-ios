//
//  MainViewController.swift
//  VBATicketCheckin
//
//  Created by Bui Minh Duc on 11/21/17.
//  Copyright © 2017 Dinosys. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyJSON

class MainViewController: UIViewController {
    
    let mainViewModel = MainViewModel.sharedInstance
    
    let cell = "matchCell"
    
    let cellHeight : CGFloat = 68
    
    private let refreshControl = UIRefreshControl()
    
    // Match
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateUI()
        
        if User.sharedInstance.IsAuthorized {
            self.showLoadinng()
            self.getMatches()
        }
    }
    
    func updateUI(){
        
        // Configure Refresh Control
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl = refreshControl
        } else {
            self.tableView.addSubview(refreshControl)
        }
        
        let refreshControlAttributedTitle = NSAttributedString(string: "Đang tải danh sách trận đấu...")
        
        self.refreshControl.attributedTitle = refreshControlAttributedTitle
        self.refreshControl.addTarget(self, action: #selector(refreshMatchData(_:)), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Set title
        self.title = "Danh sách trận đấu"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Unset title
        self.title = ""
    }
}

extension MainViewController : UITableViewDelegate, UITableViewDataSource {
    
    func getMatches() {
        self.mainViewModel.getUpcomingMatches(completion: { (success, error) in
            self.hideLoading()
            self.refreshControl.endRefreshing()
            if success {
                self.tableView.reloadData()
            } else if let getMatchError = error {
                self.showAlert(title: "Lấy danh sách trận đấu không thành công", error: getMatchError, actionTitles: ["OK"], actions:[{errorAction in
                    if getMatchError.type == APIErrorType.tokenExpired {
                        User.sharedInstance.signOut()
                        self.dismiss(animated: true, completion: nil)
                    }}])
            }
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mainViewModel.upcomingMatches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let matchIndex = indexPath.row
        let matchCount = self.mainViewModel.upcomingMatches.count
        
        if  matchCount > 0 && matchIndex < matchCount {
            let match = self.mainViewModel.upcomingMatches[matchIndex]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: self.cell) as! MatchCell
            
            cell.setMatchInfoWith(match: match)
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let matchIndex = indexPath.row
        
        self.mainViewModel.setCurrentMatch(withIndex: matchIndex)
        
        self.showQRCodeScanner()
    }
    
    @objc private func refreshMatchData(_ sender: Any) {
        self.getMatches()
    }
    
    func showQRCodeScanner(){
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let destination = storyboard.instantiateViewController(withIdentifier: "ScanTicketViewController") as! ScanTicketViewController
        
        self.navigationController?.pushViewController(destination, animated: true)
    }
    
    func showLoadinng(){
        loadingIndicator.isHidden = false
    }
    
    func hideLoading(){
        loadingIndicator.isHidden = true
    }
}
