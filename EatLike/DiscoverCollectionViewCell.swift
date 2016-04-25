//
//  DiscoverCollectionViewCell.swift
//  EatLike
//
//  Created by Queen Y on 16/4/4.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit

class DiscoverCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var likesTotal: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userThumbImage: UIImageView!
    @IBOutlet weak var restaurantImageButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var headView: UIView!

    func configure(restaurant: DiscoverRestaurants) {
        priceLabel.text = "¥ \(restaurant.price)"
        likesTotal.text = String(restaurant.likesTotal)
        nameLabel.text  = restaurant.name
        userNameLabel.text = restaurant.userName
        userThumbImage.image = restaurant.authorImage
        restaurantImageButton.setImage(restaurant.detailImage, forState: .Normal)
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
