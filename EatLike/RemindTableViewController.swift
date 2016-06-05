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
        formatter.timeZone = NSTimeZone.default()
        formatter.timeStyle = .shortStyle
        formatter.dateStyle = .shortStyle
        return formatter
    }()

    // configufe notification setting
    lazy var notificationSettings: UIUserNotificationSettings = {
        let category = UIMutableUserNotificationCategory()
        category.identifier = "com.jxau.queen"

        let notificationAction = UIMutableUserNotificationAction()
        notificationAction.identifier = "Justsaveworld"
        notificationAction.title = "Save World"
        notificationAction.activationMode = .background
        notificationAction.isAuthenticationRequired = false
        notificationAction.isDestructive = true

        category.setActions([notificationAction], for: .default)
        category.setActions([notificationAction], for: .minimal)

        var ns = Set<UIMutableUserNotificationCategory>(arrayLiteral: category)

        let notificationSettings = UIUserNotificationSettings   (forTypes: [.alert, .sound, .badge], categories: ns)

        return notificationSettings
    }()


    @IBAction func dateValueChanged(sender: UIDatePicker) {
        dueDate = sender.date
        dateLabel.text = dateFormatter.string(from: dueDate)
    }

    // 在将开关关闭的时候, 单元格的背景色发生变化
    // 给用户提供更强列的提示
    private func turnCellStatus(_ cell: UITableViewCell, enable: Bool) {
        if enable {
            cell.backgroundColor = .white()
            cell.textLabel?.textColor = .black()
            cell.isUserInteractionEnabled = true
        } else {
            cell.isUserInteractionEnabled = false
            cell.backgroundColor = .clear()
            cell.textLabel?.textColor = cell.detailTextLabel?.textColor
        }
    }

    @IBAction func remindToggled(sender: UISwitch) {
        messageField.resignFirstResponder()
        let indexPath = NSIndexPath(forRow: 1, inSection: 1)
        let cell = tableView.cellForRow(at: indexPath)!
        if sender.isOn {
            UIApplication.shared()
                .register(notificationSettings)
        } else {
            if isPickerVisual {
                hideDatePicker()
            }
        }
        self.turnCellStatus(cell, enable: sender.isOn)
        needRemind = sender.isOn
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        // 让日期选取器的最小时间为当前时间, 不能往前调
        datePicker.minimumDate = NSDate()
        datePicker.date = dueDate
        dateLabel.text = dateFormatter.string(from: dueDate)
        // 如果提醒信息不是空的, 就赋给 messageField
        if !restaurant.alertMessage.isEmpty {
            messageField.text = restaurant.alertMessage
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }

        needRemainedSwitch.isOn = restaurant.needRemind.boolValue
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(
        _ tableView: UITableView, willDisplay
        cell: UITableViewCell,
        forRowAt indexPath: NSIndexPath) {

        if indexPath.section == 1 && indexPath.row == 1 {
            turnCellStatus(cell, enable: needRemind)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 && isPickerVisual {
            return 3
        } else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 2 && indexPath.section == 1 {
            return datePickerCell
        } else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }

    // MARK: - Table Delegate
    // 只有点击了第一节第一行, 才会有选中动作
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 1 && indexPath.row == 1 {
            return indexPath
        } else {
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: NSIndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        messageField.resignFirstResponder()

        if !isPickerVisual {
            showDatePicker()
        } else {
            hideDatePicker()
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: NSIndexPath) -> CGFloat {
        // 之前没使用这一步的话
        if indexPath.section == 1 && indexPath.row == 2 {
            return 217.0
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }


    private func showDatePicker() {
        isPickerVisual = true
        let indexPath = NSIndexPath(forRow: 2, inSection: 1)
        tableView.insertRows(at: [indexPath], with: .automatic)
        datePicker.setDate(dueDate, animated: true)
    }

    private func hideDatePicker() {
        isPickerVisual = false
        let indexPath = NSIndexPath(forRow: 2, inSection: 1)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }

    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: NSIndexPath) -> Int {
        var newIndexPath = indexPath
        if indexPath.section == 1 && indexPath.row == 2 {
            newIndexPath = NSIndexPath(forRow: 0, inSection: 1)
        }

        return super.tableView(tableView, indentationLevelForRowAt: newIndexPath)
    }

    // MARK: - TextFiled Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if !textField.text!.isEmpty {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
        restaurant.alertMessage = textField.text!
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        navigationItem.rightBarButtonItem?.isEnabled = false
        if isPickerVisual {
            hideDatePicker()
        }
    }
}
