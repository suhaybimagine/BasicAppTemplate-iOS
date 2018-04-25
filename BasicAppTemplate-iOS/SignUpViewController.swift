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
import CoreLocation

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var removeImageButton: UIButton!
    @IBOutlet weak var pickImageButton: UIButton!
    @IBOutlet weak var profilePhotoView: UIImageView!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet var genderButtons: [UIButton]!
    
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var birthdateButton: UIButton!
    
    @IBOutlet weak var bottomConst: NSLayoutConstraint!
    
    var selectedImage:UIImage?
    var selectedGender:Int = 1  // 1: Male, 2: Female
    var selectedBirthDate:Date?
    var selectedLocation:CLLocationCoordinate2D?
    var selectedAddress:String?
    
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
        
        self.styleGenderButtons(forSelection: self.selectedGender)
        self.birthdateButton.setTitle("Birth Date", for: .normal)
        self.locationButton.setTitle("Select Location", for: .normal)
        
        self.birthdateButton.setTitleColor(UIColor.lightGray, for: .normal)
        self.locationButton.setTitleColor(UIColor.lightGray, for: .normal)
    }
    
    func doSetSelectedImage(_ image:UIImage? ) -> Void {
        
        let imageExists = image != nil
        self.selectedImage = image
        self.profilePhotoView.image = image
        self.pickImageButton.isHidden = imageExists
        self.removeImageButton.isHidden = !imageExists
    }
    
    @IBAction func launchLocationSelection(_ sender: Any) {
        
        self.view.endEditing(true)
        LocationSelectViewController.launch(delegate: self)
    }
    
    @IBAction func launchBirthDateSelection(_ sender: Any) {
        
        self.view.endEditing(true)
        DatePickerViewController.launch(delegate: self)
    }
    
    @IBAction func removeSelectedProfilePhoto(_ sender: Any) {
        
        self.doSetSelectedImage(nil)
    }
    
    @IBAction func selectGender(_ sender: Any) {
        
        let button = sender as! UIButton
        self.selectedGender = button.tag
        self.styleGenderButtons(forSelection: button.tag)
    }
    
    func styleGenderButtons(forSelection tagSelected:Int) -> Void {
        
        self.genderButtons.forEach { (btn) in
            
            if btn.tag == tagSelected {
                
                btn.backgroundColor = UIColor(white: 0.83 , alpha: 1)
                btn.tintColor = UIColor.black
                
            } else {
                
                btn.backgroundColor = UIColor(white: 0.96 , alpha: 1)
                btn.tintColor = UIColor.lightGray
            }
        }
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
    
    @IBAction func viewDidTap(_ sender: Any) {
        
        self.view.endEditing(true)
    }
    
    @IBAction func goBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitSignup(_ sender: Any) {
        
        self.view.endEditing(true)
        
        let reqRule = ValidationRuleRequired<String>(error: ValidationError.name)
        let emailRule = ValidationRulePattern(pattern: EmailValidationPattern.standard, error: ValidationError.email)
        
        var passRules = ValidationRuleSet<String>()
        passRules.add(rule: ValidationRuleLength(min: 6, max: 40, lengthType: .characters, error: ValidationError.password))
        passRules.add(rule: ValidationRuleEquality<String>(dynamicTarget: { () -> String in
            return self.confirmField.text ?? ""
        }, error: ValidationError.confirm))
        
        guard let name = self.nameField.text, name.validate(rule: reqRule).isValid,
            let phone = self.phoneField.text, phone.validate(rule: reqRule).isValid,
            let birthdate = self.selectedBirthDate,
            let location = self.selectedLocation else {
                
                showErrorMessage("signup-error".local)
                return
        }
        
        guard let email = self.emailField.text, email.validate(rule: emailRule).isValid else {
            showErrorMessage("email-error".local)
            return
        }
        
        guard let pass = self.passwordField.text, pass.validate(rules: passRules).isValid else {
            showErrorMessage("password-error".local)
            return
        }
        
        AppWebApi.signUp(name: name,
                         email: email,
                         password: pass,
                         birthdate: birthdate,
                         phone: phone,
                         location: location,
                         address: self.selectedAddress,
                         gender: self.selectedGender,
                         photo: self.selectedImage,
                         success: { (userId, photoUrl) in
                            
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
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
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
}


extension SignUpViewController: DatePickerViewControllerDelegate, LocationSelectViewControllerDelegate {
    
    func datePickerControllerDidSelectDate(_ selectedDate: Date) {
        
        self.selectedBirthDate = selectedDate
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        
        self.birthdateButton.setTitle(dateFormatter.string(from: selectedDate), for: .normal)
        self.birthdateButton.setTitleColor(UIColor.black, for: .normal)
    }
    
    func datePickerControllerDidClearSelection(_ datePickerVC: DatePickerViewController) {
        
        self.birthdateButton.setTitle("Birth Date", for: .normal)
        self.birthdateButton.setTitleColor(UIColor.lightGray, for: .normal)
    }
    
    func locationSelectDidReceiveAddress(_ address: String, atCoordinates coordinates: CLLocationCoordinate2D) {
        
        self.selectedLocation = coordinates
        self.selectedAddress = address
        
        self.locationButton.setTitle(address, for: .normal)
        self.locationButton.setTitleColor(UIColor.black, for: .normal)
    }
}
