//
//  GoalCell.swift
//  ExpenseManager
//
//  Created by Mac on 09/06/2026.
//

import UIKit

// MARK: - Padded Label (for proper badge UI)
class PaddingLabel: UILabel {

    var insets = UIEdgeInsets(top: 12, left: 60, bottom: 12, right: 60)
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + insets.left + insets.right,
            height: size.height + insets.top + insets.bottom
        )
    }
}

class GoalCell: UITableViewCell {

    @IBOutlet weak var iconBackView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var statusLabel: PaddingLabel!
    @IBOutlet weak var contributionTitleLabel: UILabel!
    @IBOutlet weak var contributionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var progressBackView: UIView!
    @IBOutlet weak var progressFillView: UIView!
    @IBOutlet weak var progressWidthConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        // Icon
        iconBackView.layer.cornerRadius = 12
        iconBackView.clipsToBounds = true

        // Progress bar
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

        // Status badge
        statusLabel.layer.masksToBounds = true
        statusLabel.textAlignment = .center

        statusLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 24, bottom: 10, right: 24))
        statusLabel.layer.cornerRadius = statusLabel.frame.height / 2
    }

    // MARK: - Calendar helper
    private func makeTimeText(_ text: String) -> NSAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = UIImage(systemName: "calendar")?
            .withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
        attachment.bounds = CGRect(x: 0, y: -2, width: 14, height: 14)

        let icon = NSAttributedString(attachment: attachment)
        let textStr = NSAttributedString(string: "  \(text)")

        let result = NSMutableAttributedString()
        result.append(icon)
        result.append(textStr)
        return result
    }

    // MARK: - Configure Cell
    func configure(goal: Goal, currentSavings: Double, monthlySavings: Double) {

        let progress = GoalCalculator.calculate(
            goal: goal,
            currentSavings: currentSavings,
            monthlySavings: monthlySavings
        )

        // Icon
        iconImageView.image = UIImage(systemName: goal.icon ?? "star.fill")
        iconImageView.tintColor = .systemBlue

        // Title
        titleLabel.text = goal.title

        // Amount
        let symbol = CurrencyManager.shared.currencySymbol()
        let displayAmount = min(currentSavings, progress.expectedByNow)
        amountLabel.text = "\(symbol) \(String(format: "%.2f", CurrencyManager.shared.convertAmount(displayAmount, from: "PKR"))) / \(symbol) \(String(format: "%.2f", CurrencyManager.shared.convertAmount(goal.amount, from: "PKR")))"

        // Contribution
        if progress.status == .achieved {
            contributionTitleLabel.isHidden = true
            contributionLabel.text = ""
        } else {
            contributionTitleLabel.isHidden = false
            contributionLabel.text = "\(symbol) \(String(format: "%.2f", CurrencyManager.shared.convertAmount(progress.requiredPerPeriod, from: "PKR"))) / \(progress.periodLabel)"
        }

        // Time label
        switch progress.status {
        case .achieved:
            timeLabel.attributedText = makeTimeText("Achieved")
        case .failed:
            timeLabel.attributedText = makeTimeText("Goal expired")
        default:
            let periodText = progress.periodsRemaining == 1
            ? progress.periodLabel
            : "\(progress.periodLabel)s"

            timeLabel.attributedText = makeTimeText("\(progress.periodsRemaining) \(periodText) left")
        }

        // STATUS BADGE
        switch progress.status {

        case .achieved:
            statusLabel.text = "✓ Achieved"
            statusLabel.textColor = .white
            statusLabel.backgroundColor = .systemGreen
            progressFillView.backgroundColor = .systemGreen

        case .onTrack:
            statusLabel.text = "↗ On Track"
            statusLabel.textColor = .systemBlue
            statusLabel.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.12)
            progressFillView.backgroundColor = .systemBlue

        case .behind:
            statusLabel.text = "⏱ Behind"
            statusLabel.textColor = .systemOrange
            statusLabel.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.12)
            progressFillView.backgroundColor = .systemBlue

        case .failed:
            statusLabel.text = "✕ Failed"
            statusLabel.textColor = .systemRed
            statusLabel.backgroundColor = UIColor.systemRed.withAlphaComponent(0.12)
            progressFillView.backgroundColor = .systemRed
        }

        // Progress bar
        layoutIfNeeded()
        let width = progressBackView.frame.width * CGFloat(progress.progressPercent)
        progressWidthConstraint.constant = max(0, min(width, progressBackView.frame.width))
    }
}
