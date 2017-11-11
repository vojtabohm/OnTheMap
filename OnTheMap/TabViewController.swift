//
//  TabViewController.swift
//  OnTheMap
//
//  Created by Vojtěch Böhm on 11/11/2017.
//  Copyright © 2017 Vojtěch Böhm. All rights reserved.
//

import Foundation
import UIKit

class TabViewController: UIViewController {
    
    //MARK: Outlets
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var loadingView: UIView!
    
    //MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ParseClient.shared.delegates.append(self)
        
        if ParseClient.shared.state == .loading {
            loadingView.isHidden = false
        } else {
            loadingView.isHidden = true
        }
    }
}

//MARK: - TabViewController (UI)

extension TabViewController {
    func setLoading(enabled: Bool) {
        loadingView.isHidden = !(enabled)
    }
}

//MARK: - TabViewController (UITableViewDelegate)

extension TabViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let urlString = ParseClient.shared.studentLocations?[indexPath.row].mediaURL else {
            return
        }
        
        guard let url = URL(string: urlString), (urlString.contains("http://") || urlString.contains("https://")) else {
            showOKAlert(title: "Can't open link", message: "Invalid URL")
            return
        }
        
        UIApplication.shared.openURL(url)
    }
}

//MARK: - TabViewController (UITableViewDataSource)

extension TabViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = ParseClient.shared.studentLocations?.count else {
            return 0
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewPinCell") as! TableViewPinCell
        cell.studentLocation = ParseClient.shared.studentLocations?[indexPath.row]
        
        return cell
    }
}

//MARK: - TabViewController (ParseClientDelegate)

extension TabViewController: ParseClientDelegate {
    func changedState(_ state: ParseClient.State) {
        switch state {
        case .loading:
            setLoading(enabled: true)
        case .error:
            setLoading(enabled: false)
            showOKAlert(title: "Error", message: ParseClient.shared.error!)
        default:
            return
        }
    }
    
    func finishedDownloading() {
        setLoading(enabled: false)
        tableView.reloadData()
    }
}
