//
//  SignUpViewController.swift
//  OffersMatch
//
//  Created by Ali Hajjaj on 3/14/18.
//  Copyright © 2018 Ali Hajjaj. All rights reserved.
//

import UIKit
import Validator

class SignUpViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmField: UITextField!
    
    @IBAction func viewDidTap(_ sender: Any) {
        
        self.view.endEditing(true)
    }
    
    @IBOutlet weak var bottomConst: NSLayoutConstraint!
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func goBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitSignup(_ sender: Any) {
        
        let nameRule = ValidationRuleRequired<String>(error: ValidationError.name)
        let emailRule = ValidationRulePattern(pattern: EmailValidationPattern.standard, error: ValidationError.email)
        
        var passRules = ValidationRuleSet<String>()
        passRules.add(rule: ValidationRuleLength(min: 6, max: 8, lengthType: .characters, error: ValidationError.password))
        passRules.add(rule: ValidationRuleEquality<String>(dynamicTarget: { () -> String in
            return self.confirmField.text ?? ""
        }, error: ValidationError.confirm))
        
        
        if let name = self.nameField.text, name.validate(rule: nameRule).isValid,
            let email = self.emailField.text, email.validate(rule: emailRule).isValid,
            let pass = self.passwordField.text, pass.validate(rules: passRules).isValid {
            
            
            AppWebApi.signUp(name: name, email: email, password: pass, success: { (userId) in
                
                UserDefaults.standard.set(userId, forKey: "userId")
                UserDefaults.standard.set(name, forKey: "name")
                UserDefaults.standard.set(email, forKey: "email")
                
                self.performSegue(withIdentifier: "signup_to_confirm", sender: nil)
            })
            
        } else {
            
            showErrorMessage("Please Enter All Fields Properly")
        }
        
    }
}
