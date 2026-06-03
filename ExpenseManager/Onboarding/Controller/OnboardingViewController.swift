//
//  OnboardingViewController.swift
//  ExpenseManager
//
//  Created by Mac on 21/05/2026.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var slides: [OnboardingSlide] = []
    var currentPage = 0 {
        didSet{
            pageControl.currentPage = currentPage
            if currentPage == slides.count - 1{
                nextBtn.setTitle("Get Started", for: .normal)
            }
            else{
                nextBtn.setTitle( "Next", for: .normal)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        slides = [
            OnboardingSlide(
                title: "Note Down Expenses",
                description: "Daily note your expenses to help manage money",
                image: UIImage(named: "image1")!
            ),
            OnboardingSlide(
                title: "Simple Money Management",
                description: "Get your notifications or alert when you do the over expenses",
                image: UIImage(named: "image2")!
            ),
            OnboardingSlide(
                title: "Easy to Track and Analyze",
                description: "Tracking your expense help make sure you don't overspend",
                image: UIImage(named: "image3")!
            )
        ]
    }
    
    // MARK: - IBAction
    @IBAction func nextBtnClicked(_ sender: UIButton)
    {
        if currentPage == slides.count - 1{
            UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
            let controller = storyboard?
                .instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
            controller.modalPresentationStyle = .fullScreen
            controller.modalTransitionStyle = .flipHorizontal
            present(controller,animated: true,
            completion: nil)
           
        } else{
            currentPage += 1
            let indexPath = IndexPath(item: currentPage, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
}

extension OnboardingViewController: UICollectionViewDelegate, UICollectionViewDataSource,
                                    UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingCollectionViewCell", for: indexPath) as! OnboardingCollectionViewCell
        cell.setup(slides[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width , height: collectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        currentPage = Int(scrollView.contentOffset.x
                          / width)
    }
}
