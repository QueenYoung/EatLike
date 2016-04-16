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

    var restaurant: Restaurant!
    var currentUserRating = 0
    private let ratingButtonTitles = [
        "Boring", "Meh", "It's OK", "Like It", "Fantastical"
    ]

	override func viewDidLoad() {
		super.viewDidLoad()
		let transform = CGAffineTransformMakeTranslation(0, 500)
        currentUserRating = restaurant.userRate.integerValue
        ratingButtons.forEach({$0.transform = transform})
        questionLabel.text = "How would you rate \(restaurant.name)"

        if currentUserRating > 0 {
            showStarCount(currentUserRating, animated: false)

            let index = currentUserRating - 1
            let titleOfButtonSelected = ratingButtonTitles[index]

            for ratingButton in ratingButtons {
                ratingButton.selected = ratingButton.titleLabel?.text! == titleOfButtonSelected
            }
        }

		let blur = UIBlurEffect(style: .Dark)
		let blurView = UIVisualEffectView(effect: blur)
		// Setting the frame of the blur
		blurView.frame = view.frame
		backgroundViewImage.addSubview(blurView)

	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(true)
		// 因为这个方法晚于 load 方法运行, 所以通过在 load 中设置开始状态
		// 在这个方法中设置结束状态,并启动弹性动画.
        var delay = 0.0

        for button in ratingButtons {
            UIView.animateWithDuration(0.5, delay: delay,
                                       usingSpringWithDamping: 0.4,
                                       initialSpringVelocity: 0.5,
                                       options: [.CurveEaseOut],
                                       animations: { button.transform = CGAffineTransformIdentity },
                                       completion: nil)
            delay += 0.1
        }
	}

    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func submitRate(sender: UIBarButtonItem) {
        currentUserRating = starsStackView.arrangedSubviews.count
        restaurant.userRate = currentUserRating
        performSegueWithIdentifier("unwindToDetailView", sender: nil)
    }

    @IBAction func ratingButtonTapped(sender: UIButton!) {
        let buttonTitle = sender.titleLabel!.text!

        for ratingButton in ratingButtons {
            ratingButton.selected = sender == ratingButton
        }

        let rating = ratingForButtonTitle(buttonTitle)
        showStarCount(rating)
    }

    // MARK: Helper Methods
    private func showStarCount(totalStarCount: Int, animated: Bool = true) {
        let starsToChange = totalStarCount - starsStackView.arrangedSubviews.count

        if starsToChange > 0 {
            for _ in 1...starsToChange {
                let starImage = UIImageView(image: UIImage(named: "rating_star"))
                starImage.contentMode = .ScaleAspectFit
                // Add to right
                starImage.frame.origin = CGPoint(x: starsStackView.frame.width, y: 0)
                starsStackView.addArrangedSubview(starImage)
            }
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
            UIView.animateWithDuration(0.3, animations: {
                self.starsStackView.layoutIfNeeded()
            })
        }
    }

    private func ratingForButtonTitle(buttonTitle: String) -> Int {
        guard let index = ratingButtonTitles.indexOf(buttonTitle) else {
            fatalError("Rating not found")
        }
        return index + 1
    }
}
