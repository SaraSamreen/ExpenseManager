//
//  SaveButtonCell.swift
//  ExpenseManager
//
//  Created by Mac on 03/06/2026.
//

import UIKit

class SaveButtonCell: UITableViewCell {
    
    @IBOutlet weak var saveButton: UIButton!
    var onSave: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        saveButton.layer.cornerRadius = 12
        saveButton.backgroundColor = .systemBlue
        saveButton.setTitleColor(.white, for: .normal)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        onSave?()
    }
}
