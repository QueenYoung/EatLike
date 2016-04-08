//
//  DiscoverCollectionViewCell.swift
//  EatLike
//
//  Created by Queen Y on 16/4/4.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit

class DiscoverCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var telphoneButton: UIButton!

//    @IBOutlet weak var dislikeButton: UIButton!
//    @IBOutlet weak var goodButton: UIButton!
//    @IBOutlet weak var favoriteButton: UIButton!

    func configure(restaurant: DiscoverRestaurants) {
        nameLabel.text = restaurant.name
        typeLabel.text = restaurant.type
        telphoneButton.setTitle(restaurant.phoneNumber, forState: .Normal)
        priceLabel.text = "$\(restaurant.price)"
        imageView.image = restaurant.feaurtedImage

        // 加上圆角效果.
        layer.cornerRadius = 6.0
    }
}
