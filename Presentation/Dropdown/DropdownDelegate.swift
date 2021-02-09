//
//  DropdownDelegate.swift
//  
//
//  Created by Yusuf Demirkoparan on 29.04.2020.
//
//

import Foundation
import UIKit

class DropdownTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return DropdownPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DropdownAnimator(context: .present)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DropdownAnimator(context: .dismiss)
    }
}
