//
//  ScaleSegue.swift
//  EatLike
//
//  Created by Queen Y on 16/4/17.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit

class ScaleSegue: UIStoryboardSegue, UIViewControllerTransitioningDelegate {
    override func perform() {
        destinationViewController.transitioningDelegate = self
        super.perform()
    }

    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ScalePresentAnimator()
    }

//    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return ScaleDismissAnimator()
//    }
}

class ScalePresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        var fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        if let fromNC = fromViewController as? UINavigationController {
            if let controller = fromNC.topViewController {
                fromViewController = controller
            }
        }
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)

        // 1. Get the transition context to- controller and view
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)

        // 2. Add the to-view to the transition context
        if let toView = toView {
            transitionContext.containerView()?.addSubview(toView)
        }

        // 3. Set up the initial state for the animation
        var startFrame = CGRect.zero
        if let fromViewController = fromViewController as? ScaleImageable {
            startFrame = fromViewController.scaleView.frame
//            startFrame.origin.y -= fromViewController.scaleView.frame.height
        } else {
            print("Warning: Controller \(fromViewController) does not conform to ViewScaleable")
        }
        toView?.frame = startFrame
        toView?.layoutIfNeeded()

        // 4. Perform the animation
        let duration = transitionDuration(transitionContext)
        let finalFrame = transitionContext.finalFrameForViewController(toViewController)

        UIView.animateWithDuration(duration, animations: {
            toView?.frame = finalFrame
            toView?.layoutIfNeeded()
            fromView?.alpha = 0.0
            }, completion: {
                finished in
                fromView?.alpha = 1.0
                // 5. Clean up the transition context
                transitionContext.completeTransition(true)
        })
    }
}

class ScaleDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {


    }
}

protocol ScaleImageable {
    var scaleView: UIView { get }
}


