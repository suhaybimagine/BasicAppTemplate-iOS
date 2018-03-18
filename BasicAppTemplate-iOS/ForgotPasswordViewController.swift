//
//  ForgotPasswordViewController.swift
//  OffersMatch
//
//  Created by Ali Hajjaj on 3/15/18.
//  Copyright © 2018 Ali Hajjaj. All rights reserved.
//

import UIKit
import Validator
import SVProgressHUD

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    
    @IBAction func viewWasTapped(_ sender: Any) {
        
        self.view.endEditing(true)
    }
    
    @IBAction func goback(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitForm(_ sender: Any) {
        
        self.view.endEditing(true)
        
        let emailRule = ValidationRulePattern(pattern: EmailValidationPattern.standard, error: ValidationError.email)
        
        if let email = self.emailField.text, email.validate(rule: emailRule).isValid {
            
            AppWebApi.reportForgotPassword(forEmail: email, onSuccess: {
                
                SVProgressHUD.showSuccess(withStatus: "A link was sent to your email to restore your password. Make sure to check it")
                SVProgressHUD.dismiss(withDelay: 2.0, completion: {
                    
                    _ = self.navigationController?.popViewController(animated: true)
                })
            })
            
        } else {
            
            showErrorMessage("Please type proper Email address")
        }
    }
}
