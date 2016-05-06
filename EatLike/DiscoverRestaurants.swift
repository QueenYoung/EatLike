//
//  DiscoverRestaurants.swift
//  EatLike
//
//  Created by Queen Y on 16/4/4.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit
class DiscoverRestaurants {
    var name           = ""
    var userName       = ""
    var foodName       = ""
    var type           = ""
    var price          = 0
    var isLike         = false
    var rating         = ""
    var likesTotal     = 0

    var detailImage: UIImage?
    var authorImage: UIImage?
    let detailImageKey: String
    let authorImageKey: String


    init(restaurantName: String, userName: String, foodName: String,
         type: String, image: UIImage?,
         price: Int, isLike: Bool = false, rating: String = "",
         userImage: UIImage?, likes: Int) {
        self.name = restaurantName
        self.userName       = userName
        self.type           = type
        self.detailImage    = image
        self.price          = price
        self.isLike         = isLike
        self.authorImage    = userImage
        self.likesTotal     = likes
        self.foodName       = foodName
        self.detailImageKey = NSUUID().UUIDString
        self.authorImageKey = NSUUID().UUIDString
    }
}