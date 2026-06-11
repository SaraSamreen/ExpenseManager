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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
    }
    
    func configure(isSelected: Bool) {
        contentView.backgroundColor = isSelected ? .systemBlue : .white
        layer.cornerRadius = 20
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = isSelected ? 0.3 : 0.08
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
        titleLabel.textColor = isSelected ? .white : .label
        amountLabel.textColor = isSelected ? .white : .label
    }
}
