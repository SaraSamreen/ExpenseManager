//
//  OnboardingCollectionViewCell.swift
//  ExpenseManager
//
//  Created by Mac on 21/05/2026.
//

import UIKit

class OnboardingCollectionViewCell: UICollectionViewCell {
    
    static let identifier = String(describing: OnboardingCollectionViewCell.self)
    
    // MARK: - IBOutlets
    @IBOutlet weak var slideImageView: UIImageView!
    @IBOutlet weak var slideTitlelbl: UILabel!
    @IBOutlet weak var slideDescriptionlbl: UILabel!
    
    func setup(_ slide: OnboardingSlide){
        slideImageView.image = slide.image
        slideTitlelbl.text = slide.title
        slideDescriptionlbl.text = slide.description
    }
    
    
}
