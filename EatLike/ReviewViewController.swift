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
	var rating = ""

	override func viewDidLoad() {
		super.viewDidLoad()
		let scale = CGAffineTransformMakeScale(0.0, 0.0)
		let transform = CGAffineTransformMakeTranslation(0, 500)
		reviewStackView.transform = CGAffineTransformConcat(scale, transform)
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
		UIView.animateWithDuration(0.5, delay: 0.5,
		                           usingSpringWithDamping: 0.4, initialSpringVelocity: 0.7,
		                           options: [.CurveEaseOut], animations: {
			self.reviewStackView.transform = CGAffineTransformIdentity
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

	/*
	// MARK: - Navigation

	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
	}
	*/

}
