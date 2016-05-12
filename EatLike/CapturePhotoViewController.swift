//
//  CapturePhotoViewController.swift
//  EatLike
//
//  Created by Queen Y on 16/4/29.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit

class CapturePhotoViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imageView.image = image
    }

    @IBAction func recapture(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
