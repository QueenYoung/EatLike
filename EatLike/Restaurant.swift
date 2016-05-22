//
//  Restaurant.swift
//  EatLike
//
//  Created by Queen Y on 16/3/12.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit
import CoreData
import CoreSpotlight
import MobileCoreServices
import CoreLocation
class Restaurant: NSManagedObject {
	@NSManaged var name: String
	@NSManaged var type: String
	@NSManaged var location: String
	@NSManaged var phoneNumber: String
	@NSManaged var image: NSData?
	// 因为 coredata 不存在 Boolean 类型, 所以需要使用 NSNumber
    @NSManaged var note: String
    @NSManaged var userRate: NSNumber
    @NSManaged var needRemind: NSNumber

    // 餐厅的详细位置
    @NSManaged var dueDate: NSDate!
    @NSManaged var alertMessage: String
    @NSManaged var keyString: String
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
// MARK: - Local Notification
extension Restaurant {
    func scheduleNotification() {
	    if !needRemind.boolValue {
		    let existingNotification = scheduledNotifications()
		    if let exist = existingNotification {
			    UIApplication.sharedApplication().cancelLocalNotification(exist)
			    return
		    }
	    } else if dueDate.compare(NSDate()) == .OrderedDescending {
		    let notification = UILocalNotification()
            // fix some bug
            // 这个可选集合必须包括所有需要用到的时间 Unit, 否则默认都是0
            let dateComponents = NSCalendar.currentCalendar().components(
                [.Day, .Hour, .Minute, .Second, .Month, .Year], fromDate: dueDate)
            dateComponents.second = 0
            let fixedDate = NSCalendar.currentCalendar().dateFromComponents(dateComponents)!
            print(fixedDate)
		    notification.fireDate = fixedDate
		    notification.timeZone = .defaultTimeZone()
		    notification.alertBody = alertMessage
		    notification.soundName = UILocalNotificationDefaultSoundName
            notification.alertAction = "Youqu"
            notification.alertTitle = "\(name)"
		    let identifier = "\(name)\(type)\(phoneNumber)"
		    notification.userInfo = ["itemID": identifier]
		    UIApplication.sharedApplication().scheduleLocalNotification(notification)
	    }
    }

    private func scheduledNotifications() -> UILocalNotification? {
        let identifier = "\(name)\(type)\(phoneNumber)"
        let schedule = UIApplication.sharedApplication().scheduledLocalNotifications
        guard let all = schedule else { return nil }
        return all.filter { (($0.userInfo?["itemID"] as? String) ?? "") == identifier }.first
    }
}

// MARK: - Core Spotlight
extension Restaurant {
    // 因为某个我还不太了解的原因, 这里必须使用 nonobjc 标记, 或者使用计算属性.
    @nonobjc static let domainIdentifier = "com.jxau.queen.eatlike"

    var userActivityUserInfo: [NSObject: AnyObject] {
        return ["id": keyString]
    }

    var userActivity: NSUserActivity {
        let activity = NSUserActivity(activityType: Restaurant.domainIdentifier)
        activity.userInfo = userActivityUserInfo
        activity.contentAttributeSet = attributeSet
        return activity
    }

    var attributeSet: CSSearchableItemAttributeSet {
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeContact as String)
        attributeSet.title = name
        var rate = ""
        if userRate.integerValue != 0 {
            rate = "\n"
            rate.appendContentsOf(String(count: userRate.integerValue, repeatedValue: "⭐️"))
        }


        attributeSet.contentDescription = "\(location)\(rate)\n\(phoneNumber)"
        attributeSet.thumbnailData = image
        attributeSet.supportsPhoneCall = true

        attributeSet.phoneNumbers = [phoneNumber]
        attributeSet.keywords = [phoneNumber, name, location]

        attributeSet.relatedUniqueIdentifier = keyString

        return attributeSet
    }

    var searchableItem: CSSearchableItem {
        let item = CSSearchableItem(
            uniqueIdentifier: keyString,
            domainIdentifier: Restaurant.domainIdentifier,
            attributeSet: attributeSet)

        return item
    }

    func updateSpotlightIndex() {
        CSSearchableIndex.defaultSearchableIndex().indexSearchableItems([searchableItem]) {
            error in
            if error != nil {
                print(error)
            } else {
                print("Successed")
            }
        }
    }

    func deleteSpotlightIndex() {
        CSSearchableIndex.defaultSearchableIndex()
            .deleteSearchableItemsWithIdentifiers([keyString]) {
                error in
                if error != nil {
                    print(error)
                } else {
                    print("Delete the spotlight index")
                }
        }
    }
}