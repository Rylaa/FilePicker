//
//  AlbumsCell.swift
//
//
//  Created by Yusuf Demirkoparan on 29.04.2020.
//  
//

import Foundation

import UIKit

/**
Cell for photo albums in the albums drop down menu
*/
final class AlbumCell: UITableViewCell {
    static let identifier = "AlbumCell"

    let albumImageView: UIImageView = UIImageView(frame: .zero)
    let albumTitleLabel: UILabel = UILabel(frame: .zero)

    override var isSelected: Bool {
        didSet {
            // Selection checkmark
            if isSelected == true {
                accessoryType = .checkmark
            } else {
                accessoryType = .none
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
        selectionStyle = .none

        albumImageView.translatesAutoresizingMaskIntoConstraints = false
        albumImageView.contentMode = .scaleAspectFill
        albumImageView.clipsToBounds = true
        contentView.addSubview(albumImageView)
        
        albumTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        albumTitleLabel.numberOfLines = 0
        contentView.addSubview(albumTitleLabel)

        NSLayoutConstraint.activate([
            albumImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            albumImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            albumImageView.heightAnchor.constraint(equalToConstant: 84),
            albumImageView.widthAnchor.constraint(equalToConstant: 84),
            albumImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            albumTitleLabel.leadingAnchor.constraint(equalTo: albumImageView.trailingAnchor, constant: 8),
            albumTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            albumTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            albumTitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        albumImageView.image = nil
        albumTitleLabel.text = nil
    }
}
