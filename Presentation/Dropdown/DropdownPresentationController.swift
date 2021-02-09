//
//  DropdownPresentationController.swift
// 
//
//  Created by Yusuf Demirkoparan on 29.04.2020.
//
//

import Foundation

import Foundation
import UIKit

class DropdownPresentationController: UIPresentationController {
    private let dropDownHeight: CGFloat = 200
    private let backgroundView = UIView()
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.backgroundColor = .clear
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(_:))))
    }
    
    @objc func backgroundTapped(_ recognizer: UIGestureRecognizer) {
        presentingViewController.dismiss(animated: true)
    }
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        
        containerView.insertSubview(backgroundView, at: 0)
        backgroundView.frame = containerView.bounds
    }
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: parentSize.width, height: dropDownHeight)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        
        let size = self.size(forChildContentContainer: presentedViewController,
                          withParentContainerSize: containerView.bounds.size)
        
        let position: CGPoint
        if let navigationBar = (presentingViewController as? UINavigationController)?.navigationBar {
            // We can't use the frame directly since iOS 13 new modal presentation style
            let navigationRect = navigationBar.convert(navigationBar.bounds, to: nil)
            position = CGPoint(x: 0, y: navigationRect.height + navigationRect.origin.y)

            // Match color with navigation bar
            presentedViewController.view.backgroundColor = navigationBar.barTintColor
        } else {
            position = .zero
        }
        
        return CGRect(origin: position, size: size)
    }
}
