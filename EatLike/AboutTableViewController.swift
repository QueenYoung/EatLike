//
//  AboutTableViewController.swift
//  EatLike
//
//  Created by Queen Y on 16/3/30.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit
import SafariServices
import MessageUI
class AboutTableViewController: UITableViewController,
                                MFMailComposeViewControllerDelegate {
    let links = ["http://user.qzone.qq.com/593969406/main/",
                 "https://github.com/QueenYoung/EatLike/"]

    var mailCompose = MFMailComposeViewController()
    override func viewDidLoad() {
	    super.viewDidLoad()
	    tableView.estimatedRowHeight = 64
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }


    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0 where indexPath.row == 0:
            if let url = NSURL(string: "http://www.apple.com/itunes/charts/paid-apps/") {
                let safari = SFSafariViewController(URL: url, entersReaderIfAvailable: false)
                presentViewController(safari, animated: true, completion: nil)
            }
        case 1 where indexPath.row != 2:
            if let url = NSURL(string: links[indexPath.row]) {
                let safariViewController = SFSafariViewController(URL: url, entersReaderIfAvailable: true)
                presentViewController(safariViewController, animated: true, completion: nil)
            }
        case 1:
            sendEmail()
        default:
            break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }

    // 似乎因为 Apple 的问题, 使用模拟器发送邮件就会异常.
    private func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            mailCompose.mailComposeDelegate = self
            mailCompose.setSubject("Feedback")
            mailCompose.setToRecipients(["c6swift@gmail.com"])
            let mailContent = "I am the user of your App"
            mailCompose.setMessageBody(mailContent, isHTML: false)
            presentViewController(mailCompose, animated: true, completion: nil)
        } else {
            // 否则出现一个警告框.
            let alert = UIAlertController(title: "Can't do this", message: "You hadn't set the mail account", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }


    }

    // 发送完邮件需要做的事情. 我们就是简单的 dismiss 就可以咯.
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {

        dismissViewControllerAnimated(true, completion: nil)
    }
}
