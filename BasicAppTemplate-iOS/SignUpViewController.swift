//
//  SignUpViewController.swift
//  OffersMatch
//
//  Created by Ali Hajjaj on 3/14/18.
//  Copyright © 2018 Ali Hajjaj. All rights reserved.
//

import UIKit
import Validator
import Alamofire
import AlamofireImage


class SignUpViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmField: UITextField!
    
    @IBOutlet weak var removeImageButton: UIButton!
    @IBOutlet weak var pickImageButton: UIButton!
    @IBOutlet weak var profilePhotoView: UIImageView!
    var selectedImage:UIImage?
    
    func doSetSelectedImage(_ image:UIImage? ) -> Void {
        
        let imageExists = image != nil
        self.selectedImage = image
        self.profilePhotoView.image = image
        self.pickImageButton.isHidden = imageExists
        self.removeImageButton.isHidden = !imageExists
    }
    
    @IBAction func removeSelectedProfilePhoto(_ sender: Any) {
        
        self.doSetSelectedImage(nil)
    }
    
    @IBAction func startPhotoPicking(_ sender: Any) {
        
        let actionSheet = UIAlertController(title: "Pick Photo", message: "Please select photo", preferredStyle: .actionSheet)
        let topVC = UIApplication.topViewController()!
        
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            
            topVC.present(imagePicker, animated: true, completion: nil)
        }
        
        let gallery = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            
            topVC.present(imagePicker, animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        actionSheet.addAction(camera)
        actionSheet.addAction(gallery)
        actionSheet.addAction(cancel)
        
        UIApplication.topViewController()?.present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            let size = CGSize(width: 200, height: 200)
            let photo = image.af_imageAspectScaled(toFill: size)
            self.doSetSelectedImage(photo)
        }
        
        picker.dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func viewDidTap(_ sender: Any) {
        
        self.view.endEditing(true)
    }
    
    @IBOutlet weak var bottomConst: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.doSetSelectedImage(nil)
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
        
        self.view.endEditing(true)
        
        let nameRule = ValidationRuleRequired<String>(error: ValidationError.name)
        let emailRule = ValidationRulePattern(pattern: EmailValidationPattern.standard, error: ValidationError.email)
        
        var passRules = ValidationRuleSet<String>()
        passRules.add(rule: ValidationRuleLength(min: 6, max: 40, lengthType: .characters, error: ValidationError.password))
        passRules.add(rule: ValidationRuleEquality<String>(dynamicTarget: { () -> String in
            return self.confirmField.text ?? ""
        }, error: ValidationError.confirm))
        
        
        if let name = self.nameField.text, name.validate(rule: nameRule).isValid,
            let email = self.emailField.text, email.validate(rule: emailRule).isValid,
            let pass = self.passwordField.text, pass.validate(rules: passRules).isValid,
            let photo = self.selectedImage {
            
            AppWebApi.signUp(name: name, email: email, password: pass, photo: photo, success: { (userId, photoUrl) in
                
                UserDefaults.standard.set(userId, forKey: "userId")
                UserDefaults.standard.set(name, forKey: "name")
                UserDefaults.standard.set(email, forKey: "email")
                UserDefaults.standard.set(photoUrl, forKey: "photoUrl")
                
                self.performSegue(withIdentifier: "signup_to_confirm", sender: nil)
                
            }, progress: { (progress) in
                
                print("progress: \(progress.fractionCompleted)")
                
            }, failure: { (error) in
                
                showErrorMessage(error)
            })
            
        } else {
            
            showErrorMessage("Please Enter All Fields Properly")
        }
        
    }
}
