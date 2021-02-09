//
//  DropdownAnimator.swift
//  GEO-Isbank
//
//  Created by Yusuf Demirkoparan on 29.04.2020.
//  Copyright © 2020 Remzi Solmaz. All rights reserved.
//

import Foundation
import UIKit

class DropdownAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    enum Context {
        case present
        case dismiss
    }
    
    private let context: Context
    
    init(context: Context) {
        self.context = context
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let isPresenting = context == .present
        let viewControllerKey: UITransitionContextViewControllerKey = isPresenting ? .to : .from
        
        guard let viewController = transitionContext.viewController(forKey: viewControllerKey) else { return }
        
        if isPresenting {
            transitionContext.containerView.addSubview(viewController.view)
        }
        
        let presentedFrame = transitionContext.finalFrame(for: viewController)
        let dismissedFrame = CGRect(x: presentedFrame.origin.x, y: presentedFrame.origin.y, width: presentedFrame.width, height: 0)
        
        let initialFrame = isPresenting ? dismissedFrame : presentedFrame
        let finalFrame = isPresenting ? presentedFrame : dismissedFrame
        
        let animationDuration = transitionDuration(using: transitionContext)
        viewController.view.frame = initialFrame
        UIView.animate(withDuration: animationDuration, animations: {
            viewController.view.frame = finalFrame
        }) { finished in
            transitionContext.completeTransition(finished)
        }
    }
}
