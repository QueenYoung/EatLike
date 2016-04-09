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
	@IBOutlet weak var noteImage: UIImageView!
	@IBOutlet weak var noteLabel: UILabel!
	var restaurant: Restaurant!

	override func viewDidLoad() {
		super.viewDidLoad()
		title = restaurant.name
		// 设置状态栏的透明效果
		navigationController?.navigationBar.tintColor = UIColor.whiteColor()
		navigationController?.navigationBar
			.setBackgroundImage(UIImage(), forBarMetrics: .Default)
		navigationController?.navigationBar.shadowImage = UIImage.init()
		restaurantImageView.image = UIImage(data: restaurant.image!)

		detailTableView.backgroundColor = UIColor.clearColor()
		// 脚注就是表格没有现实数据的部分，将它们移除
		detailTableView.tableFooterView = UIView(frame: CGRect.zero)

		if restaurant.rating != .None {
			ratingButton.setImage(UIImage(named: restaurant.rating.rawValue), forState: .Normal)
		}

		// 如果 note 有信息的话, 就显示. 没有的话, 不显示同时隐藏图标
		configureNoteLabel()
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
		let identifier = "DetailCell"

		let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
		// 使单元格透明
		cell.backgroundColor = UIColor.clearColor()
		switch indexPath.row {
		case 0:
			cell.textLabel?.text = "Name"
			cell.detailTextLabel?.text = restaurant.name
		case 1:
			cell.textLabel?.text = "Location"
			cell.detailTextLabel?.text = restaurant.location
		case 2:
			cell.textLabel?.text = "Type"
			cell.detailTextLabel?.text = restaurant.type
		case 3:
			cell.textLabel?.text = "Phone"
			cell.detailTextLabel?.text = restaurant.phoneNumber
		case 4:
			cell.textLabel?.text = "Been here"
			if let isVisit = restaurant.isVisited?.boolValue {
				cell.detailTextLabel?.text = isVisit ? "Yes, I've been here" : "No"
			}
		default:
			break
		}
		return cell
	}


	func tableView(tableView: UITableView,
						willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
		return nil
	}


	@IBAction func unwindToDetail(segue: UIStoryboardSegue) {
		if let ratingVC = segue.sourceViewController as? ReviewViewController {
			if ratingVC.rating == "None" {
				return
			}
			ratingButton.setImage(UIImage(named: ratingVC.rating), forState: .Normal)
			restaurant.rating = Rating(rawValue: ratingVC.rating)!

		} else if let editVC = segue.sourceViewController
				as? AddRestaurantTableViewController {
			let newRest = editVC.newRestaurant
			if !restaurant.image!.isEqualToData(newRest.image!) {
				restaurantImageView.image = UIImage(data: newRest.image!)
			}

			restaurant = editVC.newRestaurant
			detailTableView.reloadData()

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
			let reviewVC = segue.destinationViewController as! ReviewViewController
			reviewVC.rating = restaurant.rating.rawValue
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
		if restaurant.note.isEmpty {
			noteImage.hidden = true
			noteLabel.hidden = true
		} else {
			noteImage.hidden = false
			noteLabel.hidden = false
			noteLabel.text = restaurant.note
		}
	}
}
