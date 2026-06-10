//
//  AddGoalViewController.swift
//  ExpenseManager
//
//  Created by Mac on 09/06/2026.
//

import UIKit

class AddGoalViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var contributionTextField: UITextField!
    @IBOutlet weak var deadlineTextField: UITextField!
    
    var selectedContributionType = "Yearly"
    var selectedDeadline = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Goal"
        setupUI()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    func setupUI() {
    
        // Deadline default text
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        deadlineTextField.text = formatter.string(from: selectedDeadline)
        deadlineTextField.inputView = UIView()
        let deadlineTap = UITapGestureRecognizer(target: self, action: #selector(showDatePicker))
        deadlineTextField.addGestureRecognizer(deadlineTap)
        
        // Add calendar icon to deadline field
        let calIcon = UIImageView(image: UIImage(systemName: "calendar"))
        calIcon.tintColor = .gray
        calIcon.frame = CGRect(x: 0, y: 0, width: 35, height: 20)
        calIcon.contentMode = .scaleAspectFit
        deadlineTextField.rightView = calIcon
        deadlineTextField.rightViewMode = .always
        
        // Contribution default
        contributionTextField.text = "Yearly"
        contributionTextField.inputView = UIView()
        
        // Add arrow icon to contribution field
        let arrow = UIImageView(image: UIImage(systemName: "chevron.down"))
        arrow.tintColor = .gray
        arrow.frame = CGRect(x: 0, y: 0, width: 35, height: 20)
        arrow.contentMode = .scaleAspectFit
        contributionTextField.rightView = arrow
        contributionTextField.rightViewMode = .always
        
        let contributionTap = UITapGestureRecognizer(target: self, action: #selector(showContributionPicker))
        contributionTextField.addGestureRecognizer(contributionTap)
    }
    
    @objc func backTapped() {
        dismiss(animated: true)
    }
    
    @objc func showContributionPicker() {
        let alert = UIAlertController(title: "Contribution Type", message: nil, preferredStyle: .actionSheet)
        ["Daily", "Weekly", "Monthly", "Yearly"].forEach { type in
            alert.addAction(UIAlertAction(title: type, style: .default) { [weak self] _ in
                self?.selectedContributionType = type
                self?.contributionTextField.text = type
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc func showDatePicker() {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.date = selectedDeadline
        
        let alert = UIAlertController(title: "", message: "\n\n\n\n\n\n\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        picker.translatesAutoresizingMaskIntoConstraints = false
        alert.view.addSubview(picker)
        
        NSLayoutConstraint.activate([
            picker.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 8),
            picker.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -8),
            picker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 8)
        ])
        
        alert.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            self?.selectedDeadline = picker.date
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            self?.deadlineTextField.text = formatter.string(from: picker.date)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @IBAction func addGoalTapped(_ sender: UIButton) {
        guard let title = titleTextField.text, !title.isEmpty,
              let amountText = amountTextField.text, !amountText.isEmpty,
              let amount = Double(amountText), amount > 0 else {
            showAlert(message: "Please fill in all fields")
            return
        }
        
        let icon = CoreDataManager.shared.iconName(for: title)
        
        CoreDataManager.shared.saveGoal(
            title: title,
            amount: amount,
            deadline: selectedDeadline,
            contributionType: selectedContributionType,
            icon: icon
        )
        
        dismiss(animated: true)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
