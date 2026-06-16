//
//  TransactionDetailViewController.swift
//  ExpenseManager
//
//  Created by Mac on 08/06/2026.
//

import UIKit
import UniformTypeIdentifiers

class TransactionDetailViewController: UIViewController {
    
    var expense: Expense?
    var onDismiss: (() -> Void)?
    var selectedImage: UIImage? = nil
    var selectedDate: Date = Date()
    
    // MARK: - UI Elements
    let titleLabel = UILabel()
    let amountLabel = UILabel()
    let dateLabel = UILabel()
    let titleField = UITextField()
    let amountField = UITextField()
    let dateField = UITextField()
    let saveBtn = UIButton(type: .system)
    let deleteBtn = UIButton(type: .system)
    let attachedImageView = UIImageView()
    let editImageBtn = UIButton(type: .system)
    let addImageLabel = UILabel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Edit"
        setupUI()
        populateData()
    }
    
    // MARK: - Setup UI
    func setupUI() {
        
        // Title Label
        titleLabel.text = "Title"
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Amount Label
        amountLabel.text = "Amount"
        amountLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        amountLabel.textColor = .secondaryLabel
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Date Label
        dateLabel.text = "Date"
        dateLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        dateLabel.textColor = .secondaryLabel
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Title Field
        titleField.borderStyle = .roundedRect
        titleField.placeholder = "Enter title"
        titleField.translatesAutoresizingMaskIntoConstraints = false
        
        // Amount Field
        amountField.borderStyle = .roundedRect
        amountField.placeholder = "Enter amount"
        amountField.keyboardType = .decimalPad
        amountField.translatesAutoresizingMaskIntoConstraints = false
        
        // Date Field
        dateField.borderStyle = .roundedRect
        dateField.placeholder = "Select date"
        dateField.inputView = UIView()
        dateField.translatesAutoresizingMaskIntoConstraints = false
        let calContainer = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 20))
        let calIcon = UIImageView(image: UIImage(systemName: "calendar"))
        calIcon.tintColor = .gray
        calIcon.frame = CGRect(x: 4, y: 0, width: 24, height: 20)
        calIcon.contentMode = .scaleAspectFit
        calContainer.addSubview(calIcon)
        dateField.rightView = calContainer
        dateField.rightViewMode = .always
        let tap = UITapGestureRecognizer(target: self, action: #selector(showDatePicker))
        dateField.addGestureRecognizer(tap)
        
        // Attached Image View
        attachedImageView.contentMode = .scaleAspectFill
        attachedImageView.clipsToBounds = true
        attachedImageView.layer.cornerRadius = 12
        attachedImageView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        attachedImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(changeImageTapped))
        attachedImageView.isUserInteractionEnabled = true
        attachedImageView.addGestureRecognizer(imageTap)
        
        // Add Image Placeholder Label
        addImageLabel.text = "Tap to add receipt"
        addImageLabel.textColor = .secondaryLabel
        addImageLabel.font = UIFont.systemFont(ofSize: 14)
        addImageLabel.textAlignment = .center
        addImageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Edit Image Button
        editImageBtn.setTitle("Change Photo", for: .normal)
        editImageBtn.setTitleColor(.systemBlue, for: .normal)
        editImageBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        editImageBtn.backgroundColor = .clear
        editImageBtn.translatesAutoresizingMaskIntoConstraints = false
        editImageBtn.addTarget(self, action: #selector(changeImageTapped), for: .touchUpInside)
        
        // Save Button
        saveBtn.setTitle("Save Changes", for: .normal)
        saveBtn.backgroundColor = .systemBlue
        saveBtn.setTitleColor(.white, for: .normal)
        saveBtn.layer.cornerRadius = 10
        saveBtn.translatesAutoresizingMaskIntoConstraints = false
        saveBtn.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        
        // Delete Button
        deleteBtn.setTitle("Delete", for: .normal)
        deleteBtn.backgroundColor = .systemRed
        deleteBtn.setTitleColor(.white, for: .normal)
        deleteBtn.layer.cornerRadius = 10
        deleteBtn.translatesAutoresizingMaskIntoConstraints = false
        deleteBtn.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        
        // Add Subviews
        view.addSubview(titleLabel)
        view.addSubview(titleField)
        view.addSubview(amountLabel)
        view.addSubview(amountField)
        view.addSubview(dateLabel)
        view.addSubview(dateField)
        view.addSubview(attachedImageView)
        view.addSubview(addImageLabel)
        view.addSubview(editImageBtn)
        view.addSubview(saveBtn)
        view.addSubview(deleteBtn)
        
        // MARK: - Constraints
        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            titleField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            titleField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleField.heightAnchor.constraint(equalToConstant: 44),
            
            amountLabel.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 16),
            amountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            amountField.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 6),
            amountField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            amountField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            amountField.heightAnchor.constraint(equalToConstant: 44),
            
            dateLabel.topAnchor.constraint(equalTo: amountField.bottomAnchor, constant: 16),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            dateField.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 6),
            dateField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dateField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            dateField.heightAnchor.constraint(equalToConstant: 44),
            
            attachedImageView.topAnchor.constraint(equalTo: dateField.bottomAnchor, constant: 20),
            attachedImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            attachedImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            attachedImageView.heightAnchor.constraint(equalToConstant: 180),
            
            addImageLabel.centerXAnchor.constraint(equalTo: attachedImageView.centerXAnchor),
            addImageLabel.centerYAnchor.constraint(equalTo: attachedImageView.centerYAnchor),
            
            editImageBtn.topAnchor.constraint(equalTo: attachedImageView.bottomAnchor, constant: 6),
            editImageBtn.centerXAnchor.constraint(equalTo: attachedImageView.centerXAnchor),
            editImageBtn.heightAnchor.constraint(equalToConstant: 30),
            
            saveBtn.topAnchor.constraint(equalTo: editImageBtn.bottomAnchor, constant: 16),
            saveBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveBtn.heightAnchor.constraint(equalToConstant: 50),
            
            deleteBtn.topAnchor.constraint(equalTo: saveBtn.bottomAnchor, constant: 16),
            deleteBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            deleteBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            deleteBtn.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    // MARK: - Populate Data
    func populateData() {
        guard let expense = expense else { return }
        titleField.text = expense.title
        amountField.text = String(format: "%.2f", expense.amount)
        selectedDate = expense.date ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        dateField.text = formatter.string(from: selectedDate)
        
        if let imageData = expense.image, let image = UIImage(data: imageData) {
            attachedImageView.image = image
            addImageLabel.isHidden = true
        } else {
            attachedImageView.image = nil
            addImageLabel.isHidden = false
        }
        editImageBtn.isHidden = expense.image == nil
    }
    
    // MARK: - Show Date Picker
    @objc func showDatePicker() {
        let alert = UIAlertController(title: "", message: "\n\n\n\n\n\n\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.date = selectedDate
        picker.translatesAutoresizingMaskIntoConstraints = false
        alert.view.addSubview(picker)
        
        NSLayoutConstraint.activate([
            picker.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 8),
            picker.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -8),
            picker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 8)
        ])
        
        alert.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.selectedDate = picker.date
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            self.dateField.text = formatter.string(from: picker.date)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    // MARK: - Save 
    @objc func saveTapped() {
        guard let expense = expense else { return }

        guard let newTitle = titleField.text, !newTitle.isEmpty else {
            showAlert(message: "Please enter a title")
            return
        }

        guard let amountText = amountField.text, !amountText.isEmpty else {
            showAlert(message: "Please enter an amount")
            return
        }

        guard let newAmount = Double(amountText) else {
            showAlert(message: "Amount must be a valid number")
            return
        }

        guard newAmount > 0 else {
            showAlert(message: "Amount must be greater than 0")
            return
        }

        guard newAmount <= 10_000_000 else {
            showAlert(message: "Amount seems too large. Please check and try again")
            return
        }

        guard selectedDate <= Date() else {
            showAlert(message: "Date cannot be in the future")
            return
        }

        expense.title = newTitle
        expense.amount = newAmount
        expense.date = selectedDate
        
        if let selectedImage = selectedImage {
            expense.image = selectedImage.jpegData(compressionQuality: 0.7)
        } else if attachedImageView.image == nil {
            expense.image = nil
        }
        
        CoreDataManager.shared.saveContext()
        onDismiss?()
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Delete
    @objc func deleteTapped() {
        let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this transaction?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let expense = self?.expense else { return }
            CoreDataManager.shared.deleteExpense(expense)
            self?.onDismiss?()
            self?.navigationController?.popViewController(animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    // MARK: - Change Image
    @objc func changeImageTapped() {
        let alert = UIAlertController(title: "Image", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                let err = UIAlertController(title: "Not Available", message: "Camera is not available on this device", preferredStyle: .alert)
                err.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(err, animated: true)
                return
            }
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            self?.present(picker, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            self?.present(picker, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Documents", style: .default) { [weak self] _ in
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.image, .pdf])
            picker.delegate = self
            self?.present(picker, animated: true)
        })
        
        if attachedImageView.image != nil {
            alert.addAction(UIAlertAction(title: "Remove Image", style: .destructive) { [weak self] _ in
                self?.selectedImage = nil
                self?.attachedImageView.image = nil
                self?.addImageLabel.isHidden = false
                self?.editImageBtn.isHidden = true
            })
        }
    
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - Helper
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Image Picker Delegate
extension TransactionDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            selectedImage = image
            attachedImageView.image = image
            addImageLabel.isHidden = true
            editImageBtn.isHidden = false
        }
    }
}

// MARK: - Document Picker Delegate
extension TransactionDetailViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        if let image = UIImage(contentsOfFile: url.path) {
            selectedImage = image
            attachedImageView.image = image
            addImageLabel.isHidden = true
            editImageBtn.isHidden = false
        }
    }
}
