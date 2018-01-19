//
//  HistoryViewController.swift
//  machinesense
//
//  Created by Richard Adiguna on 25/12/17.
//  Copyright © 2017 Richard Adiguna. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD

class HistoryViewController: UIViewController {
    
    lazy var databaseRef: DatabaseReference = Database.database().reference()
    
    var historyRefHandle: DatabaseHandle?
    
    var historiesArray: [History] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "History"
        
        tableView.dataSource = self
        tableView.delegate = self
        
        configureNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        fetchAllHistory()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureNavigationBar() {
        self.navigationItem.searchController = UISearchController(searchResultsController: nil)
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    fileprivate func fetchAllHistory() {
        historiesArray.removeAll()
        DispatchQueue.main.async {
            let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.indeterminate
            loadingNotification.label.text = "Fetching..."
        }
        History.fetchAllHistoryWithSingleEvent(uid: User.uid, completion: { (snapshot) in
            if !snapshot.exists() {
                return
            }
            let histories = snapshot.value as! [String: Any]
         
            for history in histories {
                guard let historyDict = history.value as? [String: Any] else { return }
                
                let history = self.createHistoryInstance(historyDict: historyDict)
                
                self.historiesArray.append(history)
            }
            self.tableView.reloadData()
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        })
    }
    
    func createHistoryInstance(historyDict: [String: Any]) -> History {
        let addedDateTimeString = historyDict["addedDateTime"] as! String
        let result = historyDict["result"] as! String
        let type = historyDict["type"] as! Int
        let savedImageURL = historyDict["savedImageURL"] as! String
        
        let addedDateTime = convertStringToDate(dateString: addedDateTimeString)
        
        guard let categoryType = CategoryType(rawValue: type) else { return History() }
        
        let history = History(addedDateTime: addedDateTime, type: categoryType.rawValue, result: result)
        history.savedImageURL = savedImageURL
        
        return history
    }
    
    func convertStringToDate(dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        
        let date = formatter.date(from: dateString)
        return date ?? Date()
    }
    
}

extension HistoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historiesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HistoryCell.identifier, for: indexPath) as! HistoryCell
        cell.historyDateTimeLabel.text = historiesArray[indexPath.row].addedDateTime
        return cell
    }
    
}

extension HistoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let historyToPass = historiesArray[indexPath.row]
        performSegue(withIdentifier: "goToHistoryDetailSegue", sender: historyToPass)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToHistoryDetailSegue" {
            let vc = segue.destination as! HistoryDetailViewController
            let sender = sender as! History
            vc.history = sender
        }
    }

}
