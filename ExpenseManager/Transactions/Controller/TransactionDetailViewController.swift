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
    
    // MARK: - UI Elements
    let titleField = UITextField()
    let amountField = UITextField()
    let saveBtn = UIButton(type: .system)
    let deleteBtn = UIButton(type: .system)
    let datePickerLabel = UILabel()
    let datePicker = UIDatePicker()
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
        
        // Title Field
        titleField.borderStyle = .roundedRect
        titleField.placeholder = "Title"
        titleField.translatesAutoresizingMaskIntoConstraints = false
        
        // Amount Field
        amountField.borderStyle = .roundedRect
        amountField.placeholder = "Amount"
        amountField.keyboardType = .decimalPad
        amountField.translatesAutoresizingMaskIntoConstraints = false
        
        // Date Label
        datePickerLabel.text = "Date"
        datePickerLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        datePickerLabel.textColor = .secondaryLabel
        datePickerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Date Picker
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        // Attached Image View
        attachedImageView.contentMode = .scaleAspectFill
        attachedImageView.clipsToBounds = true
        attachedImageView.layer.cornerRadius = 12
        attachedImageView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        attachedImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add Image Placeholder Label
        addImageLabel.text = "Tap camera to add receipt"
        addImageLabel.textColor = .secondaryLabel
        addImageLabel.font = UIFont.systemFont(ofSize: 14)
        addImageLabel.textAlignment = .center
        addImageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Camera Button
        editImageBtn.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        editImageBtn.tintColor = .white
        editImageBtn.backgroundColor = .systemBlue
        editImageBtn.layer.cornerRadius = 16
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
        deleteBtn.backgroundColor = .systemBlue
        deleteBtn.setTitleColor(.white, for: .normal)
        deleteBtn.layer.cornerRadius = 10
        deleteBtn.translatesAutoresizingMaskIntoConstraints = false
        deleteBtn.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        
        // Add Subviews
        view.addSubview(titleField)
        view.addSubview(amountField)
        view.addSubview(datePickerLabel)
        view.addSubview(datePicker)
        view.addSubview(attachedImageView)
        view.addSubview(addImageLabel)
        view.addSubview(editImageBtn)
        view.addSubview(saveBtn)
        view.addSubview(deleteBtn)
        
        // MARK: - Constraints
        NSLayoutConstraint.activate([
            
            // Title Field
            titleField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleField.heightAnchor.constraint(equalToConstant: 44),
            
            // Amount Field
            amountField.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 16),
            amountField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            amountField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            amountField.heightAnchor.constraint(equalToConstant: 44),
            
            // Date Label
            datePickerLabel.topAnchor.constraint(equalTo: amountField.bottomAnchor, constant: 16),
            datePickerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            // Date Picker
            datePicker.centerYAnchor.constraint(equalTo: datePickerLabel.centerYAnchor),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Attached Image View
            attachedImageView.topAnchor.constraint(equalTo: datePickerLabel.bottomAnchor, constant: 30),
            attachedImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            attachedImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            attachedImageView.heightAnchor.constraint(equalToConstant: 180),
            
            // Placeholder Label
            addImageLabel.centerXAnchor.constraint(equalTo: attachedImageView.centerXAnchor),
            addImageLabel.centerYAnchor.constraint(equalTo: attachedImageView.centerYAnchor),
            
            // Camera Button - bottom right corner
            editImageBtn.bottomAnchor.constraint(equalTo: attachedImageView.bottomAnchor, constant: -10),
            editImageBtn.trailingAnchor.constraint(equalTo: attachedImageView.trailingAnchor, constant: -10),
            editImageBtn.widthAnchor.constraint(equalToConstant: 32),
            editImageBtn.heightAnchor.constraint(equalToConstant: 32),
            
            // Save Button
            saveBtn.topAnchor.constraint(equalTo: attachedImageView.bottomAnchor, constant: 24),
            saveBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveBtn.heightAnchor.constraint(equalToConstant: 50),
            
            // Delete Button
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
        datePicker.date = expense.date ?? Date()
        
        if let imageData = expense.image, let image = UIImage(data: imageData) {
            attachedImageView.image = image
            addImageLabel.isHidden = true
        } else {
            attachedImageView.image = nil
            addImageLabel.isHidden = false
        }
    }
    
    // MARK: - Save
    @objc func saveTapped() {
        guard let expense = expense,
              let newTitle = titleField.text, !newTitle.isEmpty,
              let amountText = amountField.text,
              let newAmount = Double(amountText) else {
            let alert = UIAlertController(title: "Error", message: "Please fill all fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        expense.title = newTitle
        expense.amount = newAmount
        expense.date = datePicker.date
        
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
        
        alert.addAction(UIAlertAction(title: "Remove Image", style: .destructive) { [weak self] _ in
            self?.selectedImage = nil
            self?.attachedImageView.image = nil
            self?.addImageLabel.isHidden = false
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
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
        }
    }
}
