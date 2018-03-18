//
//  ViewController.swift
//  OffersMatch
//
//  Created by Ali Hajjaj on 3/14/18.
//  Copyright © 2018 Ali Hajjaj. All rights reserved.
//

import UIKit
import Validator

enum ValidationError : Error {
    case password
    case email
    case confirm
    case name
}

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var bottomConst: NSLayoutConstraint!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    @IBAction func viewDidTap(_ sender: Any) {
        
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: Notification.Name.UIKeyboardWillShow, object: nil, queue: nil) { (notif) in
            
            if let frame = notif.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect {
                self.bottomConst.constant = -1 * frame.height
                UIView.animate(withDuration: 0.2, animations: {
                    self.view.layoutIfNeeded()
                })
            }
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name.UIKeyboardWillHide, object: nil, queue: nil) { _ in
            
            self.bottomConst.constant = 0
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.passwordField.text = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }

    @IBAction func submitLogin(_ sender: Any) {
        
        self.view.endEditing(true)

        let passRule = ValidationRuleLength(min: 6, max: 40, lengthType: .characters, error: ValidationError.password)
        let emailRule = ValidationRulePattern(pattern: EmailValidationPattern.standard, error: ValidationError.email)
        
        if let email = self.emailField.text, email.validate(rule: emailRule).isValid,
            let password = self.passwordField.text, password.validate(rule: passRule).isValid {
            
            AppWebApi.login(email: email, password: password, success: { (userId, name, isConfirmed) in
                
                UserDefaults.standard.set(userId, forKey: "userId")
                UserDefaults.standard.set(name, forKey: "name")
                UserDefaults.standard.set(email, forKey: "email")
                
                if isConfirmed {
                    
                    self.performSegue(withIdentifier: "login_to_home", sender: nil)
                } else {
                    
                    self.performSegue(withIdentifier: "login_to_confirm", sender: nil)
                }
            })
            
        } else {
            
            showErrorMessage("Please enter Email and Password properly")
        }
    }
}

