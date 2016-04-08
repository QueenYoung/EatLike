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
    @IBOutlet weak var doneButton: UIButton!

    var index     = 0
    var heading   = ""
    var imageFile = ""
    var content   = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        headingLabel.text       = heading
        contentLabel.text       = content
        contentImageView.image  = UIImage(named: imageFile)
        pageControl.currentPage = index
        // Do any additional setup after loading the view.

        if index >= 0 && index <= 1 {
            doneButton.hidden = true
        } else if index == 2 {
            doneButton.hidden = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func doneButtonTapped(sender: UIButton) {
        let save = NSUserDefaults.standardUserDefaults()
        save.setBool(true, forKey: "hasViewedWalkthrough")
        dismissViewControllerAnimated(true, completion: nil)
    }
   
}
