//
//  RestaurantDetailViewController.swift
//  EatLike
//
//  Created by Queen Y on 16/3/12.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit

class RestaurantDetailViewController: UIViewController, UITableViewDataSource,
                                      UITableViewDelegate {

    @IBOutlet weak var restaurantImageView: UIImageView!
    @IBOutlet var tableView: UITableView!

    var restaurant: Restaurant!
    let cache = (UIApplication.sharedApplication().delegate as! AppDelegate).imageCache

    // MARK: - View Controller
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = restaurant.name
        // 设置状态栏的透明效果
        restaurantImageView.image = cache.imageForKey(restaurant.keyString)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        // 进入 detail 视图的时候,关闭 hide on swipe 功能.
        navigationController?.hidesBarsOnSwipe = false
//        let size = CGSize(width: 1, height: 1)
//        navigationController?.navigationBar
//            .setBackgroundImage(.withColor(.clearColor(), size: size), forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage.init()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        configureAppearance()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func unwindToDetail(segue: UIStoryboardSegue) {
        // 突然发现 因为都是引用类型, 根本不需要使用将 sourceView 的 属性
        // 赋值给当前视图的属性
        // 我完全是在做无用功啊!  不过这样下次可以试下使用 结构体咯.
        let sourceViewController = segue.sourceViewController
        if sourceViewController is ReviewViewController {
            let count = Int(restaurant.userRate.intValue)
            configureStarColor(count)
        } else if sourceViewController is AddRestaurantTableViewController {
            restaurantImageView.image = cache.imageForKey(restaurant.keyString)
            tableView.reloadData()
        } else if sourceViewController is RemindTableViewController {
            restaurant.scheduleNotification()
        } else if  sourceViewController is MapViewController {
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
        }

        guard let managedObjectContext =
            (UIApplication.sharedApplication().delegate as? AppDelegate)?
                .managedObjectContext else { return }

        try! managedObjectContext.save()
    }


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .EditRestaurant:
            let editNV = segue.destinationViewController as! UINavigationController
            let editVc = editNV.topViewController as! AddRestaurantTableViewController
            editVc.newRestaurant = restaurant
        case .ShowReminded:
            let remindVC = segue.destinationViewController as! RemindTableViewController
            remindVC.restaurant = restaurant
            remindVC.dueDate = restaurant.dueDate ?? NSDate()
        case .ModalMapView:
            let mapViewNC = segue.destinationViewController as! UINavigationController
            let mapView = mapViewNC.topViewController as! MapViewController
            mapView.restaurant = restaurant
        case .ScaleImage:
            let scaleVC = segue.destinationViewController as! DetailImageController
            scaleVC.image = restaurantImageView.image
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
            if let alert = call(restaurant.phoneNumber) {
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
            if !restaurant.phoneNumber.isEmpty{
                cell.detailTextLabel?.text = restaurant.phoneNumber
            } else {
                cell.detailTextLabel?.text = "No telphone"
            }
        case 3:
            let count = Int(restaurant.userRate.intValue)
            cell = tableView.dequeueReusableCellWithIdentifier("ReviewCell")!
            cell.textLabel?.text = "Review"
            if count == 0 {
                cell.detailTextLabel?.text = String(count: 5, repeatedValue: Character("★"))
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
        cell?.detailTextLabel?.textColor = UIColor(red: 1, green: 180/255.0, blue: 0, alpha: 1.0)
    }

    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - Protocol extension
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

extension RestaurantDetailViewController: SegueType {
    enum CustomSegueIdentifier: String {
        case ReviewNavigationController
        case ModalMapView
        case ShowReminded
        case EditRestaurant
        case ScaleImage
    }
}

extension RestaurantDetailViewController {
    @IBAction func tapGestureImageForDetail(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            performSegueWithIdentifier(.ScaleImage, sender: nil)
            print(#function)
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if touches.count == 1 {
            performSegueWithIdentifier(.ScaleImage, sender: nil)
        }
    }

}

class DetailImageController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }

    @IBAction func tapGestureToReturn(sender: UITapGestureRecognizer) {
//        dismissViewControllerAnimated(true, completion: nil)
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if touches.count == 1 {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
}