//
//  MainTabBarController.swift
//  BasicAppTemplate-iOS
//
//  Created by Ali Hajjaj on 3/18/18.
//  Copyright © 2018 Imagine Technologies. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // App font name
        /*Proxima Nova [
            "ProximaNova-Extrabld",
            "ProximaNova-Light",
            "ProximaNova-Black",
            "ProximaNova-Semibold",
            "ProximaNova-Bold",
            "ProximaNova-Regular"]*/
        
        if let font = UIFont(name: "ProximaNova-Bold", size: 12) {
            UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
        }
        
        self.tabBar.tintColor = Colors.main
    }
    
    func logOut() -> Void {
        
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "name")
        UserDefaults.standard.removeObject(forKey: "email")
        
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
}
