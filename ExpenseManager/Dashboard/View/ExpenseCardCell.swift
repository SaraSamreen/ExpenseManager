//
//  ExpenseCardCell.swift
//  ExpenseManager
//
//  Created by Mac on 03/06/2026.
//

import UIKit

class ExpenseCardCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    func configure(isSelected: Bool) {
        backgroundColor = isSelected ? .systemBlue : .white
        layer.cornerRadius = 12
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = isSelected ? 0.3 : 0.15
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        titleLabel.textColor = isSelected ? .white : .label
        amountLabel.textColor = isSelected ? .white : .label
    }
}
