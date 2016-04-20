//
//  DiscoverViewController.swift
//  EatLike
//
//  Created by Queen Y on 16/4/4.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit

class DiscoverViewController: UIViewController,
                              UICollectionViewDataSource,
                              UICollectionViewDelegate {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var backgroundBlurImage: UIImageView!

    private var discovers: [DiscoverRestaurants] = [
        DiscoverRestaurants(
            restaurantName: "红旗酒楼",
            userName: "Mark",
            foodName: "Litte cake",
            type: "酒店",
            image: UIImage(named: "bourkestreetbakery"),
            price: 50,
            rating: "Very good",
            userImage: UIImage(named: "avatar"),
            likes: 90),

        DiscoverRestaurants(
            restaurantName: "桃花",
            userName: "Queen",
            foodName: "Big food",
            type: "Caffce",
            image: UIImage(named: "cafelore"),
            price: 20,
            rating: "It's very fantastical",
            userImage: UIImage(named: "avatar2"),
            likes: 10),
    ]

    @IBOutlet weak var likesTotal: UILabel!
    @IBAction func callRestaurant(sender: UIButton) {
        let string = sender.titleLabel?.text
        presentViewController(sender.call(string!)!, animated: true, completion: nil)
    }

    // TODO: 目前只是完成了对所有 button 的唯一一个可以变红色
    // 应该保证每一个 cell 有独立的 status

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundBlurImage.image = UIImage(named: "cafelore")
        getBlurView(backgroundBlurImage, style: .Dark)
//        getBlurView(headView, style: .Dark)
        // 把背景设为透明色的, 否则是黑的一片
        collectionView.backgroundColor = UIColor.clearColor()

    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        tabBarController?.tabBar.hidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return discovers.count
    }



    func collectionView(collectionView: UICollectionView,
                        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
            "Cell", forIndexPath: indexPath) as! DiscoverCollectionViewCell

        configureCell(cell, index: indexPath.row)
        return cell
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("Start")
        if segue.identifier == "modalFriend" {
            print("medium 1")
            // 因为是通过 button 来完成 segue 的, 所以无法直接调用 collectionView 的方法来获取 indexPath
            let indexPoint: CGPoint = self.view.convertPoint(self.collectionView.center, toView: self.collectionView)
            let indexPathNow = collectionView.indexPathForItemAtPoint(indexPoint)
            if let index = indexPathNow {
                print("medium 2")
                let DetailUN = segue.destinationViewController as! UINavigationController
                let detailVC = DetailUN.topViewController as! FriendRestaurantViewController
                detailVC.friendData = discovers[index.row]
            }
        }
        print("End")
    }

    // Unwind Segue
    @IBAction func cancelToHome(segue: UIStoryboardSegue) {
        let source = segue.sourceViewController as! FriendRestaurantViewController
        let index = collectionView.indexPathsForSelectedItems()?.first

        if let index = index {
            discovers[index.row] = source.friendData
        }
    }


    // MARK: Action
    @IBAction func imageButtonDidPressed(sender: UIButton) {
        /* UIView.animateWithDuration(0.7, delay: 0.0, options: [], animations: {
            let width = self.view.bounds.width
            let height = self.view.bounds.height
//            self.dialogView.layer.cornerRadius = 0.0
//            self.dialogView.frame = CGRectMake(0, 0, width, height)
//            self.imageButton.frame = CGRectMake(0, 0, width, 240)
        }) { _ in
            self.performSegueWithIdentifier("modalFriend", sender: self)
        } */
//        performSegueWithIdentifier("modalFriend", sender: self)
    }

    @IBAction func likeButtonDidPressed(sender: UIButton) {
        let tintColor = sender.tintColor
        let indexPath = getCurrentIndexPath()
        guard let index = indexPath else { return }
        let row = index.row
        let currentCell = collectionView.cellForItemAtIndexPath(index) as! DiscoverCollectionViewCell
        if tintColor == UIColor.blueColor() {
            discovers[row].likesTotal += 1
            sender.tintColor = UIColor.redColor()
            currentCell.changeLikeTotal(true)
        } else {
            discovers[row].likesTotal -= 1
            sender.tintColor = UIColor.blueColor()
            currentCell.changeLikeTotal(false)
        }
    }

// MARK: - Helper Function
    private func getCurrentIndexPath() -> NSIndexPath? {
        let indexPoint: CGPoint = self.view.convertPoint(
            self.collectionView.center, toView: self.collectionView)
        let indexPath = collectionView.indexPathForItemAtPoint(indexPoint)
        return indexPath
    }

    private func configureCell(cell: DiscoverCollectionViewCell, index: Int) {
        let restaurant = discovers[index]
        cell.configure(restaurant)
    }

}

public func getBlurView(view: UIView, style: UIBlurEffectStyle) {
    view.backgroundColor = .clearColor()
    
    let blurEffect = UIBlurEffect(style: style)
    let blurView = UIVisualEffectView(effect: blurEffect)
    blurView.frame = view.bounds
    view.addSubview(blurView)
}