//
//  WalkthroughContentViewController.swift
//  EatLike
//
//  Created by Queen Y on 16/3/22.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit

class WalkthroughContentViewController: UIViewController {
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!

    var index     = 0
    var heading   = ""
    var imageFile: UIImage!
    var content   = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        headingLabel.text       = heading
        contentLabel.text       = content
        contentLabel.preferredMaxLayoutWidth = 150
        contentImageView.image  = imageFile
        pageControl.currentPage = index
        // Do any additional setup after loading the view.

        if (index == 2) {
            NSTimer.scheduledTimerWithTimeInterval(
                3,
                target: self,
                selector: #selector(doneButtonTapped),
                userInfo: nil,
                repeats: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func doneButtonTapped() {
        let save = NSUserDefaults.standardUserDefaults()
        save.setBool(true, forKey: "hasViewedWalkthrough")
        dismissViewControllerAnimated(true, completion: nil)
    }
   
}
