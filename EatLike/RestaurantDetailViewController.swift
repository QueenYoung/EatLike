//
//  RestaurantDetailViewController.swift
//  EatLike
//
//  Created by Queen Y on 16/3/12.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit

class RestaurantDetailViewController: UIViewController, UITableViewDelegate,
												  UITableViewDataSource {
	@IBOutlet weak var restaurantImageView: UIImageView!
	@IBOutlet weak var detailTableView: UITableView!
	@IBOutlet weak var ratingButton: UIButton!
	var restaurant: Restaurant!


	override func viewDidLoad() {
		super.viewDidLoad()
		title = restaurant.name
		restaurantImageView.image = UIImage(named: restaurant.image)
		detailTableView.backgroundColor = UIColor(red: 242/255.0, green: 66/255.0, blue: 119/255.0, alpha: 0.5)
		// 脚注就是表格没有现实数据的部分，将它们移除
		detailTableView.estimatedRowHeight = 36
		detailTableView.rowHeight = UITableViewAutomaticDimension
		detailTableView.tableFooterView = UIView(frame: CGRect.zero)
		// Do any additional setup after loading the view.
		if restaurant.rate != .None {
			ratingButton.setImage(UIImage(named: restaurant.rate.rawValue), forState: .Normal)
		}
	}
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(true)
		// 进入 detail 视图的时候,关闭 hide on swipe 功能.
		navigationController?.hidesBarsOnSwipe = false
		navigationController?.setNavigationBarHidden(false, animated: true)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// 因为这个视图遵循了表格视图的协议, 所以我们需要通过下面两个方法来显示内容.
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 5
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
					  as! RestaurantDetailTableViewCell
		// 使单元格透明
		cell.backgroundColor = UIColor.clearColor()
		switch indexPath.row {
		case 0:
			cell.fieldLabel.text = "Name"
			cell.valueField.text = restaurant.name
		case 1:
			cell.fieldLabel.text = "Type"
			cell.valueField.text = restaurant.type
		case 2:
			cell.fieldLabel.text = "Location"
			cell.valueField.text = restaurant.location
		case 3:
			cell.fieldLabel.text = "Phone"
			cell.valueField.text = restaurant.phoneNumber
		case 4:
			cell.fieldLabel.text = "Been here"
			cell.valueField.text = restaurant.isVisit ? "Yes, I've been here" : "No"
		default:
			break
		}
		return cell
	}

	func tableView(tableView: UITableView,
						willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
		return nil
	}

	@IBAction func closeReview(segue: UIStoryboardSegue) {
		if let ratingVC = segue.sourceViewController as? ReviewViewController {
			ratingButton.setImage(UIImage(named: ratingVC.rating), forState: .Normal)
			restaurant.rate = Rating(rawValue: ratingVC.rating)!
		}
	}
	// TODO: 不允许点击表格的信息.
	/*
	// MARK: - Navigation

	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
	}
	*/

}
