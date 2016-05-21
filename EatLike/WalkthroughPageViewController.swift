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

    let pageHeadings = ["重温", "发现", "享受"]
    let pageContents = [
        "使用 Eat Like 将你喜欢的每一份食物, 捕捉在这一刻",
        "重温路上的经过和那迷失的风景",
        "坐下来, 静静体会这一切的美好."
    ]

    let pageImages = [
        UIImage(named: "Rest"),
        UIImage(named: "Green"),
        UIImage(named: "caomei")
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

    @objc func turnToMain() {
        dismissViewControllerAnimated(true, completion: nil)
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
}
