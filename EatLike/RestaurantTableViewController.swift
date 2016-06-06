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
        searchController.definesPresentationContext = true
        searchController.searchResultsUpdater = self
        let bar = searchController.searchBar
        bar.placeholder = NSLocalizedString("Search Restaurants", comment: "place")
        bar.sizeToFit()
        bar.tintColor = UIColor.white()
        bar.barTintColor = UIColor(colorLiteralRed: 0xd7/255.0, green: 0xd7/255.0, blue: 0xd7/255.0, alpha: 1.0)
        return searchController
    }()

    var restaurants: [Restaurant] = []
    var searchedRestaurants = [Restaurant]()
    // MARK: - View Controller Methods

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        // 实现用户引导界面
        let isViewed = NSUserDefaults
            .standard().bool(forKey: "hasViewedWalkthrough")
        if isViewed == true { return }
        let pageViewController = storyboard!.instantiateViewController(
            withIdentifier: "WalkthroughPageController") as! WalkthroughPageViewController
        pageViewController.modalTransitionStyle = .partialCurl

        present(pageViewController, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // 临时代码
         NSUserDefaults.standard().set(false, forKey: "hasViewedWalkthrough")

        // fetch data
        let fetchRequest = NSFetchRequest(entityName: "Restaurant")
        let sortDes = NSSortDescriptor(key: "name", ascending: true)
        // 按 name 升序排序
        fetchRequest.sortDescriptors = [sortDes]
        tableView.allowsMultipleSelectionDuringEditing = true

        guard let managedObjectContext = (UIApplication.shared().delegate as? AppDelegate)?.managedObjectContext else { return }
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

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.title = "Restaurants"
        // 让 tableView 获得可以动态的定义高度.
        tableView.estimatedRowHeight = 88
        // 这个属性对于那些系统提供的 Cell 来说是默认属性, 但是对于自定义的类型, 默认值是
        // IB 上的 RowHeight. 需要主动设置
        tableView.rowHeight = UITableViewAutomaticDimension

        // 当字体改变的时候, 调用通知
        NSNotificationCenter.default().addObserver(
            self, selector: .TextSizeChange,
            name: UIContentSizeCategoryDidChangeNotification, object: nil)

        // 添加搜索栏
        self.tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.delegate = self

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table View Datasource Methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive == true {
            return searchedRestaurants.count
        } else {
            return restaurants.count
        }
    }
    
    private func configureCell(cell: RestaurantTableViewCell, indexPath: NSIndexPath) {
        let restaurant: Restaurant
        if searchController.isActive {
            restaurant = self.searchedRestaurants[indexPath.row]
        } else {
            restaurant = self.restaurants[indexPath.row]
        }
        
        cell.configure(data: restaurant)
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "Cell", for: indexPath) as! RestaurantTableViewCell

        configureCell(cell: cell, indexPath: indexPath)
        return cell
    }
    
    
    // MARK: - Delegate Methods
    
    override func tableView(
        _ tableView: UITableView, didSelectRowAt indexPath: NSIndexPath) {
        let detailRestaurantNVC = storyboard!
            .instantiateViewController(withIdentifier: "restaurantDetailNavigationController")
            as! UINavigationController
        let detailRestaurantVC = detailRestaurantNVC.topViewController as! RestaurantDetailViewController
        detailRestaurantVC.restaurant = restaurants[indexPath.row]
        show(detailRestaurantVC, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
        if searchController.isActive {
            searchController.isActive = false
        }
    }

    override func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: NSIndexPath) {
        // inital
        cell.alpha = 0.0
        let rotationTransform = CGAffineTransform(translationX: -300, y: 0)
        cell.transform = rotationTransform

        UIView.animate(withDuration: 0.3, animations: {
            cell.transform = CGAffineTransform.identity
            cell.alpha = 1.0
        })
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: NSIndexPath) -> Bool {
        if searchController.isActive {
            return false
        }
        return true
    }
    
    // 创建自定义的滑动动作，并且最后将它们作为数组返回
    override func tableView(_ editActionsForRowAttableView: UITableView, editActionsForRowAt indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let restaurant = self.restaurants[indexPath.row]
        let shareAction = UITableViewRowAction(style: .default, title: "Share") {
            [unowned self] (action, indexPath) in
            if let image = restaurant.image {
                let defaultText = "Just check in \(restaurant.name)"
                let activity = UIActivityViewController(
                    activityItems: [image, defaultText],
                    applicationActivities: nil)
                self.present(activity, animated: true, completion: nil)
            }
        }
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") {
            [unowned self] (action, indexPath) in
            let alert = UIAlertController(title: "你确定要删除吗?", message: nil, preferredStyle: .alert)

            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) {
                _ in
                guard let managedObjectContext =
                    (UIApplication.shared().delegate as? AppDelegate)?.managedObjectContext else { return }
                let cache = (UIApplication.shared().delegate as! AppDelegate).imageCache
                let restaurantToDelete =
                    self.fetchResultController.object(at: indexPath) as! Restaurant
                cache.remove(for: restaurant.keyString)
                restaurantToDelete.deleteSpotlightIndex()
                managedObjectContext.delete(restaurantToDelete)
                guard let _ = try? managedObjectContext.save() else { return }
            }
            alert.addAction(deleteAction)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                self.tableView.setEditing(false, animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
            let cell = self.tableView.cellForRow(at: indexPath)!
            cell.shake()
        }
        
        let callAction = UITableViewRowAction(style: .normal, title: "Call") {
            (action, indexPath) in
            let telphone = restaurant.phoneNumber
            let url = NSURL(string: "tel://" + telphone)!
            UIApplication.shared().open(url)
        }
        
        
        shareAction.backgroundColor = UIColor.blue()
        callAction.backgroundColor = UIColor.green()
        
        // 返回的顺序可能会影响显示的，倒序显示。
        if restaurant.phoneNumber.isEmpty {
            return [deleteAction, shareAction]
        } else {
            return [deleteAction, shareAction, callAction]
        }
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifier(for: segue) {
        case .showRestaurantDetail:
            let cell = sender as! RestaurantTableViewCell
            let row = tableView.indexPath(for: cell)?.row
            let controller = segue.destinationViewController as! UINavigationController
            let restaurantDVC = controller.topViewController as! RestaurantDetailViewController
            restaurantDVC.restaurant = restaurants[row!]
        default:
            break
        }
    }
    
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
        // TODO: 希望能够有一个更带感的动画，表示创建新的数据成功。
    }
    
    
    // MARK: - FetchResults Delegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController, didChange anObject: AnyObject, at indexPath: NSIndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            // 下面这种方法不可以, 虽然我不知道为什么.
            // indexPath.map { tableView.deleteRowsAtIndexPaths([$0], withRowAnimation: .Fade) }
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            self.configureCell(
                cell: tableView.cellForRow(at: indexPath!)! as! RestaurantTableViewCell,
                indexPath: indexPath!)
            
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
        // 同时更新数据源.
        restaurants = controller.fetchedObjects as! [Restaurant]
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    // MARK: - UISearch Controller
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterRestaurant(search: searchText)
            self.tableView.reloadData()
        }
    }

    func didPresent(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    // MARK: - Help Methods
    private func filterRestaurant(search: String) {
        searchedRestaurants = restaurants.filter {
            $0.name.range(of: search, options: .caseInsensitiveSearch) != nil
        }
        // 如果没有匹配的名字， 则匹配地址
        if searchedRestaurants.isEmpty {
            searchedRestaurants = restaurants.filter {
                $0.location.range(of: search, options: .caseInsensitiveSearch) != nil
            }
        }
    }
    

    @objc private func onTextSizeChange(notification: NSNotification) {
        tableView.reloadData()
        print("DJ")
    }
    
    deinit {
        NSNotificationCenter.default().removeObserver(self)
    }
    
    @IBAction func search(sender: UIBarButtonItem) {
        searchController.isActive = true
    }
}


extension RestaurantTableViewController: SegueType {
    enum CustomSegueIdentifier: String {
        case popNoteView
        case showRestaurantDetail
        case addRestaurant
    }
}

// MARK: - extension partion
private extension Selector {
    static let TextSizeChange = #selector(
        RestaurantTableViewController.onTextSizeChange(notification:))
}

protocol Shakeable {
    func shake()
}

extension Shakeable where Self: UIView {
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 10
        animation.autoreverses = true
        animation.fromValue = NSValue(
            cgPoint: CGPoint(x: self.center.x - 4.0, y: self.center.y))
        animation.toValue = NSValue(
            cgPoint: CGPoint(x: self.center.x + 4.0, y: self.center.y))
        layer.add(animation, forKey: "position")
    }
}

extension UITableViewCell: Shakeable {}
