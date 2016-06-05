//
//  DiscoverRestaurants.swift
//  EatLike
//
//  Created by Queen Y on 16/4/4.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit

class DiscoverRestaurants {
    let name: String
    let userName: String
    let foodName: String
    let category: String
    let note: String
    let detailImage: UIImage?
    let authorImage: UIImage?

    var likesTotal: Int
    var isLike  = false
//    let detailImageKey: String
//    let authorImageKey: String

    init(name: String, userName: String, foodName: String, category: String,
         isLike: Bool, note: String, likesTotal: Int, detailImage: UIImage,
         authorImage: UIImage) {
        self.name        = name
        self.userName    = userName
        self.foodName    = foodName
        self.category    = category
        self.isLike      = isLike
        self.note        = note
        self.likesTotal  = likesTotal
        self.detailImage = detailImage
        self.authorImage = authorImage


        // 如果是第一次使用的话, 就设置一些属性并且将 UUID存储, 并设置缓存
        // 否则直接从 standUserDefault 中获取

        /* let cache = (UIApplication.shared().delegate as! AppDelegate).imageCache
        let stand = NSUserDefaults.standardUserDefaults()
        if stand.integerForKey("OneTimes") == 0 {
            detailImageKey = NSUUID().UUIDString
            authorImageKey = NSUUID().UUIDString

            stand.setInteger(1, forKey: "OneTimes")
            stand.setObject(detailImageKey, forKey: "detailKey")
            stand.setObject(authorImageKey, forKey: "authorKey")

            cache.setImage(UIImageJPEGRepresentation(detailImage, 0.8)!, key: detailImageKey)
            cache.setImage(UIImageJPEGRepresentation(authorImage, 0.8)!, key: authorImageKey)
        } else {
            detailImageKey = stand.stringForKey("detailKey")!
            authorImageKey = stand.stringForKey("authorKey")!
        } */
    }

}