import UIKit

// MARK:- Custom Segue

class FadeSegue: UIStoryboardSegue {

    override func perform() {
        destinationViewController.transitioningDelegate = self
        super.perform()
    }
}

extension FadeSegue: UIViewControllerTransitioningDelegate {
    func animationController(
        forPresentedController presented: UIViewController,
        presenting: UIViewController,
        sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let fade = FadeAnimator()
        fade.isPresenting = true
        return fade
    }

    func animationController(
        forDismissedController: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let fade = FadeAnimator()
        fade.isPresenting = false
        return fade
    }
}

// MARK: - Animator

class FadeAnimator:NSObject, UIViewControllerAnimatedTransitioning {

    var isPresenting = false

    func transitionDuration(_ transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }

    func animateTransition(_ transitionContext: UIViewControllerContextTransitioning) {

        // 1. Get the transition context to- view
        let fromView = transitionContext.view(forKey: UITransitionContextFromViewKey)
        let toView = transitionContext.view(forKey: UITransitionContextToViewKey)

        // 2. Add the to-view to the transition context
        // 3. Set up the initial state for the animation
        if isPresenting {
            toView?.alpha = 0.0
            if let toView = toView {
                transitionContext.containerView()?.addSubview(toView)
            }

        } else {
            if let fromView = fromView {
                if let toView = toView {
                    transitionContext.containerView()?.insertSubview(toView, belowSubview: fromView)
                }
                fromView.alpha = 1.0
            }
        }

        // 4. Perform the animation
        let duration = transitionDuration(transitionContext)

        UIView.animate(withDuration: duration, animations: {
            if self.isPresenting {
                if let toView = toView {
                    toView.alpha = 1.0
                }
                
            } else {
                if let fromView = fromView {
                    fromView.alpha = 0.0
                }
            }
            }, completion: {
                finished in
                // 5. Clean up the transition context
                transitionContext.completeTransition(true)
        })
    }
}
