//
//  ImageCache.swift
//  EatLike
//
//  Created by Queen Y on 16/5/4.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit

struct ImageCache {
    let caches = NSCache()

    func setImage(imagedata: NSData, key: String) {
        // 先把需要缓存的对象, 写入缓存区
        caches.setObject(imagedata, forKey: key)

        // 同时将对象写入 App 的 Document 中
        let imageURL = imageURLForKey(key)
        imagedata.writeToURL(imageURL, atomically: true)
        print("image is write to \(imageURL.path!)")
    }

    func imageForKey(key: String) -> UIImage? {
        // 如果能直接从缓存中找到图片, 就将它转码并且返回
        if let existingData = caches.objectForKey(key) as? NSData,
           let existingImage = UIImage(data: existingData) {
            print("I find the image")
            return existingImage
        }

        // 否则去 Document 中查找 并再一次将它存入缓存中.
        // 重新启动 App 的时候就会出现没找到的情况. 因为 Cache 对象被释放咯.
        let imageURL = imageURLForKey(key)
        guard let imageForDisk = UIImage(contentsOfFile: imageURL.path!) else { return nil }
        print("I find the image in \(imageURL.path!)")
        let imageData = UIImageJPEGRepresentation(imageForDisk, 0.6)
        caches.setObject(imageData!, forKey: key)
        return imageForDisk
    }

    func removeImage(key: String) {
        // 清纯缓存的同时, 清楚 document 中的数据.
        caches.removeObjectForKey(key)
        let imageURL = imageURLForKey(key)

        do {
            try NSFileManager.defaultManager().removeItemAtURL(imageURL)
        } catch {
            print(error)
            print("Something was not surive")
        }
        print("Remove the cache from \(imageURL.path!)")
    }

    private func imageURLForKey(key: String) -> NSURL {
        let documentDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let document = documentDirectory.first!

        return document.URLByAppendingPathComponent(key)
    }
}