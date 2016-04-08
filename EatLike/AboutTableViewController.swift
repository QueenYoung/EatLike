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
    var mailCompose: MFMailComposeViewController!
    override func viewDidLoad() {
	    super.viewDidLoad()
	    // Uncomment the following line to preserve selection between presentations
	    // self.clearsSelectionOnViewWillAppear = false

	    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
	    tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        mailCompose = (UIApplication.sharedApplication().delegate as? AppDelegate)?.mailCompose
    }


    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0 where indexPath.row == 0:
            if let url = NSURL(string: "http://www.apple.com/itunes/charts/paid-apps/") {
                let safari = SFSafariViewController(URL: url, entersReaderIfAvailable: true)
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

    // 似乎因为 Apple 的问题, 使用虚拟机发送邮件就会异常.
    private func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            mailCompose.mailComposeDelegate = self
            mailCompose.setSubject("Feedback")
            mailCompose.setToRecipients(["c6swift@gmail.com"])
            let mailContent = "I am user of your App"
            mailCompose.setMessageBody(mailContent, isHTML: false)
            presentViewController(mailCompose, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Can't do this", message: "You hadn't set the mail account", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
            mailCompose = nil
        }


    }

    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {

        dismissViewControllerAnimated(true) {
            self.mailCompose = nil
            self.mailCompose = MFMailComposeViewController()
        }
    }
}
