
import UIKit

// MARK:- Custom Segue

class DropSegue: UIStoryboardSegue {

  override func perform() {
    destinationViewController.transitioningDelegate = self
    super.perform()
  }
}

extension DropSegue: UIViewControllerTransitioningDelegate {
  func animationControllerForPresentedController(presented: UIViewController,
     presentingController presenting: UIViewController,
     sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return DropPresentAnimator()
  }
  
  func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return DropDismissAnimator()
  }
}

// MARK:- Animator

class DropPresentAnimator:NSObject, UIViewControllerAnimatedTransitioning {
  
  func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
    return 0.5
  }
  
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    
    // 1. Get the transition context to- view controller and view
    let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
    let toView = transitionContext.viewForKey(UITransitionContextToViewKey)

    // 2. Add the to-view to the transition context
    if let toView = toView {
      transitionContext.containerView()?.addSubview(toView)
    }

    // 3. Set up the initial state for the animation
    let finalFrame = transitionContext.finalFrameForViewController(toViewController)
    var startFrame = finalFrame
    startFrame.origin.y = -finalFrame.height
    
    toView?.frame = startFrame
    toView?.layoutIfNeeded()

    // 4. Perform the animation
    let duration = transitionDuration(transitionContext)
    
    UIView.animateWithDuration(duration, delay: 0.0,
      usingSpringWithDamping: 0.5, initialSpringVelocity: 2,
      options: [], animations: {
      if let toView = toView {
        toView.frame = finalFrame
      }
      }, completion: {
        finished in
        // 5. Clean up the transition context
        transitionContext.completeTransition(true)
    })
  }
}

class DropDismissAnimator:NSObject, UIViewControllerAnimatedTransitioning {
  
  func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
    return 0.5
  }
  
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    
    // 1. Get the transition context from- view controller and view
    let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
    let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)
    let toView = transitionContext.viewForKey(UITransitionContextToViewKey)
    
    // 2. Add the to-view to the transition context
    if let fromView = fromView {
      if let toView = toView {
        transitionContext.containerView()?.insertSubview(toView, belowSubview: fromView)
      }
    }
    
    // 3. Set up the initial state for the animation
    var finalFrame = transitionContext.finalFrameForViewController(fromViewController)
    finalFrame.origin.y = -finalFrame.height
    
    // 4. Perform the animation
    let duration = transitionDuration(transitionContext)
    UIView.animateWithDuration(duration, animations: {
      if let fromView = fromView {
        fromView.frame = finalFrame
        fromView.layoutIfNeeded()
      }
      }, completion: {
        finished in
        // 5. Clean up the transition context
        transitionContext.completeTransition(true)
    })
  }
}

