//
//  RestaurantDetailViewController.swift
//  EatLike
//
//  Created by Queen Y on 16/3/12.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit

class RestaurantDetailViewController: UIViewController {
    
	@IBOutlet weak var restaurantImageView: UIImageView!
//	@IBOutlet weak var ratingButton: UIButton!
	@IBOutlet weak var starLabel: UILabel!

	var restaurant: Restaurant!
	// MARK: - View Controller 
	override func viewDidLoad() {
		super.viewDidLoad()
		title = restaurant.name
		// 设置状态栏的透明效果
		navigationController?.navigationBar.tintColor = UIColor.whiteColor()
		navigationController?.navigationBar
			.setBackgroundImage(UIImage(), forBarMetrics: .Default)
		navigationController?.navigationBar.shadowImage = UIImage.init()
		restaurantImageView.image = UIImage(data: restaurant.image!)

        let count = Int(restaurant.userRate.intValue)
        configureStarColor(count)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(true)
		// 进入 detail 视图的时候,关闭 hide on swipe 功能.
//		navigationController?.hidesBarsOnSwipe = false
		navigationController?.setNavigationBarHidden(false, animated: true)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func unwindToDetail(segue: UIStoryboardSegue) {
		if let ratingVC = segue.sourceViewController as? ReviewViewController {
			restaurant = ratingVC.restaurant
			// TODO: Update rating label
            let count = Int(restaurant.userRate.intValue)
			configureStarColor(count)
		} else if let editVC = segue.sourceViewController
				as? AddRestaurantTableViewController {
			let newRest = editVC.newRestaurant
			// TODO: 谷歌怎么 判断两个图片是否相同.
			if !restaurant.image!.isEqualToData(newRest.image!) {
				restaurantImageView.image = UIImage(data: newRest.image!)
			}

			restaurant = editVC.newRestaurant

			configureNoteLabel()
		}

		guard let managedObjectContext =
			(UIApplication.sharedApplication().delegate as? AppDelegate)?
				.managedObjectContext else { return }
		
		try! managedObjectContext.save()
	}


	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showMap" {
			let mapVC = segue.destinationViewController as! MapViewController
			mapVC.restaurant = restaurant
		} else if segue.identifier == "modallyReview" {
			let reviewNC = segue.destinationViewController as! UINavigationController
			let reviewVC = reviewNC.topViewController as! ReviewViewController
			reviewVC.restaurant = restaurant
		} else if segue.identifier == "EditRestaurant" {
			let editVc = segue.destinationViewController as! AddRestaurantTableViewController
			editVc.newRestaurant = restaurant
		}
	}

	@IBAction func call(sender: UIButton) {
		let telphone = restaurant.phoneNumber
		if let telphone = telphone {
			presentViewController(sender.call(telphone)!, animated: true, completion: nil)
		}
	}

	private func configureNoteLabel() {

	}

    private func configureStarColor(count: Int) {
        starLabel.text = String(count: count, repeatedValue: Character("★"))
        starLabel.textColor = .yellowColor()
    }
}
