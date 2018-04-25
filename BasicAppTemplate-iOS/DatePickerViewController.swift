//
//  DatePickerViewController.swift
//  Shakawekom
//
//  Created by AhmeDroid on 4/11/17.
//  Copyright © 2017 Imagine Technologies. All rights reserved.
//

import UIKit

protocol DatePickerViewControllerDelegate {

    func datePickerControllerDidSelectDate(_ selectedDate:Date) -> Void
    func datePickerControllerDidClearSelection(_ datePickerVC:DatePickerViewController) -> Void
}

class DatePickerViewController: UIViewController {
    
    static func launch(delegate:DatePickerViewControllerDelegate?, initialDate:Date? = nil, maximumDate:Date? = nil) -> Void {
        
        if let viewC = UIApplication.topViewController(),
            let datePickerVC = viewC.storyboard?.instantiateViewController(withIdentifier: "datePickerVC") as? DatePickerViewController  {
            
            datePickerVC.maximumDate = maximumDate
            datePickerVC.currentDate = initialDate ?? Date()
            datePickerVC.modalTransitionStyle = .crossDissolve
            datePickerVC.modalPresentationStyle = .overCurrentContext
            datePickerVC.delegate =  delegate
            
            viewC.present(datePickerVC, animated: true, completion: {_ in})
        } else {
            
            print("Can't launch date picker on non-UIViewController objects")
        }
    }

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var selectionLabel: UILabel!
    
    var delegate:DatePickerViewControllerDelegate?
    var maximumDate:Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.datePicker.maximumDate = self.maximumDate
        
        if let _date = self.currentDate {
            self.datePicker.setDate(_date, animated: false)
        }
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.numberOfTapsRequired = 1
        
        self.view.addGestureRecognizer(tapRecognizer)
        tapRecognizer.addTarget(self, action: #selector( viewWasTapped ))
    }
    
    func viewWasTapped() -> Void {
        
        self.dismiss(animated: true, completion: {_ in})
    }
    
    private var currentDate:Date!
    @IBAction func datePickerChanged(_ sender: Any) {
        
        let selectedDate = self.datePicker.date
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE yyyy/MM/dd"
        
        self.selectionLabel.text = formatter.string(from: selectedDate)
        self.currentDate = selectedDate
    }
    
    @IBAction func clearSelection(_ sender: Any) {
        
        self.dismiss(animated: true) {
            self.delegate?.datePickerControllerDidClearSelection(self)
        }
    }
    
    @IBAction func finishSelection(_ sender: Any) {
        
        self.dismiss(animated: true) { 
            
            if self.currentDate != nil {
                self.delegate?.datePickerControllerDidSelectDate(self.currentDate)
            }
        }
    }
}
