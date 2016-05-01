//
//  RestaurantDetailViewController.swift
//  EatLike
//
//  Created by Queen Y on 16/3/12.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit

class RestaurantDetailViewController: UIViewController, UITableViewDataSource,
                                      UITableViewDelegate, SegueType {

    @IBOutlet weak var restaurantImageView: UIImageView!
    @IBOutlet var tableView: UITableView!

    var restaurant: Restaurant!

    enum CustomSegueIdentifier: String {
        case ReviewNavigationController
        case ModalMapView
        case ShowReminded
        case EditRestaurant
    }

    // MARK: - View Controller
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = restaurant.name
        // 设置状态栏的透明效果
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar
            .setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage.init()
        navigationController?.interactivePopGestureRecognizer?.enabled = true
        restaurantImageView.image = UIImage(data: restaurant.image!)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        // 进入 detail 视图的时候,关闭 hide on swipe 功能.
        //		navigationController?.hidesBarsOnSwipe = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func unwindToDetail(segue: UIStoryboardSegue) {
        if let ratingVC = segue.sourceViewController as? ReviewViewController {
            restaurant = ratingVC.restaurant
            let count = Int(restaurant.userRate.intValue)
            configureStarColor(count)
        } else if let editVC = segue.sourceViewController
            as? AddRestaurantTableViewController {
            let newRest = editVC.newRestaurant
            // TODO: 谷歌怎么 判断两个图片是否相同.
            //	if !restaurant.image!.isEqualToData(newRest.image!) {
            restaurantImageView.image = UIImage(data: newRest.image!)
            // }
            // TODO: 写一个函数, 判断 restaurant 的哪些属性被修改了.
            restaurant = editVC.newRestaurant
            tableView.reloadData()
        } else if let remindVC = segue.sourceViewController as? RemindTableViewController {
            restaurant = remindVC.restaurant
            restaurant.scheduleNotification()
        }

        guard let managedObjectContext =
            (UIApplication.sharedApplication().delegate as? AppDelegate)?
                .managedObjectContext else { return }

        try! managedObjectContext.save()
    }


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .EditRestaurant:
            let editVc = segue.destinationViewController as! AddRestaurantTableViewController
            editVc.newRestaurant = restaurant
        case .ShowReminded:
            let remindVC = segue.destinationViewController as! RemindTableViewController
            remindVC.restaurant = restaurant
            remindVC.dueDate = restaurant.dueDate ?? NSDate()
        case .ModalMapView:
            let mapViewNC = segue.destinationViewController as! UINavigationController
            let mapView = mapViewNC.topViewController as! MapViewController
            mapView.restaurant = restaurant
        default:
            break
        }
    }

    // MARK: - Table View Data Source

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row

        switch row {
        case 0:
                performSegueWithIdentifier(.ModalMapView, sender: self)
        case 2:
            // will modal a alert view
            if let phone = restaurant.phoneNumber,
                let alert = call(phone)  {
                presentViewController(alert, animated: true, completion: nil)
            }
        case 3:
            let reviewNC = storyboard!
                .instantiateViewControllerWithIdentifier("ReviewNavigationController")
                as! UINavigationController

            let reviewVC = reviewNC.topViewController as! ReviewViewController
            reviewVC.restaurant = restaurant
            showViewController(reviewVC, sender: self)
        case 4:
            performSegueWithIdentifier(.ShowReminded, sender: self)
        default:
            break
        }

        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }



    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let row = indexPath.row


        var cell = tableView.dequeueReusableCellWithIdentifier("NormalCell")!
        cell.textLabel?.textColor = .blueColor()
        cell.textLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        cell.detailTextLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        switch row {
        case 0:
            cell.textLabel?.text = "Location"
            cell.detailTextLabel?.text = restaurant.location
        case 1:
            cell.textLabel?.text = "Category"
            cell.detailTextLabel?.text = restaurant.type
        case 2:
            cell.textLabel?.text = "Phone"
            cell.detailTextLabel?.text = restaurant.phoneNumber
        case 3:
            let count = Int(restaurant.userRate.intValue)
            cell = tableView.dequeueReusableCellWithIdentifier("ReviewCell")!
            cell.textLabel?.text = "Review"
            if count == 0 {
                cell.detailTextLabel?.text = "Touch me to review the food"
                cell.detailTextLabel?.textColor = UIColor.lightGrayColor()
            } else {
                cell.detailTextLabel?.text = String(count: count, repeatedValue: Character("★"))
            }
        case 4:
            cell = tableView.dequeueReusableCellWithIdentifier("RemainedCell")!
        default:
            break
        }
        return cell
    }

    private func configureStarColor(count: Int) {
        let indexpath = NSIndexPath(forRow: 3, inSection: 0)
        let cell = tableView.cellForRowAtIndexPath(indexpath)
        cell?.detailTextLabel!.text = String(count: count, repeatedValue: Character("★"))
        cell?.detailTextLabel?.textColor = .yellowColor()
    }

    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

protocol SegueType {
    associatedtype CustomSegueIdentifier: RawRepresentable
}

extension SegueType where Self: UIViewController, CustomSegueIdentifier.RawValue == String {
    func performSegueWithIdentifier(identifier: CustomSegueIdentifier, sender: AnyObject?) {
        performSegueWithIdentifier(identifier.rawValue, sender: self)
    }

    func segueIdentifierForSegue(segue: UIStoryboardSegue) -> CustomSegueIdentifier {
        guard let identifier = segue.identifier,
            segueIdentifier = CustomSegueIdentifier(rawValue: identifier) else {
                fatalError("Invalid segue identifier \(segue.identifier)")
        }
        return segueIdentifier
    }
}


