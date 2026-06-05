//
//  DatePickerCell.swift
//  ExpenseManager
//
//  Created by Mac on 03/06/2026.
//

import UIKit

class DatePickerCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateTextField: UITextField!
    
    var onDateTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dateTextField.isUserInteractionEnabled = false
        dateTextField.layer.cornerRadius = 12
        dateTextField.layer.masksToBounds = true
        dateTextField.backgroundColor = UIColor(white: 0.95, alpha: 1)
        dateTextField.borderStyle = .none
        
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 50))
        dateTextField.leftView = padding
        dateTextField.leftViewMode = .always
        
        let calendarBtn = UIButton(type: .system)
        calendarBtn.setImage(UIImage(systemName: "calendar"), for: .normal)
        calendarBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        calendarBtn.addTarget(self, action: #selector(calendarTapped), for: .touchUpInside)
        dateTextField.rightView = calendarBtn
        dateTextField.rightViewMode = .always
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 54, height: 44))
        calendarBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        containerView.addSubview(calendarBtn)
        dateTextField.rightView = containerView
    }
    
    @objc func calendarTapped() {
        onDateTapped?()
    }
    
    func setDate(_ date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        dateTextField.text = formatter.string(from: date)
    }
}
