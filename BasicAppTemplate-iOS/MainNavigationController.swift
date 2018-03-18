//
//  MainNavigationController.swift
//  BasicAppTemplate-iOS
//
//  Created by Ali Hajjaj on 3/18/18.
//  Copyright © 2018 Imagine Technologies. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = UserDefaults.standard.string(forKey: "userId") {
            if let mainTabVC = self.storyboard?.instantiateViewController(withIdentifier: "mainTabVC") {
                self.pushViewController(mainTabVC, animated: false)
            }
        }
    }

}
