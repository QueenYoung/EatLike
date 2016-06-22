//
//  ImageCache.swift
//  EatLike
//
//  Created by Queen Y on 16/5/4.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit

struct ImageCache {
    let caches = Cache<AnyObject, NSData>()

    func set(imagedata: Data, key: String) {
        // 先把需要缓存的对象, 写入缓存区
        caches.setObject(imagedata, forKey: key)
        // 同时将对象写入 App 的 Document 中
        let imageurl = imageURL(for: key)
		do {
			try imagedata.write(to: imageurl, options: .atomicWrite)
		} catch {
			print(error)
		}
        print("image is write to \(imageurl.path!)")
    }

    func image(for key: String) -> UIImage? {
        // 如果能直接从缓存中找到图片, 就将它转码并且返回
        if let existingData = caches.object(forKey: key),
           let existingImage = UIImage(data: existingData as Data) {
            print("I find the image")
            return existingImage
        }
        
        // 否则去 Document 中查找 并再一次将它存入缓存中.
        // 重新启动 App 的时候就会出现没找到的情况. 因为 Cache 对象被释放咯.
        let imageurl = imageURL(for: key)
        guard let imageForDisk = UIImage(contentsOfFile: imageurl.path!) else { return nil }
        print("I find the image in \(imageurl.path!)")
        let imageData = UIImageJPEGRepresentation(imageForDisk, 0.8)
        caches.setObject(imageData!, forKey: key)
        return imageForDisk
    }
    
    func remove(for key: String) {
        // 清纯缓存的同时, 清楚 document 中的数据.
        caches.removeObject(forKey: key)
        let imageurl = imageURL(for: key)
        do {
            try FileManager.default().removeItem(at: imageurl as URL)
        } catch {
            print(error)
            print("Something was not surive")
        }
        print("Remove the cache from \(imageurl.path!)")
    }
    
    private func imageURL(`for` key: String) -> URL {
        let documentDirectory = FileManager.default()
            .urlsForDirectory(.cachesDirectory, inDomains: .userDomainMask)
        let document = documentDirectory.first!
		do {
			return try document.appendingPathComponent(key)
		} catch {
			fatalError("Appending path component eror")
		}

    }
}
