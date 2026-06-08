//
//  ImagePickerCell.swift
//  ExpenseManager
//
//  Created by Mac on 08/06/2026.
//

import UIKit

class ImagePickerCell: UITableViewCell {
    
    var onPickImage: (() -> Void)?
    
    let containerView = UIView()
    let imagePreview = UIImageView()
    let placeholderLabel = UILabel()
    let pickBtn = UIButton(type: .system)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    func setupUI() {
        selectionStyle = .none
        
        containerView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        containerView.layer.cornerRadius = 12
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        imagePreview.contentMode = .scaleAspectFill
        imagePreview.clipsToBounds = true
        imagePreview.layer.cornerRadius = 12
        imagePreview.isHidden = true
        imagePreview.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(imagePreview)
        
        placeholderLabel.text = "Tap to attach receipt / image"
        placeholderLabel.textColor = .secondaryLabel
        placeholderLabel.font = UIFont.systemFont(ofSize: 14)
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(placeholderLabel)
        
        pickBtn.setImage(UIImage(systemName: "paperclip"), for: .normal)
        pickBtn.tintColor = .systemBlue
        pickBtn.translatesAutoresizingMaskIntoConstraints = false
        pickBtn.addTarget(self, action: #selector(pickTapped), for: .touchUpInside)
        containerView.addSubview(pickBtn)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            placeholderLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            pickBtn.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            pickBtn.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            imagePreview.topAnchor.constraint(equalTo: containerView.topAnchor),
            imagePreview.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            imagePreview.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imagePreview.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
    }
    
    @objc func pickTapped() {
        onPickImage?()
    }
    
    func setImage(_ image: UIImage?) {
        if let image = image {
            imagePreview.image = image
            imagePreview.isHidden = false
            placeholderLabel.isHidden = true
            pickBtn.isHidden = true
        } else {
            imagePreview.isHidden = true
            placeholderLabel.isHidden = false
            pickBtn.isHidden = false
        }
    }
}
