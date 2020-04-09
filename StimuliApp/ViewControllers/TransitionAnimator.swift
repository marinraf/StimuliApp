//  TransitionAnimator.swift
//  CustomTransitionDemo
//
//  Created by Artur Rymarz on 01.08.2018.
//  Copyright © 2018 OpenSource. All rights reserved.

import UIKit

final class TransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let presenting: Bool

    init(presenting: Bool) {
        self.presenting = presenting
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(UINavigationController.hideShowBarDuration) * 1.5
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        guard let toView = transitionContext.view(forKey: .to) else { return }

        let duration = transitionDuration(using: transitionContext)

        let container = transitionContext.containerView
        if presenting {
            container.addSubview(toView)
        } else {
            container.insertSubview(toView, belowSubview: fromView)
        }

        let toViewFrame = toView.frame
        toView.frame = CGRect(x: presenting ? toView.frame.width : -toView.frame.width,
                              y: toView.frame.origin.y,
                              width: toView.frame.width,
                              height: toView.frame.height)

        let animations = {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1) {
                toView.frame = toViewFrame
                fromView.frame = CGRect(x: self.presenting ? -fromView.frame.width : fromView.frame.width,
                                        y: fromView.frame.origin.y,
                                        width: fromView.frame.width,
                                        height: fromView.frame.height)
            }

        }

        UIView.animateKeyframes(withDuration: duration,
                                delay: 0,
                                options: .calculationModeCubic,
                                animations: animations,
                                completion: { _ in
                                    container.addSubview(toView)
                                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
