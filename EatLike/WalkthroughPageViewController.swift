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
        if let startingViewController = getViewController(at: 0) {
            setViewControllers([startingViewController], direction: .forward, animated: true, completion: nil)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



    // MARK: - PageView Datasouce Methods
    private func getViewController(at index: Int) -> WalkthroughContentViewController? {
        if index < 0 || index >= pageHeadings.count {
            return nil
        }


        guard let pageController = storyboard?
            .instantiateViewController(withIdentifier: "WalkthroughContentViewController")
            as? WalkthroughContentViewController else { return nil }

        // 为相应视图控制器设置属性。
        pageController.imageFile = pageImages[index]
        pageController.heading   = pageHeadings[index]
        pageController.content   = pageContents[index]
        pageController.index     = index

        return pageController

    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughContentViewController).index
        index += 1

        // 如果当前是最后一个引导图, 加 1 后就是 3
        if index == 3 {
            delay(with: 1.5, closure: {
                self.doneButtonTapped()
            })
        }

        return getViewController(at: index)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughContentViewController).index
        index -= 1

        return getViewController(at: index)
    }

    // MARK: - Delegate Methods
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pageHeadings.count
    }

    func doneButtonTapped() {
        let save = UserDefaults.standard()
        save.set(true, forKey: "hasViewedWalkthrough")
        dismiss(animated: true, completion: nil)
    }
}
