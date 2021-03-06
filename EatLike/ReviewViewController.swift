//
//  ReviewViewController.swift
//  EatLike
//
//  Created by Queen Y on 16/3/13.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit

class ReviewViewController: UIViewController {
    @IBOutlet weak var backgroundViewImage: UIImageView!
    @IBOutlet weak var starsStackView: UIStackView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet var ratingButtons: [UIButton]!
    @IBOutlet weak var ratingStackView: UIStackView!

    var restaurant: Restaurant!
    var currentUserRating = 0
    private var ratingButtonTitles: [String] {
        return ratingButtons.map({$0.currentTitle!})
    }

    let cache = (UIApplication.shared().delegate as! AppDelegate).imageCache


    override func viewDidLoad() {
        super.viewDidLoad()
        currentUserRating = restaurant.userRate.intValue
        questionLabel.text = "\(restaurant.name)"

        if currentUserRating > 0 {
            showStarCount(with: currentUserRating, animated: false)

            let index = currentUserRating - 1
            let titleOfButtonSelected = ratingButtonTitles[index]

            for ratingButton in ratingButtons {
                ratingButton.isSelected = ratingButton.titleLabel?.text! == titleOfButtonSelected
            }
        }

        let blur = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blur)
        backgroundViewImage.image = cache.image(for: restaurant.keyString)
        // Setting the frame of the blur
        blurView.frame = view.frame
        backgroundViewImage.addSubview(blurView)

        // animated inital status
        ratingStackView.axis = .vertical
        starsStackView.isHidden = true
        let rotation = CGFloat(M_PI * 2 / 3.0)
        let rotationTransform = CATransform3DMakeRotation(rotation, 0, 0, 1.0)
        starsStackView.layer.transform = rotationTransform

        questionLabel.transform = CGAffineTransform(translationX: -300, y: 0)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.setBackgroundImage(
            UIImage.init(), for: .default)
    }

    override func viewWillDisappear(_ animated: Bool) {
        let barColor = UIColor(
            red: 0xf7/255.0,
            green: 0x5b/255.0,
            blue: 0x61/255.0,
            alpha: 1.0)
        let back = UIImage.withColor(color: barColor, size: CGSize(width: 1, height: 1))
        navigationController?.navigationBar.setBackgroundImage(back, for: .default)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        // 因为这个方法晚于 load 方法运行, 所以通过在 load 中设置开始状态
        // 在这个方法中设置结束状态,并启动弹性动画.

        UIView.animate(
            withDuration: 0.5,
            delay: 0.0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 6.0,
            options: [.curveEaseIn],
            animations: {
                self.questionLabel.transform = CGAffineTransform.identity
                self.ratingStackView.axis = .horizontal
            }, completion: nil)
        
        
        UIView.animate(withDuration: 0.5, delay: 0.2, options: [.curveEaseIn], animations: {
            self.starsStackView.isHidden = false
            self.starsStackView.layer.transform = CATransform3DIdentity
            }, completion: nil)
    }
    
    
    @IBAction func submitRate(sender: UIBarButtonItem) {
        currentUserRating = starsStackView.arrangedSubviews.count
        restaurant.userRate = currentUserRating
        _ = navigationController?.popViewController(animated: true)
        performSegue(withIdentifier: "unwindToDetailView", sender: nil)
    }
    
    @IBAction func ratingButtonTapped(sender: UIButton) {
        let buttonTitle = sender.titleLabel!.text!
        
        for ratingButton in ratingButtons {
            ratingButton.isSelected = sender == ratingButton
        }
        
        let rating = ratingForButtonTitle(buttonTitle: buttonTitle)
        showStarCount(with: rating)
    }
    
    // MARK: Helper Methods
    private func showStarCount(with totalStarCount: Int, animated: Bool = true) {
        let starsToChange = totalStarCount - starsStackView.arrangedSubviews.count
        
        // 提高评价
        if starsToChange > 0 {
            for _ in 1...starsToChange {
                let starImage = UIImageView(image: UIImage(named: "rating_star"))
                starImage.contentMode = .scaleAspectFit
                // Add to right
                starImage.frame.origin = CGPoint(x: starsStackView.frame.width, y: 0)
                starsStackView.addArrangedSubview(starImage)
            }
            // 降低评价
        } else if starsToChange < 0 {
            let starsToRemove = abs(starsToChange)
            
            for _ in 1...starsToRemove {
                guard let star = starsStackView.arrangedSubviews.last else {
                    fatalError("Are you kidding me?")
                }
                starsStackView.removeArrangedSubview(star)
                star.removeFromSuperview()
            }
        }

        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.starsStackView.layoutIfNeeded()
            })
        }
    }
    
    private func ratingForButtonTitle(buttonTitle: String) -> Int {
        guard let index = ratingButtonTitles.index(of: buttonTitle) else {
            fatalError("Rating not found")
        }
        return index + 1
    }
}
