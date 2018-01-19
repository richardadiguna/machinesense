//
//  HistoryDetailViewController.swift
//  machinesense
//
//  Created by Richard Adiguna on 19/01/18.
//  Copyright © 2018 Richard Adiguna. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD

class HistoryDetailViewController: UIViewController {

    var history: History?
    
    @IBOutlet weak var historyImageView: UIImageView!
    @IBOutlet weak var historyResultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let history = history {
            DispatchQueue.main.async {
                let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
                loadingNotification.mode = MBProgressHUDMode.indeterminate
                loadingNotification.label.text = "Downloading..."
            }
            getHistoryImage(from: history.savedImageURL, completion: { (image) in
                guard let image = image else { return }
                
                self.historyImageView.contentMode = .scaleAspectFit
                
                DispatchQueue.main.async {
                    self.historyImageView.image = image
                    self.historyResultLabel.text = history.result
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
                
            })
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func getHistoryImage(from url: String, completion: @escaping (UIImage?)->Void){
        let httpsRef = Storage.storage().reference(forURL: url)
        var image: UIImage?
        httpsRef.getData(maxSize: 15 * 1024 * 1024) { (data, error) in
            if let error = error {
                print(error)
            } else if let data = data {
                image = UIImage(data: data)
                image?.fixOrientation()
                completion(image)
            }
        }
    }
}
