//
//  AssetsCollectionViewCell.swift
//  GEO-Isbank
//
//  Created by Yusuf Demirkoparan on 29.04.2020.
//  Copyright © 2020 Remzi Solmaz. All rights reserved.
//

import UIKit
import Photos

/**
The photo cell.
*/
class AssetCollectionViewCell: UICollectionViewCell {
    let imageView: UIImageView = UIImageView(frame: .zero)
    var settings: Settings! {
        didSet { selectionView.settings = settings }
    }
    var selectionIndex: Int? {
        didSet { selectionView.selectionIndex = selectionIndex }
    }

    override var isSelected: Bool {
        didSet {
            guard oldValue != isSelected else { return }
            
            updateAccessibilityLabel(isSelected)
            if UIView.areAnimationsEnabled {
                UIView.animate(withDuration: TimeInterval(0.1), animations: { () -> Void in
                    // Set alpha for views
                    self.updateAlpha(self.isSelected)

                    // Scale all views down a little
                    self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                }, completion: { (finished: Bool) -> Void in
                    UIView.animate(withDuration: TimeInterval(0.1), animations: { () -> Void in
                        // And then scale them back upp again to give a bounce effect
                        self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    }, completion: nil)
                })
            } else {
                updateAlpha(isSelected)
            }
        }
    }
    
    private let selectionOverlayView: UIView = UIView(frame: .zero)
    private let selectionView: SelectionView = SelectionView(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)

        // Setup views
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        selectionOverlayView.backgroundColor = UIColor.lightGray
        selectionOverlayView.translatesAutoresizingMaskIntoConstraints = false
        selectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        contentView.addSubview(selectionOverlayView)
        contentView.addSubview(selectionView)

        // Add constraints
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            selectionOverlayView.topAnchor.constraint(equalTo: contentView.topAnchor),
            selectionOverlayView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            selectionOverlayView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            selectionOverlayView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            selectionView.heightAnchor.constraint(equalToConstant: 25),
            selectionView.widthAnchor.constraint(equalToConstant: 25),
            selectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            selectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])

        updateAlpha(isSelected)
        updateAccessibilityLabel(isSelected)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        selectionIndex = nil
    }
    
    func updateAccessibilityLabel(_ selected: Bool) {
        accessibilityLabel = selected ? "deselect image" : "select image"
    }
    
    private func updateAlpha(_ selected: Bool) {
        if selected {
            self.selectionView.alpha = 1.0
            self.selectionOverlayView.alpha = 0.3
        } else {
            self.selectionView.alpha = 0.0
            self.selectionOverlayView.alpha = 0.0
        }
    }
}
