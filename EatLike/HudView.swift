//
//  HudView.swift
//  EatLike
//
//  Created by Queen Y on 16/5/31.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit

class HudView: UIView {

    var text = ""

    class func hud(in view: UIView, animated: Bool) -> HudView {
        let hudview = HudView(frame: view.bounds)
        hudview.isOpaque = false

        view.addSubview(hudview)
        view.isUserInteractionEnabled = false

        view.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
        if animated {
            hudview.showAnimated()
        }
        return hudview
    }

    override func draw(_ rect: CGRect) {
        let boxWidth: CGFloat = 96.0
        let boxHeight: CGFloat = 96.0

        let boxRect = CGRect(
            x: round((bounds.size.width - boxWidth) / 2),
            y: round((bounds.size.height - boxHeight) / 2),
            width: boxWidth,
            height: boxHeight
        )

        let roundRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        UIColor(white: 0.3, alpha: 0.6).setFill()
        roundRect.fill()

        // add image
        if let image = UIImage(named: "Checkmark") {
            let imagePoint = CGPoint(
                x: center.x - round(image.size.width / 2),
                y: center.y - round(image.size.height / 2) - boxHeight / 8
            )

            image.draw(at: imagePoint)
        }

        // add text
        let attribs = [NSFontAttributeName: UIFont.systemFont(ofSize: 16),
                       NSForegroundColorAttributeName: UIColor.white()]
        let textSize = text.size(attributes: attribs)

        let textPoint = CGPoint(
            x: center.x - round(textSize.width / 2),
            y: center.y - round(textSize.height / 2) + boxHeight / 4
        )

        (text as NSString).draw(at: textPoint, withAttributes: attribs)
    }

    func showAnimated() {
        alpha = 0.0
        transform = CGAffineTransform(scaleX: 1.5, y: 1.5)

        UIView.animate(
            withDuration: 0.4,
            delay: 0.0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 5.0,
            options: [],
            animations: {
            self.alpha = 1.0
            self.transform = CGAffineTransform.identity
            }, completion: nil
        )
    }
}
