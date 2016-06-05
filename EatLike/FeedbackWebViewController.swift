//
//  FeedbackWebViewController.swift
//  EatLike
//
//  Created by Queen Y on 16/3/30.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit

class FeedbackWebViewController: UIViewController {
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // 因为 `iOS 9` 的安全特性, 要求所有的 HTTP 访问必须更加安全
        // 需要前往 info 文件添加一个 App Transport Security 字典,
        // 并设置 Allow Arbitrary Loads to `YES`
        if let url = NSURL(string: "https://www.icloud.com/#mail/") {
            let request = NSURLRequest(url: url)
            webView.loadRequest(request)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
