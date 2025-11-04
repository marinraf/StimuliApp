//  TransitionCoordinator.swift
//  CustomTransitionDemo
//
//  Created by Artur Rymarz on 01.08.2018.
//  Copyright © 2018 OpenSource. All rights reserved.

import UIKit

extension UINavigationController {

    private static var coordinatorHelperKey: UInt8 = 0

    var transitionCoordinatorHelper: TransitionCoordinator? {
        return objc_getAssociatedObject(self, UnsafeRawPointer(&UINavigationController.coordinatorHelperKey)) as? TransitionCoordinator
    }

    func addCustomTransitioning() {
        var object = objc_getAssociatedObject(self, UnsafeRawPointer(&UINavigationController.coordinatorHelperKey))

        guard object == nil else {
            return
        }

        object = TransitionCoordinator()
        let nonatomic = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
        objc_setAssociatedObject(self, UnsafeRawPointer(&UINavigationController.coordinatorHelperKey), object, nonatomic)

        delegate = object as? TransitionCoordinator

        let edgeSwipeGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self,
                                                                          action: #selector(handleSwipe(_:)))
        edgeSwipeGestureRecognizer.edges = .left
        view.addGestureRecognizer(edgeSwipeGestureRecognizer)
    }

    @objc func handleSwipe(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        guard let gestureRecognizerView = gestureRecognizer.view else {
            transitionCoordinatorHelper?.interactionController = nil
            return
        }

        guard !(self.viewControllers.last is DisplayViewController) else { return }
        guard !(self.viewControllers.last is DisplayPreviewViewController) else { return }

        let percent = gestureRecognizer.translation(in: gestureRecognizerView).x /
            gestureRecognizerView.bounds.size.width

        if gestureRecognizer.state == .began {
            transitionCoordinatorHelper?.interactionController = UIPercentDrivenInteractiveTransition()
            popViewController(animated: true)
        } else if gestureRecognizer.state == .changed {
            transitionCoordinatorHelper?.interactionController?.update(percent)
        } else if gestureRecognizer.state == .ended {
            if percent > 0.5 && gestureRecognizer.state != .cancelled {
                transitionCoordinatorHelper?.interactionController?.finish()
            } else {
                transitionCoordinatorHelper?.interactionController?.cancel()
            }
            transitionCoordinatorHelper?.interactionController = nil
        }
    }
}

final class TransitionCoordinator: NSObject, UINavigationControllerDelegate {
    var interactionController: UIPercentDrivenInteractiveTransition?

    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            return TransitionAnimator(presenting: true)
        case .pop:
            return TransitionAnimator(presenting: false)
        default:
            return nil
        }
    }

    func navigationController(_ navigationController: UINavigationController,
                              interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) ->
        UIViewControllerInteractiveTransitioning? {

            return interactionController
    }
}
