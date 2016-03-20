//
//  RestaurantTableViewController.swift
//  EatLike
//
//  Created by Queen Y on 16/3/11.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit
import CoreData
class RestaurantTableViewController: UITableViewController,
												 NSFetchedResultsControllerDelegate, UISearchResultsUpdating {
	// MARK: -Normal Properties
	var fetchResultController: NSFetchedResultsController!
	var searchController: UISearchController = {
		let searchController = UISearchController(searchResultsController: nil)
		//	搜索的时候，背景不会模糊。如果使用的不是另一个独立的视图，需要赋值为 false， 否则无法点击搜索的值
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.hidesNavigationBarDuringPresentation = true
		let bar = searchController.searchBar
		bar.placeholder = "Search Restaurants"
		bar.tintColor = UIColor.whiteColor()
		bar.barTintColor = UIColor(red: 223/255.0, green: 124/255.0, blue: 124/255.0, alpha: 1.0)
		return searchController
	}()

	var restaurants:[Restaurant] = []
	var searchedRestaurants = [Restaurant]()
	// MARK: - View Controller Methods

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(true)
		navigationController?.hidesBarsOnSwipe = true
	}


	override func viewDidLoad() {
		super.viewDidLoad()
		// fetch data
		let fetchRequest = NSFetchRequest(entityName: "Restaurant")
		let sortDes = NSSortDescriptor(key: "name", ascending: true)
		// 按 name 升序排序
		fetchRequest.sortDescriptors = [sortDes]

		guard let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext else { return }
		fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
		// 调用完这个方法后, 不能对 fetchResultsController 的任何事情进行修改
		fetchResultController.delegate = self
		do {
			try fetchResultController.performFetch()
			restaurants = fetchResultController.fetchedObjects as! [Restaurant]
		} catch {
			print(error)
			return
		}

		// 让 backBarButton 的 title 标题为空 
		// 直接设置 title 为空不管用, 因为这个属性默认为 nil
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
		navigationItem.title = "Restaurants"

		// 让 tableView 获得可以动态的定义高度.
		tableView.estimatedRowHeight = 36.0
		tableView.rowHeight = UITableViewAutomaticDimension
		navigationItem.leftBarButtonItem = editButtonItem()

		// 添加搜索栏
		self.tableView.tableHeaderView = searchController.searchBar
		searchController.searchResultsUpdater = self
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
		if searchController.active == true {
			return searchedRestaurants.count
		} else {
			return restaurants.count
		}
	}

	private func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
		let restaurant: Restaurant
		if searchController.active {
			restaurant = self.searchedRestaurants[indexPath.row]
		} else {
			restaurant = self.fetchResultController.objectAtIndexPath(indexPath) as! Restaurant
		}
		let resaurantCell = cell as! RestaurantTableViewCell
		resaurantCell.nameLabel.text = restaurant.name
		resaurantCell.LocationLabel.text = restaurant.location
		resaurantCell.TypeLabel.text = restaurant .type
		resaurantCell.thumbnailImageView.image = UIImage(data: restaurant.image!)
		if let visited = restaurant.isVisited?.boolValue {
			resaurantCell.accessoryType = visited ? .Checkmark : .None
		}
		/* 给 缩略图添加圆角效果
		但是可以使用 IB 来完成这个任务。
		通过添加 Runtime Attribute 设置半径（为图片框架的长度的一半，半径）
		再设置 imageView 的 Attribute 的  Clip Subviews */
		// cell.thumbnailImageView.layer.cornerRadius = 30.0
		// cell.thumbnailImageView.clipsToBounds = true
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! RestaurantTableViewCell
		configureCell(cell, indexPath: indexPath)
		cell.updateLabelPerferredFont()

		return cell
	}

	// 因为在 ViewRowAction 中实现了删除，所以删除不需要这个方法。
	/* override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		let row = indexPath.row
		if editingStyle == .Delete {
			removeRestaurant(row)
			tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
		}
	}*/

	override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
		print(#function)

		setEditing(false, animated: true)
	}

	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		if searchController.active {
			return false
		}
		return true
	}

	// 创建自定义的滑动动作，并且最后将它们作为数组返回
	override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
		let shareAction = UITableViewRowAction(style: .Default, title: "Share") {
			[unowned self] (action, indexPath) in
			if let image = self.restaurants[indexPath.row].image {
				let defaultText = "Just check in \(self.restaurants[indexPath.row].name)"
				let activity = UIActivityViewController(activityItems: [image, defaultText], applicationActivities: nil)
				self.presentViewController(activity, animated: true, completion: nil)
			}
		}

		let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "Delete") {
			[unowned self] (action, indexPath) in
			guard let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext else { return }
			print("Fuck DJ")
			let restaurantToDelete = self.fetchResultController.objectAtIndexPath(indexPath) as! Restaurant
			print("Fuck mother")
			managedObjectContext.deleteObject(restaurantToDelete)
			guard let _ = try? managedObjectContext.save() else { return }
		}

		shareAction.backgroundColor = UIColor(red: 28/255.0, green: 165/255.0, blue: 253/255.0, alpha: 1.0)
		// 返回的顺序可能会影响显示的，倒序显示。
		return [deleteAction, shareAction]
	}

	// MARK: - Navigation

	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		switch segue.identifier! {
		case "showRestaurantDetail":
			guard let indexPath = tableView.indexPathForSelectedRow else { return }
			let restaurantDetailVC = segue.destinationViewController as! RestaurantDetailViewController
			restaurantDetailVC.restaurant = searchController.active ?
						searchedRestaurants[indexPath.row] : restaurants[indexPath.row]
			searchController.active = false
		case "addRestaurant":
			break
		default:
			break
		}
	}

	func removeRestaurant(index: Int) {
		restaurants.removeAtIndex(index)
	}

	@IBAction func unwindToHome(segue: UIStoryboardSegue) {
		guard let sourceViewController = segue.sourceViewController as? AddRestaurantTableViewController,
				let newRes = sourceViewController.newRestaurant else { return }

		restaurants.append(newRes)
		// TODO: 希望能够有一个更带感的动画，表示创建新的数据成功。
	}


	// MARK: - FetchResults Delegate
	func controllerWillChangeContent(controller: NSFetchedResultsController) {
		tableView.beginUpdates()
	}

	func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {

		switch type {
		case .Insert:
			tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
		case .Delete:
		// 下面这种方法会不可以的, 虽然我不知道为什么.
		// indexPath.map { tableView.deleteRowsAtIndexPaths([$0], withRowAnimation: .Fade) }
			tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
		case .Update:
			self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, indexPath: indexPath!)
		// 如果要实现 Move 的情况, 必须设置一个标记表明是用户主动触发了这种操作!
		// 否则其他的删除, 插入操作都会因为被认为是 Move, 而导致问题.
		case .Move:
			tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
			tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
		}
		// 同时更新数据源.
		restaurants = controller.fetchedObjects as! [Restaurant]
	}

	func controllerDidChangeContent(controller: NSFetchedResultsController) {
		tableView.endUpdates()
	}

	// MARK: - Search Methods
	func filterRestaurant(search: String) {
		searchedRestaurants = restaurants.filter { $0.name.rangeOfString(search, options: .CaseInsensitiveSearch) != nil }
		// 如果没有匹配的名字， 则匹配地址
		if searchedRestaurants.isEmpty {
			searchedRestaurants = restaurants.filter { $0.location.rangeOfString(search, options: .CaseInsensitiveSearch) != nil }
		}
	}

	func updateSearchResultsForSearchController(searchController: UISearchController) {
		if let searchText = searchController.searchBar.text {
			filterRestaurant(searchText)
			self.tableView.reloadData()
		}
	}
}
