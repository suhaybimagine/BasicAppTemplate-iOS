//
//  ConfirmSignUpViewController.swift
//  OffersMatch
//
//  Created by Ali Hajjaj on 3/18/18.
//  Copyright © 2018 Ali Hajjaj. All rights reserved.
//

import UIKit

class ConfirmSignUpViewController: UIViewController {

    @IBOutlet var codeDigitFields: [UITextField]!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0 ..< codeDigitFields.count {
            
            let textField = codeDigitFields[i]
            textField.delegate = self
            textField.keyboardType = .numbersAndPunctuation
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
            textField.spellCheckingType = .no
            textField.returnKeyType = (i + 1) == codeDigitFields.count ? .done : .next
            textField.addTarget(self, action: #selector( textFieldEdited(_:) ), for: .editingChanged )
        }
    }
    
    func contructConfirmationCode() -> String? {
        
        var code = ""
        for digitField in self.codeDigitFields {
            code += digitField.text ?? ""
        }
        
        return code.count == self.codeDigitFields.count ? code : nil
    }
    
    
    @IBAction func viewWasTapped(_ sender: Any) {
        
        self.view.endEditing(true)
    }
    
    @IBAction func resendConfirmationCode(_ sender: Any) {
        
        if let userId = UserDefaults.standard.string(forKey: "userId") {
            
            AppWebApi.sendConfirmationCode(forUser: userId)
        }
    }
    
    @IBAction func submitConfirmCode(_ sender: Any) {
        
        if let code = contructConfirmationCode(),
            let userId = UserDefaults.standard.string(forKey: "userId") {
            
            AppWebApi.confirmSignup(forUser: userId, withCode: code, onSuccess: {
                
                self.performSegue(withIdentifier: "confirm_to_home", sender: nil)
            })
            
        } else {
            
            showErrorMessage("Please fill in fields for confirmation code")
        }
    }
}

extension ConfirmSignUpViewController:UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.focusToNextField(textField, withNextValue: nil)
        return true
    }
    
    func focusToNextField(_ textField:UITextField, withNextValue value: String?) -> Void {
        
        if let index = codeDigitFields.index(of: textField) {
            
            if index < (codeDigitFields.count - 1) {
                
                let nextField = codeDigitFields[index + 1]
                nextField.text = value ?? nextField.text
                nextField.becomeFirstResponder()
                
            } else {
                
                textField.resignFirstResponder()
            }
        }
    }
    
    func focusToPrevField(_ textField:UITextField) -> Void {
        
        if let index = codeDigitFields.index(of: textField) {
            
            if index > 0 {
                
                let prevField = codeDigitFields[index - 1]
                prevField.becomeFirstResponder()
                
            } else {
                
                textField.resignFirstResponder()
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let  char = string.cString(using: .utf8)!
        let isBackSpace = strcmp(char, "\\b")
        
        if (string.isEmpty && isBackSpace == -92) {
            
            textField.text = nil
            self.focusToPrevField(textField)
            return false
        }
        
        return true
    }
    
    @IBAction func textFieldEdited(_ sender: Any) {
        
        let textField = sender as! UITextField
        
        if let str = textField.text, str.count == 2 {
            
            textField.text = str.substring(to: str.index(str.startIndex, offsetBy: 1))
            
            let nextChar = str.substring(from: str.index(str.startIndex, offsetBy: 1))
            self.focusToNextField(textField, withNextValue: nextChar)
        }
    }
}
