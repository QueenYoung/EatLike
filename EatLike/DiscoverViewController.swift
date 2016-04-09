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
    @IBOutlet var userLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!

    private var selected: UIButton?
    private var discovers: [DiscoverRestaurants] = [
        DiscoverRestaurants(
            ID: "宋仲基",
            name: "Paris",
            type: "France",
            phone: "138-0405-1234",
            image: UIImage(named: "cafeloisl"),
            price: 40,
            isLike: true),

        DiscoverRestaurants(
            ID: "都敏俊",
            name: "Shanghai",
            type: "China",
            phone: "188-1231-3412",
            image: UIImage(named: "donostia"),
            price: 39,
            isLike: false),

        DiscoverRestaurants(
            ID: "1008611",
            name: "Rome",
            type: "Itlay",
            phone: "130-3723-2552",
            image: UIImage(named: "forkeerestaurant"),
            price: 56,
            isLike: true),

        DiscoverRestaurants(
            ID: "12389",
            name: "Haha",
            type: "Didiao",
            phone: "130-6512-0086",
            image: UIImage(named: "confessional"),
            price: 40,
            isLike: true)
    ]

    @IBAction func callRestaurant(sender: UIButton) {
        let string = sender.titleLabel?.text
        presentViewController(sender.call(string!)!, animated: true, completion: nil)
    }

    // TODO: 目前只是完成了对所有 button 的唯一一个可以变红色
    // 应该保证每一个 cell 有独立的 status
    @IBAction func like(sender: UIButton) {
        if selected == nil {
            selected = sender
            sender.tintColor = UIColor.redColor()
        } else if selected == sender {
            return
        }

        swap(&sender.tintColor, &selected!.tintColor)
        selected = sender
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundBlurImage.image = UIImage(named: "teakha")
        let blurDark = UIBlurEffect(style: .Dark)
        let blurView = UIVisualEffectView(effect: blurDark)
        blurView.frame = view.frame
        backgroundBlurImage.addSubview(blurView)
        // 把背景设为透明色的, 否则是黑的一片
        collectionView.backgroundColor = UIColor.clearColor()

        userLabel.text = discovers[0].restaurantID
        ratingLabel.text = discovers[0].rating
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return discovers.count
    }

    private func configureCell(cell: DiscoverCollectionViewCell, index: Int) {
        let restaurant = discovers[index]
        cell.configure(restaurant)
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! DiscoverCollectionViewCell

        configureCell(cell, index: indexPath.row)
        return cell
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        let indexPoint: CGPoint = self.view.convertPoint(self.collectionView.center, toView: self.collectionView)
        let indexPathNow = collectionView.indexPathForItemAtPoint(indexPoint)

        if let index = indexPathNow {
            userLabel.text = "From: \(discovers[index.row].restaurantID)"

            let rate = discovers[index.row].rating
            ratingLabel.text = rate.isEmpty ? "这家伙最爱吃这个了." : rate
        }
    }
    
}
