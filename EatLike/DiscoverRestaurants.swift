//
//  DiscoverRestaurants.swift
//  EatLike
//
//  Created by Queen Y on 16/4/4.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit
class DiscoverRestaurants {
    var restaurantID = ""
    var name      = ""
    var type      = ""
    var price     = 0
    var isLike    = false
    var feaurtedImage: UIImage?
    var phoneNumber: String
    var rating    = ""


    init(ID: String, name: String, type: String, phone: String, image: UIImage?,
         price: Int, isLike: Bool, rating: String = "") {
        self.restaurantID  = ID
        self.name          = name
        self.type          = type
        self.feaurtedImage = image
        self.price         = price
        self.isLike        = isLike
        self.phoneNumber   = phone
    }
}