//
//  VideoCollectionViewCell.swift
//  GEO-Isbank
//
//  Created by Yusuf Demirkoparan on 29.04.2020.
//  Copyright © 2020 Remzi Solmaz. All rights reserved.
//

import Foundation

import UIKit

class VideoCollectionViewCell: AssetCollectionViewCell {
    let gradientView = GradientView(frame: .zero)
    let durationLabel = UILabel(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(gradientView)
        gradientView.colors = [.clear, .black]
        gradientView.locations = [0.0 , 0.7]
        
        NSLayoutConstraint.activate([
            gradientView.heightAnchor.constraint(equalToConstant: 30),
            gradientView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor)
        ])
        
        durationLabel.textAlignment = .right
        durationLabel.text = "0:03"
        durationLabel.textColor = .white
        durationLabel.font = UIFont.boldSystemFont(ofSize: 12)
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        gradientView.addSubview(durationLabel)
        
        NSLayoutConstraint.activate([
            durationLabel.topAnchor.constraint(greaterThanOrEqualTo: gradientView.topAnchor, constant: -4),
            durationLabel.bottomAnchor.constraint(equalTo: gradientView.bottomAnchor, constant: -4),
            durationLabel.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: -8),
            durationLabel.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor, constant: -8)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
