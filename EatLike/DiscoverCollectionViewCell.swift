//
//  DiscoverCollectionViewCell.swift
//  EatLike
//
//  Created by Queen Y on 16/4/4.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit

class DiscoverCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var likesTotal: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userThumbImage: UIImageView!
    @IBOutlet weak var restaurantImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var headView: UIView!
    @IBOutlet weak var dialogStackView: UIStackView!
    @IBOutlet weak var buttonStackView: UIStackView!

    func configure(restaurant: DiscoverRestaurants) {
        let cache = (UIApplication.sharedApplication().delegate as! AppDelegate).imageCache
        likesTotal.text = String(restaurant.likesTotal)
        nameLabel.text  = restaurant.name
        userNameLabel.text = restaurant.userName
        userThumbImage.image = cache.imageForKey(restaurant.authorImageKey)
        restaurantImage.image = cache.imageForKey(restaurant.detailImageKey)
        userNameLabel.text?.appendContentsOf(" | \(restaurant.foodName)")
        // 加上圆角效果 and Blur
        getBlurView(headView, style: .Dark)
        layer.cornerRadius = 6.0
    }

    func changeLikeTotal(add: Bool) {
        if add {
            let total = Int(likesTotal.text!)! + 1
            likesTotal.text = "\(total)"
        } else {
            let total = Int(likesTotal.text!)! - 1
            likesTotal.text = "\(total)"
        }
    }
}
