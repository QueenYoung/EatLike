//
//  AppDelegate.swift
//  EatLike
//
//  Created by Queen Y on 16/3/11.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit
import CoreData
import CoreSpotlight
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var imageCache = ImageCache()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        UIApplication.shared().statusBarStyle = .lightContent
        configureAppearance()
        if let barFont = UIFont(name: "Avenir-Light", size: 24) {
            UINavigationBar.appearance().titleTextAttributes =
                [NSForegroundColorAttributeName: UIColor(red: 0xd7/255.0, green: 0xd7/255.0, blue: 0xd7/255.0, alpha: 1.0),
                 NSFontAttributeName: barFont]
        }

        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        let objectId: String
        if userActivity.activityType == Restaurant.domainIdentifier,
            let activityObjectId = userActivity.userInfo?["id"] as? String {
            // Handle result from NSUserActivity indexing
            objectId = activityObjectId
        } else if userActivity.activityType == CSSearchableItemActionType,
            let activityObjectId = userActivity
                .userInfo?[CSSearchableItemActivityIdentifier] as? String  {
            // Handle result from CoreSpotlight indexing
            objectId = activityObjectId
        } else {
            return false
        }

        print(window!.rootViewController)
        print((window!.rootViewController as! UITabBarController).viewControllers!)
        if let tabv = window!.rootViewController as? UITabBarController,
            nav = tabv.viewControllers!.first as? UINavigationController,
            homeVC = nav.viewControllers.first as? RestaurantTableViewController,
            restaurant = homeVC.restaurants.filter({$0.keyString == objectId}).first {

            nav.popToRootViewController(animated: false)
            let restaurantDetailVC = (
                homeVC.storyboard!
                    .instantiateViewController(
                        withIdentifier: "restaurantDetailNavigationController")
                    as! UINavigationController
                ).topViewController
                as! RestaurantDetailViewController

            restaurantDetailVC.restaurant = restaurant
            nav.pushViewController(restaurantDetailVC, animated: true)
            return true
        }
        return false
    }

    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        // TODO: 通过这个方法可以在软件运行的时候, 显示 alert.
        // 接下来只需要定义一个有意思的就可以.
        let alert = UIAlertController(title: "吃饭时间到了!", message: "不愿走路的话, 就叫外卖吧", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        ((window!.rootViewController! as! UITabBarController)
            .viewControllers![0] as! UINavigationController)
            .topViewController?.present(alert, animated: true, completion: nil)
    }

    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: () -> Void) {
        if identifier == "Justsavaworld" {
            NSNotificationCenter.default().post(name: "SaveWorld", object: nil)
        }

        completionHandler()
    }

    // MARK: - Core Data stack/**/

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.appcoda.CoreDataDemo" in the application's documents Application Support directory.
        let urls = NSFileManager.default().urlsForDirectory(.documentDirectory, inDomains: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.main().urlForResource("EatLike", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("EatLike.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: url,
                options: nil
            )
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }

        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(
            concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
}



