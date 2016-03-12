//
//  RestaurantTableViewController.swift
//  EatLike
//
//  Created by Queen Y on 16/3/11.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit

class RestaurantTableViewController: UITableViewController {
	// MARK: -Normal Properties
	let restaurants = RestaurantModel()
	// MARK: - View Controller Methods
	override func prefersStatusBarHidden() -> Bool {
		return true
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// Uncomment the following line to preserve selection between presentations
		// self.clearsSelectionOnViewWillAppear = false

		// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
		// self.navigationItem.rightBarButtonItem = self.editButtonItem()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: - Table View Datasource Methods

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return 1
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return restaurants.restaurantNames.count
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! RestaurantTableViewCell
		let row = indexPath.row
		cell.nameLabel.text = restaurants.restaurantNames[row]
		cell.thumbnailImageView.image = UIImage(named: restaurants.restaurantImages[row])

		cell.accessoryType = self.restaurants.restaurantIsVisit[indexPath.row] ? .Checkmark : .None
		/* 给 缩略图添加圆角效果
		 但是可以使用 IB 来完成这个任务。
		 通过添加 Runtime Attribute 设置半径（为图片框架的长度的一半，半径）
		 再设置 imageView 的 Attribute 的  Clip Subviews */
		// cell.thumbnailImageView.layer.cornerRadius = 30.0
		// cell.thumbnailImageView.clipsToBounds = true
		return cell
	}

	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		let row = indexPath.row
		if editingStyle == .Delete {
			restaurants.removeResuaurant(row)
			tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
		}
	}

	// 创建自定义的滑动动作，并且最后将它们作为数组返回
	override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
		let shareAction = UITableViewRowAction(style: .Default, title: "Share") {
			[unowned self] (action, indexPath) in
			if let image = UIImage(named: self.restaurants.restaurantImages[indexPath.row]) {
				let defaultText = "Just check in \(self.restaurants.restaurantNames[indexPath.row])"
				let activity = UIActivityViewController(activityItems: [image, defaultText], applicationActivities: nil)
				self.presentViewController(activity, animated: true, completion: nil)
			}
		}

		let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "Delete") {
			[unowned self] (action, indexPath) in

			self.restaurants.removeResuaurant(indexPath.row)
			self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
		}
		shareAction.backgroundColor = UIColor(red: 28/255.0, green: 165/255.0, blue: 253/255.0, alpha: 1.0)
		// 返回的顺序可能会影响显示的，倒序显示。
		return [deleteAction, shareAction]
	}
	// MARK: - Table View Delegate Methods

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let optionMenu = UIAlertController(title: "Yahoo!", message: "What do you want to do", preferredStyle: .ActionSheet)
		optionMenu.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
		optionMenu.addAction(UIAlertAction(title: "Call 400-800-\(indexPath.row)", style: .Default, handler: nil))
		optionMenu.addAction(UIAlertAction(title: "I've been here", style: .Default, handler: {
			[unowned self] _ in
			self.restaurants.restaurantIsVisit[indexPath.row] = true
			tableView.reloadData()
		}))

		presentViewController(optionMenu, animated: true, completion: nil)

		// 防止被选中的位置一直保存被选中的灰色状态。
		tableView.deselectRowAtIndexPath(indexPath, animated: false)
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
