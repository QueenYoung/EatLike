//
//  RestaurantDetailViewController.swift
//  EatLike
//
//  Created by Queen Y on 16/3/12.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit

class RestaurantDetailViewController: UIViewController,
                                      UITableViewDataSource,
                                      UITableViewDelegate {

    @IBOutlet weak var restaurantImageView: UIImageView!
    @IBOutlet var tableView: UITableView!

    var restaurant: Restaurant!
    let cache = (UIApplication.shared().delegate as! AppDelegate).imageCache

    // MARK: - View Controller
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = restaurant.name
        // 设置状态栏的透明效果
        restaurantImageView.image = cache.image(for: restaurant.keyString)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.estimatedRowHeight = 64
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.hidesBarsOnSwipe = false
    }


    override func viewWillDisappear(_ animated: Bool) {
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
            restaurantImageView.image = cache.image(for: restaurant.keyString)
            tableView.reloadData()
            if navigationItem.title != restaurant.name {
                navigationItem.title = restaurant.name
            }
            return
        } else if sourceViewController is RemindTableViewController {
            restaurant.scheduleNotification()
        } else if  sourceViewController is MapViewController {
            tableView.reloadRows(at: [NSIndexPath(forRow: 0, inSection: 0)], with: .automatic)
        }

        guard let managedObjectContext =
            (UIApplication.shared().delegate as? AppDelegate)?
                .managedObjectContext else { return }

        try! managedObjectContext.save()
        restaurant.updateSpotlightIndex()
    }


    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifier(for: segue) {
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
            let scaleVC = (segue.destinationViewController as! UINavigationController)
                .topViewController as! DetailImageController
            scaleVC.image = restaurantImageView.image
        default:
            break
        }
    }

    // MARK: - Table View Data Source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: NSIndexPath) {
        let row = indexPath.row

        switch row {
        case 0:
            performSegue(with: .ModalMapView, sender: self)
        case 2:
            // will modal a alert view
            if let alert = call(telphone: restaurant.phoneNumber) {
                present(alert, animated: true, completion: nil)
            }
        case 3:
            let reviewNC = storyboard!
                .instantiateViewController(withIdentifier: "ReviewNavigationController")
                as! UINavigationController

            let reviewVC = reviewNC.topViewController as! ReviewViewController
            reviewVC.restaurant = restaurant
            show(reviewVC, sender: self)
        case 4:
            performSegue(with: .ShowReminded, sender: self)
        default:
            break
        }

        tableView.deselectRow(at: indexPath, animated: false)
    }



    func tableView(_ tableView: UITableView, cellForRowAt indexPath: NSIndexPath) -> UITableViewCell {

        let row = indexPath.row
        var cell: UITableViewCell!
        if case 0...2 = row {
            cell = tableView.dequeueReusableCell(withIdentifier: "NormalCell")
                as! DetailTableViewCell
        } else if row == 3 {
            cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell")!
        } else if row == 4 {
            cell = tableView.dequeueReusableCell(withIdentifier: "RemainedCell")
        }

        switch row {
        case 0:
            (cell as! DetailTableViewCell).titleLabel.text = NSLocalizedString("Location", comment: "location")
            (cell as! DetailTableViewCell).subtitleLabel.text = restaurant.location
        case 1:
            (cell as! DetailTableViewCell).titleLabel.text = NSLocalizedString("Category", comment: "category")
            (cell as! DetailTableViewCell).subtitleLabel.text = restaurant.type
        case 2:
            (cell as! DetailTableViewCell).titleLabel.text = NSLocalizedString("Phone", comment: "phonenumber")
            if !restaurant.phoneNumber.isEmpty{
                (cell as! DetailTableViewCell).subtitleLabel.text = restaurant.phoneNumber
            } else {
                (cell as! DetailTableViewCell).subtitleLabel.text = NSLocalizedString("No phone", comment: "nophone")
            }
        case 3:
            let count = Int(restaurant.userRate.intValue)
            cell.textLabel?.text = NSLocalizedString("Review", comment: "review")
            if count == 0 {
                cell.detailTextLabel?.text = String(repeating:  Character("🌕"), count: count)
                cell.detailTextLabel?.textColor = UIColor.lightGray()
            } else {
                cell.detailTextLabel?.text = String(repeating:  Character("⭐️"), count: count)
            }
        default:
            break
        }
        return cell
    }

    private func configureStarColor(_ count: Int) {
        let indexpath = NSIndexPath(forRow: 3, inSection: 0)
        let cell = tableView.cellForRow(at: indexpath)
        cell?.detailTextLabel?.text = String(repeating:  Character("⭐️"), count: count)
    }

    @IBAction func cancel(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Protocol extension
protocol SegueType {
    associatedtype CustomSegueIdentifier: RawRepresentable
}

extension SegueType where Self: UIViewController, CustomSegueIdentifier.RawValue == String {
    func performSegue(with identifier: CustomSegueIdentifier, sender: AnyObject?) {
        performSegue(withIdentifier: identifier.rawValue, sender: self)
    }

    func segueIdentifier(for segue: UIStoryboardSegue) -> CustomSegueIdentifier {
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
    /* @IBAction func tapGestureImageForDetail(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            performSegueWithIdentifier(.ScaleImage, sender: nil)
            print(#function)
        }
    } */

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 1 {
            performSegue(with: .ScaleImage, sender: nil)
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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 1 {
            dismiss(animated: true, completion: nil)
        }
    }
}