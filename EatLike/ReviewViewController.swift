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
	@IBOutlet weak var reviewStackView: UIStackView!
	@IBOutlet weak var dislikeButton: UIButton!
	@IBOutlet weak var greatButton: UIButton!
	@IBOutlet weak var likeButton: UIButton!

	var rating: String!

	override func viewDidLoad() {
		super.viewDidLoad()
		let transform = CGAffineTransformMakeTranslation(0, 500)
		dislikeButton.transform = transform
		greatButton.transform = transform
		likeButton.transform = transform
        
		let blur = UIBlurEffect(style: .Dark)
		let blurView = UIVisualEffectView(effect: blur)
		// Setting the frame of the blur
		blurView.frame = view.frame
		backgroundViewImage.addSubview(blurView)

		// Do any additional setup after loading the view.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(true)
		// 因为这个方法晚于 load 方法运行, 所以通过在 load 中设置开始状态
		// 在这个方法中设置结束状态,并启动弹性动画.
		UIView.animateWithDuration(0.5, delay: 0.0,
		                           usingSpringWithDamping: 0.4, initialSpringVelocity: 0.7,
		                           options: [.CurveEaseOut], animations: {
         self.dislikeButton.transform = CGAffineTransformIdentity
			}, completion: nil)
		UIView.animateWithDuration(0.5, delay: 0.2,
		                           usingSpringWithDamping: 0.4, initialSpringVelocity: 0.7,
		                           options: [.CurveEaseOut], animations: {
												self.greatButton.transform = CGAffineTransformIdentity
			}, completion: nil)
		UIView.animateWithDuration(0.5, delay: 0.4,
		                           usingSpringWithDamping: 0.4, initialSpringVelocity: 0.7,
		                           options: [.CurveEaseOut], animations: {
												self.likeButton.transform = CGAffineTransformIdentity
			}, completion: nil)
	}

	@IBAction func selectButton(sender: UIButton) {
		switch sender.tag {
		case 100:
			rating = "dislike"
		case 200:
			rating = "good"
		case 300:
			rating = "great"
		default:
			break
		}
		performSegueWithIdentifier("unwindToDetailView", sender: sender)
	}


}
