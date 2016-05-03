//
//  ChooseCategaryTableViewController.swift
//  EatLike
//
//  Created by Queen Y on 16/5/3.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit

class ChooseCategaryTableViewController: UITableViewController {

    var choosedCategary: String!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        choosedCategary = cell.textLabel?.text
        performSegueWithIdentifier("UnwindCategary", sender: self)
    }

    @IBAction func done(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
  }
