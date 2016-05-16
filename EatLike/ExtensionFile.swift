//
//  ExtensionFile.swift
//  EatLike
//
//  Created by Queen Y on 16/4/9.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit
public func call(telphone: String, isAlert: Bool = true) -> UIAlertController? {
    guard !telphone.isEmpty else { return nil }
    let number = String(telphone.characters.filter { $0 != "-" })
    let url = NSURL(string: "tel://" + number)
    
    if isAlert {
        let alert = UIAlertController(
            title: "确定要拨打 \(number)",
            message: "请确定你不是无意识的点击",
            preferredStyle: .ActionSheet)
        let callAction = UIAlertAction(title: "我要吃饭!", style: .Destructive) {
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
    blurView.frame = view.frame
    // 将毛玻璃界面放在最后面.
    view.insertSubview(blurView, atIndex: 0)
}

public func spring(duration: NSTimeInterval, delay: NSTimeInterval = 0, animations: () -> Void) {
    UIView.animateWithDuration(
        duration,
        delay: 0,
        usingSpringWithDamping: 0.7,
        initialSpringVelocity: 0.7,
        options: [],
        animations: animations,
        completion: nil)
}


public func delay(delay: Double, closure: () -> Void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
}

extension UIImage {
    class func withColor(color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let ctx = UIGraphicsGetCurrentContext()
        color.setFill()
        CGContextFillRect(ctx, CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

public func configureAppearance() {
    let barColor = UIColor(red: 0xf7/255.0, green: 0x5b/255.0, blue: 0x61/255.0, alpha: 1.0)
    let navBarAppearance = UINavigationBar.appearance()
    navBarAppearance.translucent = true

    let imageSize = CGSize(width: 1, height: 1)
    let backgroundImage = UIImage.withColor(barColor, size: imageSize)
    navBarAppearance.setBackgroundImage(backgroundImage, forBarMetrics: .Default)
    navBarAppearance.tintColor = UIColor.whiteColor()
}