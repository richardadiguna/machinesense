//
//  UserViewController.swift
//  machinesense
//
//  Created by Richard Adiguna on 25/12/17.
//  Copyright © 2017 Richard Adiguna. All rights reserved.
//

import UIKit
import Firebase

class UserViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userEmailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.isScrollEnabled = false
        
        if let email = Auth.auth().currentUser?.email {
            DispatchQueue.main.async {
                self.userEmailLabel.text = email
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension UserViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        switch indexPath.row {
        case 0:
            cell.userCellTitleLabel.text = "Edit Profile"
            return cell
        case 1:
            cell.userCellTitleLabel.text = "Settings"
            return cell
        case 2:
            cell.userCellTitleLabel.text = "Help"
            return cell
        case 3:
            cell.userCellTitleLabel.text = "Logout"
            cell.detailImageView.alpha = 0
            return cell
        default:
            return UITableViewCell()
        }
    }
    
}

extension UserViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 3:
            User.logoutUser {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SplashViewController")
                self.present(vc, animated: true, completion: nil)
            }
        default:
            return
        }
    }
    
}
