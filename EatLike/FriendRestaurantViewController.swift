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
        authorLabel.text?.append(" 👉 \(friendData[index].foodName)")
        
        self.dackButton.alpha = 0.0
        self.descriptionTextView.alpha = 0.0
        
        print(NSDate().timeIntervalSince(startTime))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        dackButton.alpha = 1.0
        springScaleFrom(view: self.dackButton, x: -100, y: 0, scaleX: 0.5, scaleY: 0.5)
        spring(duration: 0.5) {
            self.textViewWithFont(textView: self.descriptionTextView, fontName: "Georgia", fontSize: 16, lineSpacing: 6.0)
            self.descriptionTextView.alpha = 1.0
        }
    }
    
    @IBAction func cancel(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    private func textViewWithFont(textView: UITextView, fontName: String, fontSize: CGFloat, lineSpacing: CGFloat) {
        let queue = dispatch_queue_create("com.queen.jaxu.eatlike", DISPATCH_QUEUE_CONCURRENT)
        let font = UIFont(name: fontName, size: fontSize)
        dispatch_async(queue!) {
            let text = self.friendData[self.index].note
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineSpacing
            
            let attributedString = NSMutableAttributedString(string: text)
            attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
            attributedString.addAttribute(NSFontAttributeName, value: font!, range: NSMakeRange(0, attributedString.length))
            
            dispatch_async(dispatch_get_main_queue()) {
                textView.attributedText = attributedString
            }
        }
    }
    
    private func springScaleFrom (view: UIView, x: CGFloat, y: CGFloat, scaleX: CGFloat, scaleY: CGFloat) {
        let translation = CGAffineTransform(translationX: x, y: y)
        let scale = CGAffineTransform(scaleX: scaleX, y: scaleY)
        view.transform = translation.concat(scale)
        
        UIView.animate(
            withDuration: 0.7,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.7,
            options: [],
            animations: {
            view.transform = CGAffineTransform.identity
            }, completion: nil)
    }
    
    
    // fixme: 
    @IBAction func swipeDownToDismissView(sender: UISwipeGestureRecognizer) {
        UIView.animate(withDuration: 0.2) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
