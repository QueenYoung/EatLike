//
//  Restaurant.swift
//  EatLike
//
//  Created by Queen Y on 16/3/12.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit
import CoreData
class Restaurant: NSManagedObject {
	@NSManaged var name: String
	@NSManaged var type: String
	@NSManaged var location: String
	@NSManaged var phoneNumber: String?
	@NSManaged var image: NSData?
	// 因为 coredata 不存在 Boolean 类型, 所以需要使用 NSNumber
	@NSManaged var isVisited: NSNumber?
	@NSManaged private var ratingValue: String
	// 通过新建一个属性, 来让枚举可以更好的在 Core Data 下工作
	var rating: Rating {
		get {
			return Rating(rawValue: self.ratingValue) ?? Rating(rawValue: "None")!
		}

		set {
			self.ratingValue = newValue.rawValue
		}
	}


	/* init?(name: String, type: String, location: String,
	                 phoneNumber: String, picture image: NSData?, isVisited: Bool) {
		if name.isEmpty || type.isEmpty || location.isEmpty {
			return nil
		}

		super.ini
		self.name = name
		self.type = type
		self.location = location
		self.phoneNumber = phoneNumber
		self.image = image
		self.isVisited = isVisited
	} */
}

public enum Rating: String {
	case Dislike = "dislike"
	case Good = "good"
	case Great = "great"
	case None
}

extension Restaurant {
	override var description: String {
		return "The restaurant is \(name), it is in \(location)," +
				 "\(type)"
	}
}

extension String {
	subscript(index: Int) -> Character {
		return self[self.startIndex.advancedBy(index, limit: self.endIndex.predecessor())]
	}
}