//
//  NumberView.swift
//  GEO-Isbank
//
//  Created by Yusuf Demirkoparan on 29.04.2020.
//  Copyright © 2020 Remzi Solmaz. All rights reserved.
//

import Foundation
import UIKit

class NumberView: UILabel {
    
    override var tintColor: UIColor! {
        didSet {
            textColor = tintColor
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)

        font = UIFont.boldSystemFont(ofSize: 12)
        numberOfLines = 1
        adjustsFontSizeToFitWidth = true
        baselineAdjustment = .alignCenters
        textAlignment = .center
    }
    
    override func draw(_ rect: CGRect) {
        super.drawText(in: rect)
    }
}
