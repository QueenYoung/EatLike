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
                                     NSFetchedResultsControllerDelegate,
                                     UISearchResultsUpdating,
                                     UINavigationControllerDelegate,
                                     UISearchControllerDelegate {
    // MARK: - Normal Properties
    var fetchResultController: NSFetchedResultsController!
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        //	搜索的时候，背景不会模糊。如果使用的不是另一个独立的视图，需要赋值为 false， 否则无法点击搜索的值
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.definesPresentationContext = true
        let bar = searchController.searchBar
        bar.placeholder = "Search Restaurants"
        bar.sizeToFit()
        bar.tintColor = UIColor.whiteColor()
        bar.barTintColor = UIColor(colorLiteralRed: 0xd7/255.0, green: 0xd7/255.0, blue: 0xd7/255.0, alpha: 1.0)
        return searchController
    }()

    let notesViewHeight: CGFloat = 128
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet var noteView: UIView!
    var restaurants:[Restaurant] = []
    var searchedRestaurants = [Restaurant]()
    // MARK: - View Controller Methods

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        //		navigationController?.hidesBarsOnSwipe = true
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        // fetch data
        let fetchRequest = NSFetchRequest(entityName: "Restaurant")
        let sortDes = NSSortDescriptor(key: "name", ascending: true)
        // 按 name 升序排序
        fetchRequest.sortDescriptors = [sortDes]
        tableView.allowsMultipleSelectionDuringEditing = true

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
        tableView.estimatedRowHeight = tableView.rowHeight
        // 这个属性对于那些系统提供的 Cell 来说是默认属性, 但是对于自定义的类型, 默认值是
        // IB 上的 RowHeight. 需要主动设置
        tableView.rowHeight = UITableViewAutomaticDimension

        NSNotificationCenter.defaultCenter().addObserver(
            self, selector: .TextSizeChange,
            name: UIContentSizeCategoryDidChangeNotification, object: nil)
        // 添加搜索栏
        self.tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.delegate = self
    }

    // 用来显示引导界面
    //    override func viewDidAppear(animated: Bool) {
    //        super.viewDidAppear(true)
    //        let isViewed = NSUserDefaults
    //            .standardUserDefaults().boolForKey("hasViewedWalkthrough")
    //        if isViewed == true { return }
    //        if let pageViewController = storyboard?.instantiateViewControllerWithIdentifier(
    //            "WalkthroughController") as? WalkthroughPageViewController {
    //            presentViewController(pageViewController, animated: true, completion: nil)
    //        }
    //    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table View Datasource Methods

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func tableView(
        tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {

        if searchController.active == true {
            return searchedRestaurants.count
        } else {
            return restaurants.count
        }
    }

    private func configureCell(cell: RestaurantTableViewCell, indexPath: NSIndexPath) {
        let restaurant: Restaurant
        if searchController.active {
            restaurant = self.searchedRestaurants[indexPath.row]
        } else {
            restaurant = self.restaurants[indexPath.row]
        }

        cell.configure(restaurant)
    }

    override func tableView(
        tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier(
            "Cell", forIndexPath: indexPath) as! RestaurantTableViewCell

        return cell
    }


    // MARK: - Delegate Methods

    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let detailRestaurantNVC = storyboard!
            .instantiateViewControllerWithIdentifier("restaurantDetailNavigationController")
            as! UINavigationController
        let detailRestaurantVC = detailRestaurantNVC.topViewController as! RestaurantDetailViewController
        detailRestaurantVC.restaurant = restaurants[indexPath.row]
        showViewController(detailRestaurantVC, sender: self)
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? RestaurantTableViewCell else { return }
        // TODO: 根据 textView 的文本长度动态设置大小.
        tableView.beginUpdates()
        if cell.stackView.arrangedSubviews.contains(noteView) {
            removeNotesView(cell)
        } else {
            addNotesViewToCell(cell)
            noteTextView.text = restaurants[indexPath.row].note
        }
        tableView.endUpdates()
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        configureCell(cell as! RestaurantTableViewCell, indexPath: indexPath)
        // inital
        cell.alpha = 0.0
        let rotationTransform = CGAffineTransformMakeTranslation(-300, 0)
        cell.transform = rotationTransform

        UIView.animateWithDuration(0.3, animations: {
            cell.transform = CGAffineTransformIdentity
            cell.alpha = 1.0
        })
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
            guard let managedObjectContext =
                (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext else { return }
            let restaurantToDelete =
                self.fetchResultController.objectAtIndexPath(indexPath) as! Restaurant

            managedObjectContext.deleteObject(restaurantToDelete)
            guard let _ = try? managedObjectContext.save() else { return }
        }

        let callAction = UITableViewRowAction(style: .Normal, title: "Call") {
            [unowned self] (action, indexPath) in
            let telphone = self.restaurants[indexPath.row].phoneNumber
            guard let phone = telphone else { return }
            let url = NSURL(string: "tel://" + phone)!
            UIApplication.sharedApplication().openURL(url)
        }


        shareAction.backgroundColor = UIColor.blueColor()
        callAction.backgroundColor = UIColor.greenColor()

        // 返回的顺序可能会影响显示的，倒序显示。
        return [deleteAction, shareAction, callAction]
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showRestaurantDetail" {
            let cell = sender as! RestaurantTableViewCell
            let row = tableView.indexPathForCell(cell)?.row
            let controller = segue.destinationViewController as! UINavigationController
            let restaurantDVC = controller.topViewController as! RestaurantDetailViewController
            restaurantDVC.restaurant = restaurants[row!]
        }
    }


    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
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
            // 下面这种方法不可以, 虽然我不知道为什么.
            // indexPath.map { tableView.deleteRowsAtIndexPaths([$0], withRowAnimation: .Fade) }
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            self.configureCell(
                tableView.cellForRowAtIndexPath(indexPath!)! as! RestaurantTableViewCell,
                indexPath: indexPath!)

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

    // MARK: - UISearch Controller
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterRestaurant(searchText)
            self.tableView.reloadData()
        }
    }


    func didPresentSearchController(searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }


    // MARK: - Help Methods
    private func filterRestaurant(search: String) {
        searchedRestaurants = restaurants.filter { $0.name.rangeOfString(search, options: .CaseInsensitiveSearch) != nil }
        // 如果没有匹配的名字， 则匹配地址
        if searchedRestaurants.isEmpty {
            searchedRestaurants = restaurants.filter { $0.location.rangeOfString(search, options: .CaseInsensitiveSearch) != nil }
        }
    }



    func addNotesViewToCell(cell: RestaurantTableViewCell) {

        let stack = cell.stackView
        noteView.heightAnchor.constraintEqualToConstant(notesViewHeight - 48).active = true
        noteView.clipsToBounds = true
        stack.addArrangedSubview(noteView)
    }

    func removeNotesView(cell: RestaurantTableViewCell) {
        let stack = cell.stackView
        stack.removeArrangedSubview(noteView)
        noteView.removeFromSuperview()
    }
    // 当字体类型改变的时候，调用

    @objc private func onTextSizeChange(notification: NSNotification) {
        tableView.reloadData()
        print("DJ")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    @IBAction func search(sender: UIBarButtonItem) {
        searchController.active = true
    }
}


// MARK: - extension partion
private extension Selector {
    static let TextSizeChange = #selector(
        RestaurantTableViewController.onTextSizeChange(_:))
}
