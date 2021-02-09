//
//  GradientView.swift
//  GEO-Isbank
//
//  Created by Yusuf Demirkoparan on 29.04.2020.
//  Copyright © 2020 Remzi Solmaz. All rights reserved.
//

import Foundation
import UIKit

class GradientView: UIView {
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override var layer: CAGradientLayer {
        return super.layer as! CAGradientLayer
    }
    
    var colors: [UIColor]? {
        get {
            let layerColors = layer.colors as? [CGColor]
            return layerColors?.map { UIColor(cgColor: $0) }
        } set {
            layer.colors = newValue?.map { $0.cgColor }
        }
    }
    
    open var locations: [NSNumber]? {
        get {
            return layer.locations
        } set {
            layer.locations = newValue
        }
    }
}
