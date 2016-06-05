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
        getBlur(in: backgroundBlurImage, style: .dark)
        getBlur(in: headerView, style: .dark)
        animator = UIDynamicAnimator(referenceView: view)

        let imageSize = CGSize(width: 1, height: 1)
        self.navigationController?.navigationBar
            .setBackgroundImage(.withColor(color: .clear(), size: imageSize), for: .default)
        self.navigationController?.navigationBar.shadowImage = .withColor(color: .clear(), size: imageSize)
        
        view.insertSubview(backgroundBlurImage, at: 0)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        UIApplication.shared().statusBarStyle = .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.shared().statusBarStyle = .default
    }

    override func viewDidAppear(_ animated: Bool) {
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

    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "modalFriend" {
            let nav = segue.destinationViewController as! UINavigationController
            let friendVC = nav.topViewController as! FriendRestaurantViewController

            friendVC.startTime = NSDate()
            friendVC.friendData = self.discovers
            friendVC.index = self.index
        }
    }
    
    
    // MARK: Action
    
    @IBAction func handlerPanGesture(sender: UIPanGestureRecognizer) {
        let myView = dialogView
        let location = sender.location(in: view)
        let boxLocation = sender.location(in: dialogView)
        
        if sender.state == .began {
            if snapBehavior != nil {
                animator.removeBehavior(snapBehavior)
            }
            
            // 添加钟摆效果并且计算偏移量, 摆动终点就是手指停留的位置
            let centerOffset = UIOffsetMake(
                boxLocation.x - myView.bounds.midX,
                boxLocation.y - myView.bounds.midY
            )
            attachmentBehavior = UIAttachmentBehavior(item: myView, offsetFromCenter: centerOffset, attachedToAnchor: location)
            attachmentBehavior.frequency = 0.0
            
            animator.addBehavior(attachmentBehavior)
        }
        else if sender.state == .changed {
            attachmentBehavior.anchorPoint = location
        }
        else if sender.state == .ended {
            animator.removeBehavior(attachmentBehavior)
            
            let translation = sender.translation(in: view)
            // 如果是向下移动超过了 100 点, 就移除所有之前的行为, 附加重力效果
            // 并且开始刷新界面
            if translation.y > 100 {
                animator.removeAllBehaviors()
                
                // 添加重力效果
                let gravity = UIGravityBehavior(items: [dialogView])
                gravity.gravityDirection = CGVector(dx: 0, dy: 10)
                animator.addBehavior(gravity)
                
                // 使用线程刷新
                delay(with: 0.2) { self.refreshView() }
            } else {
                // otherwise 添加晃动动作
                snapBehavior = UISnapBehavior(item: myView, snapTo: view.center)
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
            sender.tintColor = .blue()
        } else {
            currentRestaurant.isLike = true
            currentRestaurant.likesTotal += 1
            sender.tintColor = .red()
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
        snapBehavior = UISnapBehavior(item: dialogView, snapTo: view.center)
        attachmentBehavior.anchorPoint = view.center
        
        dialogView.center = view.center
        isAnimated = true
        configureView()
        viewDidAppear(true)
    }
    
    private func animatedView() {
        let scale = CGAffineTransform(scaleX: 0.5, y: 0.5)
        let translate = CGAffineTransform(translationX: 0, y: -200)
        dialogView.transform = scale.concat(translate)
        spring(duration: 0.5, delay: 0.2) {
            self.dialogView.transform = CGAffineTransform.identity
        }
    }
    
    private func configureView() {
        let restaurant = discovers[index]
        backgroundBlurImage.image = restaurant.detailImage
        userImageView.image = restaurant.authorImage
        restaurantImageButton.setImage(
            restaurant.detailImage, for: [])
        restaurantLabel.text = restaurant.name
        likesTotalLabel.text = "\(restaurant.likesTotal)"
        userNameLabel.text = restaurant.userName
        userNameLabel.text?.append(" | \(restaurant.foodName)")
        updateLikeButtonColor()
        dialogView.alpha = 1
    }
    
    private func updateLikeButtonColor() {
        if discovers[index].isLike {
            likesButton.tintColor = .red()
        } else {
            likesButton.tintColor = .blue()
        }
    }
    
}

