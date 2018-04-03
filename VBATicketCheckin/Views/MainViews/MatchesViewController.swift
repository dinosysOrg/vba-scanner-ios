//
//  MatchesViewController.swift
//  VBATicketCheckin
//
//  Created by ngoclam on 3/9/18.
//  Copyright © 2018 Dinosys. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyJSON

class MatchesViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private let mainViewModel = MainViewModel.shared
    private let refreshControl = UIRefreshControl()
    var ticketScanningType = TicketScanningType.checkIn
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.getMatches()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setNavigationTitle("Danh sách trận đấu")
        self.setTabBarHidden(self.ticketScanningType != .checkIn)
        self.setNavigationHidden(false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.separatorStyle = .none
        self.tableView.estimatedRowHeight = 90.0
        
        // Configure Refresh Control
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl = refreshControl
        } else {
            self.tableView.addSubview(refreshControl)
        }
        
        let title = NSAttributedString(string: "Đang tải danh sách trận đấu...")
        self.refreshControl.attributedTitle = title
        self.refreshControl.addTarget(self, action: #selector(refreshMatchData(_:)), for: .valueChanged)
    }
    
    // MARK: - Process
    @objc private func refreshMatchData(_ sender: Any) {
        self.getMatches()
    }
    
    private func handleMatchesGettingError(_ error: APIError) {
        self.showAlert(title: "Lấy danh sách trận đấu không thành công", error: error, actionTitles: ["OK"], actions: [{ [weak self] errorAction in
            DispatchQueue.main.async {
                if error.type == APIErrorType.tokenExpired {
                    self?.logOut()
                }
            }}])
    }
    
    private func navigateToScanTicket() {
        let destination = Utils.viewController(withIdentifier: Constants.VIEWCONTROLLER_IDENTIFIER_SCAN_TICKET) as! ScanTicketViewController
        destination.ticketScanningType = self.ticketScanningType
        self.navigationController?.pushViewController(destination, animated: true)
    }
    
    // MARK: - API
    private func getMatches() {
        guard User.authorized else {
            self.logOut()
            return
        }
        
        if !self.refreshControl.isRefreshing {
            self.showLoading()
        }
        
        self.mainViewModel.getUpcomingMatches { [weak self] (matches, error) in
            DispatchQueue.main.async {
                self?.hideLoading()
                self?.refreshControl.endRefreshing()
                
                guard error == nil else {
                    self?.handleMatchesGettingError(error!)
                    return
                }
                
                self?.tableView.reloadData()
            }
        }
    }
}

extension MatchesViewController : UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mainViewModel.upcomingMatches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let matchCount = self.mainViewModel.upcomingMatches.count
        
        guard matchCount > 0 && indexPath.row < matchCount else {
            return UITableViewCell()
        }
        
        let cellIdentifier = "MatchCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! MatchCell
        let match = self.mainViewModel.upcomingMatches[indexPath.row]
        cell.setInfoWith(match)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
        
        let matchIndex = indexPath.row
        self.mainViewModel.setCurrentMatch(withIndex: matchIndex)
        self.navigateToScanTicket()
    }
}
