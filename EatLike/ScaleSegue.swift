
import UIKit

class ScaleSegue: UIStoryboardSegue {

    override func perform() {
        destinationViewController.transitioningDelegate = self
        super.perform()
    }
}

extension ScaleSegue: UIViewControllerTransitioningDelegate {
    func animationController(
        forPresentedController presented: UIViewController,
        presenting: UIViewController,
        sourceController source: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {

        return ScalePresentAnimator()
    }

    func animationController(forDismissedController dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ScaleDismissAnimator()
    }
}

private protocol ViewScaleable {
    var scaleView:UIView { get }
}

class ScalePresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(_ transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    func animateTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        var fromViewController = transitionContext.viewController(forKey: UITransitionContextFromViewControllerKey)!
        if let fromNC = fromViewController as? UINavigationController {
            if let controller = fromNC.topViewController {
                fromViewController = controller
            }
        }
        let fromView = transitionContext.view(
            forKey: UITransitionContextFromViewKey)

        // 1. Get the transition context to- controller and view
        let toViewController = transitionContext.viewController(
            forKey: UITransitionContextToViewControllerKey)!
        let toView = transitionContext.view(forKey: UITransitionContextToViewKey)

        // 2. Add the to-view to the transition context
        if let toView = toView {
            transitionContext.containerView().addSubview(toView)
        }

        // 3. Set up the initial state for the animation
        var startFrame = CGRect.zero
        if let fromViewController = fromViewController as? ViewScaleable {
            startFrame = fromViewController.scaleView.frame
            startFrame.origin.y = 40
        } else {
            print("Warning: Controller \(fromViewController) does not conform to ViewScaleable")
        }
        toView?.frame = startFrame
        toView?.layoutIfNeeded()

        // 4. Perform the animation
        let duration = transitionDuration(transitionContext)
        let finalFrame = transitionContext.finalFrame(for: toViewController)

        UIView.animate(
            withDuration: duration, animations: {
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
    func transitionDuration(_ transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    func animateTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        let fromView = transitionContext.view(forKey: UITransitionContextFromViewKey)

        // Get the transition context to- controller and view
        var toViewController = transitionContext
            .viewController(forKey: UITransitionContextToViewControllerKey)!

        if let toNC = toViewController as? UINavigationController {
            if let controller = toNC.topViewController {
                toViewController = controller
            }
        }

        let toView = transitionContext.view(forKey: UITransitionContextToViewKey)

        // Add the to- view to the transition context
        if let fromView = fromView,
            toView = toView {
            transitionContext.containerView().insertSubview(toView, belowSubview:fromView)
        }

        // Set up the inital state for the animation
        toView?.alpha = 0.0

        // Work out the final frame for the animation
        var finalFrame = CGRect.zero
        if let toViewController = toViewController as? ViewScaleable {
            finalFrame = toViewController.scaleView.frame
            finalFrame.origin.y = 40
        } else {
            print("Warning: Controller \(toViewController) does not conform to ViewScaleable")
        }

        // Perform the animation
        let duration = transitionDuration(transitionContext)

        UIView.animate(
            withDuration: duration, animations: {
            fromView?.frame = finalFrame
            fromView?.layoutIfNeeded()
            toView?.alpha = 1.0
            }, completion: {
                finished in
                // Clean up the transition context
                transitionContext.completeTransition(true)
        })
    }
}

extension RestaurantDetailViewController: ViewScaleable {
    var scaleView: UIView {
        return restaurantImageView
    }
}

extension UITabBarController: ViewScaleable {
    var scaleView: UIView {
        let nvc = self.viewControllers!.first as! UINavigationController
        if let detailVC = nvc.topViewController as? RestaurantDetailViewController {
            return detailVC.scaleView
        } else {
            print("erjkl")
            return UIView(frame:
                CGRect(x: self.view.frame.origin.x,
                       y: self.view.frame.height / 4.0,
                       width: self.view.frame.width,
                       height: self.view.frame.height)
            )
        }
    }
}

extension DetailImageController: ViewScaleable {
    var scaleView: UIView {
        return imageView
    }
}

