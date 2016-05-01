//
//  ExtensionFile.swift
//  EatLike
//
//  Created by Queen Y on 16/4/9.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit

public func call(telphone: String, isAlert: Bool = true) -> UIAlertController? {
    let number = String(telphone.characters.filter { $0 != "-" })
    let url = NSURL(string: "tel://" + number)
    
    if isAlert {
        let alert = UIAlertController(
            title: "确定要拨打 \(number)",
            message: "请确定你不是无意识的点击",
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


public func getBlurView(view: UIView, style: UIBlurEffectStyle) {
    view.backgroundColor = .clearColor()

    let blurEffect = UIBlurEffect(style: style)
    let blurView = UIVisualEffectView(effect: blurEffect)
    blurView.frame = view.bounds
    view.insertSubview(blurView, atIndex: 0)
}

