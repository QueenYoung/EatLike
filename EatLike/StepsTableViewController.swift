//
//  StepsTableViewController.swift
//  EatLike
//
//  Created by Queen Y on 16/4/25.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit
import MapKit
class StepsTableViewController: UITableViewController {

    var routeSteps = [MKRouteStep]()
    var count: Int {
        return routeSteps.count
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.estimatedRowHeight = self.tableView.rowHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return routeSteps.count / 5 + 1
    }

    override func tableView(tableView: UITableView,
                            titleForHeaderInSection section: Int) -> String? {
        return "\(section + 1)"
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let totalSections = numberOfSectionsInTableView(tableView)
        if section < totalSections - 1 {
            return 5
        } else {
            return routeSteps.count - 5 * section
        }
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StepCell", forIndexPath: indexPath)

        // Configure the cell...
        cell.textLabel?.text = routeSteps[indexPath.row].instructions
        return cell
    }

    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return nil
    }

}
