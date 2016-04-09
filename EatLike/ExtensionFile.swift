//
//  ExtensionFile.swift
//  EatLike
//
//  Created by Queen Y on 16/4/9.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit
extension UIButton {
    func call(telphone: String, isAlert: Bool = true) -> UIAlertController? {
        let number = String(telphone.characters.filter { $0 != "-" })
        let url = NSURL(string: "tel://" + number)

        if isAlert {
            let alert = UIAlertController(
                title: "Call",
                message: "确定要拨打 \(number)?",
                preferredStyle: .ActionSheet)
            let callAction = UIAlertAction(title: "我要吃饭!", style: .Default) {
                _ in
                UIApplication.sharedApplication().openURL(url!)
            }

            alert.addAction(callAction)
            alert.addAction(UIAlertAction(title: "手残,按错", style: .Cancel, handler: nil))
            return alert
        }

        UIApplication.sharedApplication().openURL(url!)
        return nil
    }
}