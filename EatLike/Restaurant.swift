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
    @NSManaged var note: String
    @NSManaged var userRate: NSNumber
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

func ==(lhs: Restaurant, rhs: Restaurant) -> Bool {
	if lhs.name != rhs.name {
		return false
	} else if lhs.location != rhs.location {
		return false
	} else if lhs.type != rhs.type {
		return false
	} else if lhs.phoneNumber != rhs.phoneNumber {
		return false
	} else if lhs.note != rhs.note {
		return false
	} else {
		return true
	}
}

