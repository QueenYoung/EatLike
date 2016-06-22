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
    var friendData: DiscoverRestaurants!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = friendData.name
        detailImageView.image = friendData.detailImage
        userImageView.image = friendData.authorImage
        authorLabel.text = friendData.userName
        authorLabel.text?.append(" 👉 \(friendData.foodName)")
        navigationItem.title = friendData.name
        
        self.dackButton.alpha = 0.0
        self.descriptionTextView.alpha = 0.0
        print(NSDate().timeIntervalSince(startTime as Date))

        let imageSize = CGSize(width: 1, height: 1)
        self.navigationController?.navigationBar
            .setBackgroundImage(.withColor(color: .clear(), size: imageSize), for: .default)
        self.navigationController?.navigationBar.shadowImage = .withColor(color: .clear(), size: imageSize)


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
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    private func textViewWithFont(textView: UITextView, fontName: String, fontSize: CGFloat, lineSpacing: CGFloat) {
		
        let queue = DispatchQueue(label: "com.queen.jxau.eatlike", attributes: DispatchQueueAttributes.concurrent, target: nil)
        let font = UIFont(name: fontName, size: fontSize)
        queue.async {
            let text = self.friendData.note
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineSpacing
            
            let attributedString = NSMutableAttributedString(string: text)
            attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
            attributedString.addAttribute(NSFontAttributeName, value: font!, range: NSMakeRange(0, attributedString.length))

            DispatchQueue.main.async {
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

    @IBAction func swipeDownDismiss(sender: UISwipeGestureRecognizer) {
        let gravity = UIGravityBehavior(items: [self.view])
        gravity.gravityDirection = CGVector(dx: 0, dy: 10)
        let animator = UIDynamicAnimator(referenceView: view)
        switch sender.state {
        case .began:
            print("oo")
            break
        case .changed:
            print("aa")
           let location = sender.location(in: view)
           let frame = view.frame
           view.frame = CGRect(x: frame.origin.x, y: frame.origin.y + location.y, width: frame.width, height: frame.height)
        default:
            animator.addBehavior(gravity)
        }
    }
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}
