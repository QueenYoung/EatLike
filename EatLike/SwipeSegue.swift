
import UIKit

class SwipeSegue: UIStoryboardSegue {

    override func perform() {
        destinationViewController.transitioningDelegate = self
        super.perform()
    }
}

extension SwipeSegue: UIViewControllerTransitioningDelegate {
    func animationController(
        forPresentedController presented: UIViewController,
        presenting: UIViewController,
                             sourceController source: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {

        // Challenge is only swipe to dismiss, so still scale up
        return ScalePresentAnimator()
    }

    func animationController(forDismissedController dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SwipeDismissAnimator()
    }
}

protocol ViewSwipeable {
    var swipeDirection: UISwipeGestureRecognizerDirection { get }
}

class SwipeDismissAnimator:NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(
        _ transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5

    }

    func animateTransition(_ transitionContext: UIViewControllerContextTransitioning) {

        // Get the views from the transition context
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextToViewControllerKey)!

        let fromView = transitionContext.view(forKey: UITransitionContextFromViewKey)
        let toView = transitionContext.view(forKey: UITransitionContextToViewKey)


        // Add the to- view to the transition context
        if let fromView = fromView {
            if let toView = toView {
                transitionContext.containerView()?.insertSubview(toView, belowSubview: fromView)
            }
        }

        // Work out the final frame for the animation
        var finalFrame = transitionContext.initialFrame(for: fromViewController)
        // Center final frame so it slides  vertically
        let toFinalFrame = transitionContext.finalFrame(for: toViewController)
        finalFrame.origin.x = toFinalFrame.width/2 - finalFrame.width/2

        if let fromViewController = fromViewController as? ViewSwipeable {
            let direction = fromViewController.swipeDirection
            switch direction {
            case UISwipeGestureRecognizerDirection.up:
                finalFrame.origin.y = -finalFrame.height
            case UISwipeGestureRecognizerDirection.down:
                finalFrame.origin.y = UIWindow().bounds.height
            default:()
            }
        } else {
            // Not Swipeable
            print("Warning: Controller \(fromViewController) does not conform to ViewSwipeable")
        }
        // Perform the animation
        let duration = transitionDuration(transitionContext)
        UIView.animate(withDuration: duration, animations: {
            fromView?.frame = finalFrame
            }, completion: {
                finished in
                // Clean up the transition context
                transitionContext.completeTransition(true)
        })
    }
}
