//
//  ForgotPasswordViewController.swift
//  OffersMatch
//
//  Created by Ali Hajjaj on 3/15/18.
//  Copyright © 2018 Ali Hajjaj. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func goback(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitForm(_ sender: Any) {
        
        
    }
}
