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

    override func tableView(
        _ tableView: UITableView, didSelectRowAt indexPath: NSIndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        choosedCategary = cell.textLabel?.text
        performSegue(withIdentifier: "UnwindCategary", sender: self)
    }

    @IBAction func done(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
  }
