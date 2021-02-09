//
//  CheckMarkView.swift
//  GEO-Isbank
//
//  Created by Yusuf Demirkoparan on 29.04.2020.
//  Copyright © 2020 Remzi Solmaz. All rights reserved.
//

import Foundation
import UIKit

class CheckmarkView: UIView {
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 7, y: 12.5))
        path.addLine(to: CGPoint(x: 11, y: 16))
        path.addLine(to: CGPoint(x: 17.5, y: 9.5))
        
        path.stroke()
    }
}
