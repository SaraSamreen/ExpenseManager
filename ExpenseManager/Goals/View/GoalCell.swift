//
//  GoalCell.swift
//  ExpenseManager
//
//  Created by Mac on 09/06/2026.
//

import UIKit

class GoalCell: UITableViewCell {
    
    @IBOutlet weak var iconBackView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var progressBackView: UIView!
    @IBOutlet weak var progressFillView: UIView!
    @IBOutlet weak var progressWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        iconBackView.layer.cornerRadius = 12
        iconBackView.clipsToBounds = true
        progressBackView.layer.cornerRadius = 3
        progressFillView.layer.cornerRadius = 3
    }
    
    func configure(goal: Goal, currentSavings: Double) {
        titleLabel.text = goal.title
        let saved = min(currentSavings, goal.amount)
        amountLabel.text = "Rs \(String(format: "%.0f", saved)) / Rs \(String(format: "%.0f", goal.amount))"
        
        let iconName = goal.icon ?? "star.fill"
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = .systemBlue
        
        let progress = goal.amount > 0 ? CGFloat(saved / goal.amount) : 0
        layoutIfNeeded()
        progressWidthConstraint.constant = progressBackView.frame.width * progress
    }
}
