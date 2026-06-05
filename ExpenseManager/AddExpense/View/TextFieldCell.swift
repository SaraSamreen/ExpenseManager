//
//  TextFieldCell.swift
//  ExpenseManager
//
//  Created by Mac on 03/06/2026.
//

import UIKit

class TextFieldCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.borderStyle = .none
        textField.layer.cornerRadius = 12
        textField.layer.masksToBounds = true
        textField.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 50))
        textField.leftView = padding
        textField.leftViewMode = .always
    }
}
