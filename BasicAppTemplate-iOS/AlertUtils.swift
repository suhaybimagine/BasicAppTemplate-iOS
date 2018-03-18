//
//  AlertUtils.swift
//  HappyUAE
//
//  Created by AhmeDroid on 10/13/16.
//  Copyright © 2016 Imagine Technologies. All rights reserved.
//

import UIKit

func showErrorMessage(_ title:String, message:String, okLabel:String) -> Void {
    
    DispatchQueue.main.async {
        
        let alert = UIAlertController(title: title,
                                      message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: okLabel, style: .default, handler: {_ in})
        
        alert.addAction(okAction)
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
    }
}

func showErrorMessage( _ message:String? = nil ) -> Void {
    
    showErrorMessage("تطبيق عزوتنا",
                     message: message ?? "نأسف، هناك خلل ما !",
                     okLabel: "حسناً")
}
