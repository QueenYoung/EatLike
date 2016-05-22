//
//  FriendRestaurantViewController.swift
//  EatLike
//
//  Created by Queen Y on 16/4/10.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit

class FriendRestaurantViewController: UIViewController {

    @IBOutlet var detailImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var dackButton: UIButton!

    var startTime: NSDate!
    var friendData: [DiscoverRestaurants] = []
    var index: Int!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = friendData[index].name
        detailImageView.image = friendData[index].detailImage
        userImageView.image = friendData[index].authorImage
        authorLabel.text = friendData[index].userName
        authorLabel.text?.appendContentsOf(" 🌚🌝 \(friendData[index].foodName)")

        self.dackButton.alpha = 0.0
        self.descriptionTextView.alpha = 0.0

        print(NSDate().timeIntervalSinceDate(startTime))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)

    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        delay(0.2) {
            self.dackButton.alpha = 1.0
            self.springScaleFrom(self.dackButton, x: -100, y: 0, scaleX: 0.5, scaleY: 0.5)
            spring(0.5) {
                self.textViewWithFont(self.descriptionTextView, fontName: "Georgia", fontSize: 16, lineSpacing: 6.0)
                self.descriptionTextView.alpha = 1.0
            }
        }
    }
    
    @IBAction func cancel(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func textViewWithFont(textView: UITextView, fontName: String, fontSize: CGFloat, lineSpacing: CGFloat) {
        let font = UIFont(name: fontName, size: fontSize)
        textView.text = friendData[index].note
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
    
    
    // fixme: 
    @IBAction func swipeDownToDismissView(sender: UISwipeGestureRecognizer) {
        UIView.animateWithDuration(0.2) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return navigationController?.topViewController
    }
    
}
