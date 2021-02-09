//
//  PlayerView.swift
//  GEO-Isbank
//
//  Created by Yusuf Demirkoparan on 29.04.2020.
//  Copyright © 2020 Remzi Solmaz. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class PlayerView: UIView {
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    override var layer: AVPlayerLayer {
        return super.layer as! AVPlayerLayer
    }
    
    var player: AVPlayer? {
        set {
            layer.player = newValue
        }
        get {
            return layer.player
        }
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.videoGravity = .resizeAspect
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.videoGravity = .resizeAspect
    }
}
