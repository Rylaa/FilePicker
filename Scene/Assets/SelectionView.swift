//
//  SelectionView.swift
//  
//
//  Created by Yusuf Demirkoparan on 29.04.2020.
//
//

import Foundation

import UIKit

/**
Used as an overlay on selected cells
*/
class SelectionView: UIView {
    var settings: Settings!
    
    var selectionIndex: Int? {
        didSet {
            guard let numberView = icon as? NumberView, let selectionIndex = selectionIndex else { return }
            // Add 1 since selections should be 1-indexed
            numberView.text = (selectionIndex + 1).description
            setNeedsDisplay()
        }
    }
    
    private lazy var icon: UIView = {
        switch settings.theme.selectionStyle {
        case .checked:
            return CheckmarkView()
        case .numbered:
            return NumberView()
        }
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()
                
        //// Shadow Declarations
        let shadow2Offset = CGSize(width: 0.1, height: -0.1);
        let shadow2BlurRadius: CGFloat = 2.5;
        
        //// Frames
        let selectionFrame = bounds;
        
        //// Subframes
        let group = selectionFrame.insetBy(dx: 3, dy: 3)
        
        //// SelectedOval Drawing
        let selectedOvalPath = UIBezierPath(ovalIn: CGRect(x: group.minX + floor(group.width * 0.0 + 0.5), y: group.minY + floor(group.height * 0.0 + 0.5), width: floor(group.width * 1.0 + 0.5) - floor(group.width * 0.0 + 0.5), height: floor(group.height * 1.0 + 0.5) - floor(group.height * 0.0 + 0.5)))
        context?.saveGState()
        context?.setShadow(offset: shadow2Offset, blur: shadow2BlurRadius, color: settings.theme.selectionShadowColor.cgColor)
        settings.theme.selectionFillColor.setFill()
        selectedOvalPath.fill()
        context?.restoreGState()
        
        settings.theme.selectionStrokeColor.setStroke()
        selectedOvalPath.lineWidth = 1
        selectedOvalPath.stroke()
        
        //// Selection icon
        let largestSquareInCircleInsetRatio: CGFloat = 0.5 - (0.25 * sqrt(2))
        let dx = group.size.width * largestSquareInCircleInsetRatio
        let dy = group.size.height * largestSquareInCircleInsetRatio
        icon.frame = group.insetBy(dx: dx, dy: dy)
        icon.tintColor = settings.theme.selectionStrokeColor
        icon.draw(icon.frame)
    }
}
