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
	var restaurants:[Restaurant] = [

		Restaurant(name: "Cafe Deadend", type: "Coffee & Tea Shop",
					  location: "G/F, 72 Po Hing Fong, Sheung Wan, Hong Kong",
					  phoneNumber: "232-923423", image: "cafedeadend.jpg", isVisited: false),

		Restaurant(name: "Homei", type: "Cafe",
					  location: "Shop B, G/F, 22-24A Tai Ping San Street SOHO, Sheung Wan, Hong Kong",
					  phoneNumber: "348-233423", image: "homei.jpg", isVisited: false),

		Restaurant(name: "Teakha", type: "Tea House",
					  location: "Shop B, 18 Tai Ping Shan Road SOHO, Sheung Wan, Hong Kong",
					  phoneNumber: "354-243523", image: "teakha.jpg", isVisited: false),

		Restaurant(name: "Cafe loisl", type: "Austrian / Causual Drink",
					  location: "Shop B, 20 Tai Ping Shan Road SOHO, Sheung Wan, Hong Kong",
					  phoneNumber: "453- 333423", image: "cafeloisl.jpg", isVisited: false),

		Restaurant(name: "Petite Oyster", type: "French",
					  location: "24 Tai Ping Shan Road SOHO, Sheung Wan, Hong Kong",
					  phoneNumber: "983-284334", image: "petiteoyster.jpg", isVisited: false),

		Restaurant(name: "For Kee Restaurant", type: "Bakery",
					  location: "Shop J- K., 200 Hollywood Road, SOHO, Sheung Wan, Hong Kong",
					  phoneNumber: "232- 434222", image: "forkeerestaurant.jpg", isVisited: false),

		Restaurant(name: "Po's Atelier", type: "Bakery",
					  location: "G/F, 62 Po Hing Fong, Sheung Wan, Hong Kong",
					  phoneNumber: "234-834322", image: "posatelier.jpg", isVisited: false),

		Restaurant(name: "Bourke Street Backery", type: "Chocolate",
					  location: "633 Bourke St Sydney New South Wales 2010 Surry Hills",
					  phoneNumber: "982-434343", image: "bourkestreetbakery.jpg", isVisited: false),

		Restaurant(name: "Haigh's Chocolate", type: "Cafe",
					  location: "412-414 George St Sydney New South Wales",
					  phoneNumber: "734-232323", image: "haighschocolate.jpg", isVisited: false),

		Restaurant(name: "Palomino Espresso", type: "American / Seafood",
					  location: "Shop 1 61 York St Sydney New South Wales",
					  phoneNumber: "872-734343", image: "palominoespresso.jpg", isVisited: false),

		Restaurant(name: "Upstate", type: "American",
					  location: "95 1st Ave New York, NY 10003",
					  phoneNumber: "343-233221", image: "upstate.jpg", isVisited: false),

		Restaurant(name: "Traif", type: "American",
					  location: "229 S 4th St Brooklyn, NY 11211",
					  phoneNumber: "985-723623", image: "traif.jpg", isVisited: false),

		Restaurant(name: "Graham Avenue Meats", type: "Breakfast & Brunch",
					  location: "445 Graham Ave Brooklyn, NY 11211",
					  phoneNumber: "455-232345", image: "grahamavenuemeats.jpg", isVisited: false),

		Restaurant(name: "Waffle & Wolf", type: "Coffee & Tea",
					  location: "413 Graham Ave Brooklyn, NY 11211",
					  phoneNumber: "434-232322", image: "wafflewolf.jpg", isVisited: false),

		Restaurant(name: "Five Leaves", type: "Coffee & Tea",
					  location: "18 Bedford Ave Brooklyn, NY 11222",
					  phoneNumber: "343-234553", image: "fiveleaves.jpg", isVisited: false),


		Restaurant(name: "Cafe Lore", type: "Latin American",
					  location: "Sunset Park 4601 4th Ave Brooklyn, NY 11220",
					  phoneNumber: "342-455433", image: "cafelore.jpg", isVisited: false),

		Restaurant(name: "Confessional", type: "Spanish",
					  location: "308 E 6th St New York, NY 10003",
					  phoneNumber: "643-332323", image: "confessional.jpg", isVisited: false),

		Restaurant(name: "Barrafina", type: "Spanish",
					  location: "54 Frith Street London W1D 4SL United Kingdom",
					  phoneNumber: "542-343434", image: "barrafina.jpg", isVisited: false),

		Restaurant(name: "Donostia", type: "Spanish",
					  location: "10 Seymour Place London W1H 7ND United Kingdom",
					  phoneNumber: "722-232323", image: "donostia.jpg", isVisited: false),

		Restaurant(name: "Royal Oak", type: "British",
					  location: "2 Regency Street London SW1P 4BZ United Kingdom",
					  phoneNumber: "343-988834", image: "royaloak.jpg", isVisited: false),

		Restaurant(name: "Thai Cafe", type: "Thai",
					  location: "22 Charlwood Street London SW1V 2DY Pimlico",
					  phoneNumber: "432-344050", image: "thaicafe.jpg", isVisited: false) ]
	// MARK: - View Controller Methods

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(true)
		navigationController?.hidesBarsOnSwipe = true
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
		navigationItem.title = "Restaurants"

		// 让 tableView 获得可以动态的定义高度.
		tableView.estimatedRowHeight = 80
		tableView.rowHeight = UITableViewAutomaticDimension
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
		return restaurants.count
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! RestaurantTableViewCell
		let row = indexPath.row
		cell.nameLabel.text = restaurants[row].name
		cell.LocationLabel.text = restaurants[row].location
		cell.TypeLabel.text = restaurants[row].type
		cell.thumbnailImageView.image = UIImage(named: restaurants[row].image)
		cell.accessoryType = self.restaurants[row].isVisit ? .Checkmark : .None
		cell.updateLabelPerferredFont()
		/* 给 缩略图添加圆角效果
		但是可以使用 IB 来完成这个任务。
		通过添加 Runtime Attribute 设置半径（为图片框架的长度的一半，半径）
		再设置 imageView 的 Attribute 的  Clip Subviews */
		// cell.thumbnailImageView.layer.cornerRadius = 30.0
		// cell.thumbnailImageView.clipsToBounds = true
		return cell
	}

	// 因为在 ViewRowAction 中实现了删除，所以删除不需要这个方法。
	/* override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		let row = indexPath.row
		if editingStyle == .Delete {
			removeRestaurant(row)
			tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
		}
	} */

	// 创建自定义的滑动动作，并且最后将它们作为数组返回
	override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
		let shareAction = UITableViewRowAction(style: .Default, title: "Share") {
			[unowned self] (action, indexPath) in
			if let image = UIImage(named: self.restaurants[indexPath.row].image) {
				let defaultText = "Just check in \(self.restaurants[indexPath.row].name)"
				let activity = UIActivityViewController(activityItems: [image, defaultText], applicationActivities: nil)
				self.presentViewController(activity, animated: true, completion: nil)
			}
		}

		let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "Delete") {
			[unowned self] (action, indexPath) in

			self.removeRestaurant(indexPath.row)
			self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
		}
		shareAction.backgroundColor = UIColor(red: 28/255.0, green: 165/255.0, blue: 253/255.0, alpha: 1.0)
		// 返回的顺序可能会影响显示的，倒序显示。
		return [deleteAction, shareAction]
	}

	// MARK: - Table View Delegate Methods

	/* override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
	} */


	// MARK: - Navigation

	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		switch segue.identifier! {
		case "showRestaurantDetail":
			guard let indexPath = tableView.indexPathForSelectedRow else { return }
			let restaurantDetailVC = segue.destinationViewController as! RestaurantDetailViewController
			restaurantDetailVC.restaurant = restaurants[indexPath.row]
		default:
			break
		}
	}

	func removeRestaurant(index: Int) {
		restaurants.removeAtIndex(index)
	}

}
