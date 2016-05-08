//
//  FriendRestaurantViewController.swift
//  EatLike
//
//  Created by Queen Y on 16/4/10.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit

class FriendRestaurantViewController: UIViewController {

    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var dackButton: UIButton!

    var friendData: DiscoverRestaurants!

    override func viewDidLoad() {
        super.viewDidLoad()

        detailImageView.image = friendData.detailImage
        userImageView.image = friendData.authorImage

        authorLabel.text = String(friendData.userName)
        authorLabel.text?.appendContentsOf(" | \(friendData.foodName)")
        dackButton.alpha = 0.0
        descriptionTextView.alpha = 0.0

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)

        dackButton.alpha = 1.0
        springScaleFrom(dackButton, x: -100, y: 0, scaleX: 0.5, scaleY: 0.5)
        spring(0.4) {
            self.textViewWithFont(self.descriptionTextView, fontName: "Georgia", fontSize: 16, lineSpacing: 6.0)
            self.descriptionTextView.alpha = 1.0
        }
    }

    @IBAction func cancel(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    private func textViewWithFont(textView: UITextView, fontName: String, fontSize: CGFloat, lineSpacing: CGFloat) {
        let font = UIFont(name: fontName, size: fontSize)
        textView.text = friendData.note
        let text = textView.text

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing

        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        attributedString.addAttribute(NSFontAttributeName, value: font!, range: NSMakeRange(0, attributedString.length))

        textView.attributedText = attributedString
    }

    private func springScaleFrom (view: UIView, x: CGFloat, y: CGFloat, scaleX: CGFloat, scaleY: CGFloat) {
        let translation = CGAffineTransformMakeTranslation(x, y)
        let scale = CGAffineTransformMakeScale(scaleX, scaleY)
        view.transform = CGAffineTransformConcat(translation, scale)

        UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [], animations: {
            view.transform = CGAffineTransformIdentity
            }, completion: nil)
    }


    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
