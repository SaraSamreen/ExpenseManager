//
//  CategoryCell.swift
//  ExpenseManager
//
//  Created by Mac on 03/06/2026.
//

import UIKit

class CategoryCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var categories: [String] = []
    var selectedCategory: String = ""
    var onCategorySelected: ((String) -> Void)?
    var onAddTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CategoryChipCell")
    }

     
    
    func configure(title: String, categories: [String], selected: String, onAdd: @escaping () -> Void, onSelect: @escaping (String) -> Void) {
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 13)
        self.categories = categories
        self.selectedCategory = selected
        self.onAddTapped = onAdd
        self.onCategorySelected = onSelect
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryChipCell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        cell.layer.masksToBounds = true

        if indexPath.row == 0 {
            cell.layer.cornerRadius = 16
            cell.backgroundColor = UIColor(white: 0.93, alpha: 1)
            cell.layer.borderWidth = 1.5
            cell.layer.borderColor = UIColor.lightGray.cgColor
            let label = UILabel(frame: cell.contentView.bounds)
            label.text = "+"
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 22)
            label.textColor = .gray
            cell.contentView.addSubview(label)
        } else {
            let category = categories[indexPath.row - 1]
            cell.layer.cornerRadius = 16
            cell.layer.borderWidth = 0
            cell.backgroundColor = category == selectedCategory ? .systemBlue : UIColor(white: 0.95, alpha: 1)
            let label = UILabel(frame: cell.contentView.bounds)
            label.text = category
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = category == selectedCategory ? .white : .black
            cell.contentView.addSubview(label)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            onAddTapped?()
        } else {
            selectedCategory = categories[indexPath.row - 1]
            onCategorySelected?(selectedCategory)
            collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 110, height: 50)
    }
}
