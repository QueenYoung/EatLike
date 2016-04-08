//
//  WalkthroughPageViewController.swift
//  EatLike
//
//  Created by Queen Y on 16/3/22.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit

class WalkthroughPageViewController: UIPageViewController,
                                     UIPageViewControllerDataSource {

    let pageHeadings = ["Personalize", "Locate", "Discover"]
    let pageContents = [
        "Pin your favorite restaurants and create your own food guide",
        "Search and locate your favorite restaurant on Maps.",
        "Find restaurant pinned by your friends and other aronud the world"
    ]
    let pageImages = [
        "foodpin-intro-1", "foodpin-intro-2", "foodpin-intro-3"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        if let startingViewController = viewControllerAtIndex(0) {
            setViewControllers([startingViewController], direction: .Forward, animated: true, completion: nil)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



    // MARK: - PageView Datasouce Methods
    private func viewControllerAtIndex(index: Int) -> WalkthroughContentViewController? {
        if index < 0 || index >= pageHeadings.count {
            return nil
        }

        guard let pageController = storyboard?
            .instantiateViewControllerWithIdentifier ("WalkthroughContentViewController")
            as? WalkthroughContentViewController else { return nil }

        // 为相应视图控制器设置属性。
        pageController.imageFile = pageImages[index]
        pageController.heading   = pageHeadings[index]
        pageController.content   = pageContents[index]
        pageController.index     = index

        return pageController

    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughContentViewController).index
        index += 1

        return viewControllerAtIndex(index)
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughContentViewController).index
        index -= 1

        return viewControllerAtIndex(index)
    }

    // MARK: - Delegate Methods
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pageHeadings.count
    }

    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        guard let pageController = storyboard?.instantiateViewControllerWithIdentifier("WalkthroughContentViewController") as? WalkthroughContentViewController else {
            return 0
        }
        
        return pageController.index
    }
}
