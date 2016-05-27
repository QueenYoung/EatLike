//
//  DiscoverViewController.swift
//  EatLike
//
//  Created by Queen Y on 16/4/4.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit

class DiscoverViewController: UIViewController {
    @IBOutlet var backgroundBlurImage: UIImageView!
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var restaurantLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var likesTotalLabel: UILabel!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet var restaurantImageButton: UIButton!
    @IBOutlet weak var likesButton: UIButton!
    @IBOutlet weak var dialogView: UIView!

    var animator : UIDynamicAnimator!
    var attachmentBehavior : UIAttachmentBehavior!
    var gravityBehaviour : UIGravityBehavior!
    var snapBehavior : UISnapBehavior!
    var isAnimated = false

    private lazy var discovers = getData()

    var index = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        if isAnimated {
            dialogView.alpha = 0
        }

        configureView()
        getBlurView(backgroundBlurImage, style: .Dark)
        getBlurView(headerView, style: .Dark)
        animator = UIDynamicAnimator(referenceView: view)

        let imageSize = CGSize(width: 1, height: 1)
        self.navigationController?.navigationBar
            .setBackgroundImage(.withColor(.clearColor(), size: imageSize), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = .withColor(.clearColor(), size: imageSize)
        
        view.insertSubview(backgroundBlurImage, atIndex: 0)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.sharedApplication().statusBarStyle = .Default
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)

        // 来控制是否需要额外的动画.
        if isAnimated {
            animatedView()
            isAnimated = false
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "modalFriend" {
            let nav = segue.destinationViewController as! UINavigationController
            let friendVC = nav.topViewController as! FriendRestaurantViewController
            let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            dispatch_async(queue) {
                friendVC.startTime = NSDate()
                friendVC.friendData = self.discovers
                friendVC.index = self.index
            }
        }
    }


    // MARK: Action

    @IBAction func handlerPanGesture(sender: UIPanGestureRecognizer) {
        let myView = dialogView
        let location = sender.locationInView(view)
        let boxLocation = sender.locationInView(dialogView)

        if sender.state == .Began {
            if snapBehavior != nil {
                animator.removeBehavior(snapBehavior)
            }

            // 添加钟摆效果并且计算偏移量, 摆动终点就是手指停留的位置
            let centerOffset = UIOffsetMake(boxLocation.x - CGRectGetMidX(myView.bounds), boxLocation.y - CGRectGetMidY(myView.bounds));
            attachmentBehavior = UIAttachmentBehavior(item: myView, offsetFromCenter: centerOffset, attachedToAnchor: location)
            attachmentBehavior.frequency = 0.0

            animator.addBehavior(attachmentBehavior)
        }
        else if sender.state == .Changed {
            attachmentBehavior.anchorPoint = location
        }
        else if sender.state == .Ended {
            animator.removeBehavior(attachmentBehavior)

            let translation = sender.translationInView(view)
            // 如果是向下移动超过了 100 点, 就移除所有之前的行为, 附加重力效果
            // 并且开始刷新界面
            if translation.y > 100 {
                animator.removeAllBehaviors()

                // 添加重力效果
                let gravity = UIGravityBehavior(items: [dialogView])
                gravity.gravityDirection = CGVectorMake(0, 10)
                animator.addBehavior(gravity)

                // 使用线程刷新
                delay(0.2) {
                    self.refreshView()
                }
            } else {
                // otherwise 添加晃动动作
                snapBehavior = UISnapBehavior(item: myView, snapToPoint: view.center)
                animator.addBehavior(snapBehavior)
            }
        }
    }

    @IBAction func likeButtonDidPressed(sender: UIButton) {
        let currentRestaurant = discovers[index]
        let isLiked = currentRestaurant.isLike
        if isLiked {
            currentRestaurant.isLike = false
            currentRestaurant.likesTotal -= 1
            sender.tintColor = .blueColor()
        } else {
            currentRestaurant.isLike = true
            currentRestaurant.likesTotal += 1
            sender.tintColor = .redColor()
        }
        likesTotalLabel.text = "\(currentRestaurant.likesTotal)"
        // 如果换成结构体的话, 要记得保存会原来的结构, 毕竟是值类型
        // 但是我发现使用 class 的话加载更快.
        discovers[index] = currentRestaurant
    }

// MARK: - Helper Function

    private func refreshView() {
        index += 1
        if index == discovers.count {
            index = 0
        }

        animator.removeAllBehaviors()
        snapBehavior = UISnapBehavior(item: dialogView, snapToPoint: view.center)
        attachmentBehavior.anchorPoint = view.center

        dialogView.center = view.center
        isAnimated = true
        configureView()
        viewDidAppear(true)
    }

    private func animatedView() {
        let scale = CGAffineTransformMakeScale(0.5, 0.5)
        let translate = CGAffineTransformMakeTranslation(0, -200)
        dialogView.transform = CGAffineTransformConcat(scale, translate)
        spring(0.5, delay: 0.2) {
            self.dialogView.transform = CGAffineTransformIdentity
        }
    }

    private func configureView() {
        let restaurant = discovers[index]
        backgroundBlurImage.image = restaurant.detailImage
        userImageView.image = restaurant.authorImage
        restaurantImageButton.setImage(
            restaurant.detailImage, forState: .Normal)
        restaurantLabel.text = restaurant.name
        likesTotalLabel.text = "\(restaurant.likesTotal)"
        userNameLabel.text = restaurant.userName
        userNameLabel.text?.appendContentsOf(" | \(restaurant.foodName)")
        updateLikeButtonColor()
        dialogView.alpha = 1
    }

    private func updateLikeButtonColor() {
        if discovers[index].isLike {
            likesButton.tintColor = .redColor()
        } else {
            likesButton.tintColor = .blueColor()
        }
    }

}

