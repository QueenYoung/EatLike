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
        // Do any additional setup after loading the view.
        detailImageView.image = friendData.detailImage
        userImageView.image = friendData.authorImage
//        descriptionTextView.text = friendData.rating
        authorLabel.text = String(friendData.userName)
        authorLabel.text?.appendContentsOf(" | \(friendData.foodName)")
        textViewWithFont(descriptionTextView, fontName: "Georgia", fontSize: 16, lineSpacing: 6.0)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    private func textViewWithFont(textView: UITextView, fontName: String, fontSize: CGFloat, lineSpacing: CGFloat) {
        let font = UIFont(name: fontName, size: fontSize)
        let text = textView.text

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing

        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        attributedString.addAttribute(NSFontAttributeName, value: font!, range: NSMakeRange(0, attributedString.length))

        textView.attributedText = attributedString
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
