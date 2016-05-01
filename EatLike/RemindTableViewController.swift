//
//  RemindTableViewController.swift
//  EatLike
//
//  Created by Queen Y on 16/5/1.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit

class RemindTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var needRemainedSwitch: UISwitch!
    @IBOutlet var datePickerCell: UITableViewCell!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateLabel: UILabel!
    var restaurant: Restaurant!

    var isPickerVisual = false
    var needRemind: Bool {
        get {
            return restaurant.needRemind.boolValue
        }

        set {
            restaurant.needRemind = newValue
        }
        
    }
    var dueDate: NSDate {
        get {
            return restaurant.dueDate
        }
        set {
            restaurant.dueDate = newValue
        }
    }

    lazy var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.timeZone = NSTimeZone.defaultTimeZone()
        formatter.timeStyle = .ShortStyle
        formatter.dateStyle = .ShortStyle
        return formatter
    }()

    lazy var notificationSettings: UIUserNotificationSettings = {
        let category = UIMutableUserNotificationCategory()
        category.identifier = "com.jxau.queen"

        let notificationAction = UIMutableUserNotificationAction()
        notificationAction.identifier = "Justsaveworld"
        notificationAction.title = "Save World"
        notificationAction.activationMode = .Background
        notificationAction.authenticationRequired = false
        notificationAction.destructive = true

        category.setActions([notificationAction], forContext: .Default)
        category.setActions([notificationAction], forContext: .Minimal)

        var ns = Set<UIMutableUserNotificationCategory>(arrayLiteral: category)

        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Sound, .Badge], categories: ns)

        return notificationSettings
    }()

    @IBAction func dateValueChanged(sender: UIDatePicker) {
        dueDate = sender.date
        dateLabel.text = dateFormatter.stringFromDate(dueDate)
    }

    @IBAction func remindToggled(sender: UISwitch) {
        messageField.resignFirstResponder()

        if sender.on {
            UIApplication.sharedApplication()
                .registerUserNotificationSettings(notificationSettings)
        }
        needRemind = sender.on
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 让日期选取器的最小时间为当前时间, 不能往前调
        datePicker.minimumDate = NSDate()
        datePicker.date = dueDate
        dateLabel.text = dateFormatter.stringFromDate(dueDate)
        if !restaurant.alertMessage.isEmpty {
            messageField.text = restaurant.alertMessage
        } else {
            navigationItem.rightBarButtonItem?.enabled = false
        }

        needRemainedSwitch.on = restaurant.needRemind.boolValue
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 && isPickerVisual {
            return 3
        } else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 2 && indexPath.section == 1 {
            return datePickerCell
        } else {
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
    }

    // MARK: - Table Delegate
    // 只有点击了第一节第一行, 才会有选中动作
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 1 && indexPath.row == 1 {
            return indexPath
        } else {
            return nil
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        messageField.resignFirstResponder()

        if !isPickerVisual {
            showDatePicker()
        } else {
            hideDatePicker()
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 2 {
            return 217.0
        } else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }


    private func showDatePicker() {
        isPickerVisual = true
        let indexPath = NSIndexPath(forRow: 2, inSection: 1)
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        datePicker.setDate(dueDate, animated: true)
    }

    private func hideDatePicker() {
        isPickerVisual = false
        let indexPath = NSIndexPath(forRow: 2, inSection: 1)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }

    override func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        var newIndexPath = indexPath
        if indexPath.section == 1 && indexPath.row == 2 {
            newIndexPath = NSIndexPath(forRow: 0, inSection: 1)
        }

        return super.tableView(tableView, indentationLevelForRowAtIndexPath: newIndexPath)
    }

    // MARK: - TextFiled Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }

    func textFieldDidEndEditing(textField: UITextField) {
        if !textField.text!.isEmpty {
            navigationItem.rightBarButtonItem?.enabled = true
        }
        restaurant.alertMessage = textField.text!
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        navigationItem.rightBarButtonItem?.enabled = false
        if isPickerVisual {
            hideDatePicker()
        }
    }
}
