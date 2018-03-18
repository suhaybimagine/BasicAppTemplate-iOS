//
//  HomeViewController.swift
//  OffersMatch
//
//  Created by Ali Hajjaj on 3/14/18.
//  Copyright © 2018 Ali Hajjaj. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func logoutCurrentUser(_ sender: Any) {
        
        if let tabVC = self.tabBarController as? MainTabBarController {
            tabVC.logOut()
        }
    }
}
