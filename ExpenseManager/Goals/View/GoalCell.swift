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
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var contributionTitleLabel: UILabel!
    @IBOutlet weak var contributionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var progressBackView: UIView!
    @IBOutlet weak var progressFillView: UIView!
    @IBOutlet weak var progressWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        iconBackView.layer.cornerRadius = 12
        iconBackView.clipsToBounds = true
        progressBackView.layer.cornerRadius = 3
        progressFillView.layer.cornerRadius = 3
        
        // Card style
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .white
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 6
        layer.masksToBounds = false
        backgroundColor = .clear
        
        // Status label
        statusLabel.layer.cornerRadius = 10
        statusLabel.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16))
    }
    
    // MARK: - Helper: Calendar icon & text
    private func makeTimeText(_ text: String) -> NSAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = UIImage(systemName: "calendar")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
        attachment.bounds = CGRect(x: 0, y: -2, width: 14, height: 14)
        
        let iconString = NSAttributedString(attachment: attachment)
        let textString = NSAttributedString(string: "  \(text)")
        
        let combined = NSMutableAttributedString()
        combined.append(iconString)
        combined.append(textString)
        return combined
    }
    
    // MARK: - Configure
    func configure(goal: Goal, currentSavings: Double, monthlySavings: Double) {
        
        let progress = GoalCalculator.calculate(goal: goal, currentSavings: currentSavings, monthlySavings: monthlySavings)
        
        // Icon
        iconImageView.image = UIImage(systemName: goal.icon ?? "star.fill")
        iconImageView.tintColor = .systemBlue
        
        // Title
        titleLabel.text = goal.title
        
        // Amount
        let displayAmount = currentSavings < progress.expectedByNow ? currentSavings : progress.expectedByNow
        amountLabel.text = "Rs \(String(format: "%.0f", displayAmount)) / Rs \(String(format: "%.0f", goal.amount))"
        
        // Contribution
        if progress.status == .achieved {
            contributionLabel.text = ""
            contributionTitleLabel.isHidden = true
        } else {
            contributionTitleLabel.isHidden = false
            contributionLabel.text = "Rs \(String(format: "%.0f", progress.requiredPerPeriod)) / \(progress.periodLabel)"
        }
        
        // Time label with calendar Symbol
        switch progress.status {
        case .achieved:
            timeLabel.attributedText = makeTimeText("Achieved")
        case .failed:
            timeLabel.attributedText = makeTimeText("Goal expired")
        default:
            let periodText = progress.periodsRemaining == 1 ? progress.periodLabel : "\(progress.periodLabel)s"
            timeLabel.attributedText = makeTimeText("\(progress.periodsRemaining) \(periodText) left")
        }
        
        // Status badge
        switch progress.status {
        case .achieved:
            statusLabel.text = "  ✓ Achieved  "
            statusLabel.textColor = .systemGreen
            statusLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.12)
            progressFillView.backgroundColor = .systemBlue
        case .onTrack:
            statusLabel.text = "  ↗ On Track  "
            statusLabel.textColor = .systemBlue
            statusLabel.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.12)
            progressFillView.backgroundColor = .systemBlue
        case .behind:
            statusLabel.text = "  ⏱ Behind  "
            statusLabel.textColor = .systemOrange
            statusLabel.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.12)
            progressFillView.backgroundColor = .systemBlue
        case .failed:
            statusLabel.text = "  ✕ Failed  "
            statusLabel.textColor = .systemRed
            statusLabel.backgroundColor = UIColor.systemRed.withAlphaComponent(0.12)
            progressFillView.backgroundColor = .systemRed
        }
        
        // Progress bar
        layoutIfNeeded()
        progressWidthConstraint.constant = progressBackView.frame.width * CGFloat(progress.progressPercent)
    }
}
