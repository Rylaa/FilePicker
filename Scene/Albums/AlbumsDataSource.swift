//
//  AlbumsDataSource.swift
//  GEO-Isbank
//
//  Created by Yusuf Demirkoparan on 29.04.2020.
//  Copyright © 2020 Remzi Solmaz. All rights reserved.
//

import UIKit
import Photos

/**
Implements the UITableViewDataSource protocol with a data source and cell factory
*/

final class AlbumsTableViewDataSource : NSObject, UITableViewDataSource {
    var settings: Settings!
    
    private let albums: [PHAssetCollection]
    private let scale: CGFloat
    private let imageManager = PHCachingImageManager.default()
    
    init(albums: [PHAssetCollection], scale: CGFloat = UIScreen.main.scale) {
        self.albums = albums
        self.scale = scale
        super.init()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return albums.count > 0 ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AlbumCell.identifier, for: indexPath) as! AlbumCell
        
        // Fetch album
        let album = albums[indexPath.row]
        
        // Title
        cell.albumTitleLabel.attributedText = titleForAlbum(album)

        let fetchOptions = settings.fetch.assets.options.copy() as! PHFetchOptions
        fetchOptions.fetchLimit = 1
        
        let imageSize = CGSize(width: 84, height: 84).resize(by: scale)
        let imageContentMode: PHImageContentMode = .aspectFill
        if let asset = PHAsset.fetchAssets(in: album, options: fetchOptions).firstObject {
            imageManager.requestImage(for: asset, targetSize: imageSize, contentMode: imageContentMode, options: settings.fetch.preview.photoOptions) { (image, _) in
                guard let image = image else { return }
                cell.albumImageView.image = image
            }
        }
        
        return cell
    }

    func registerCells(in tableView: UITableView) {
        tableView.register(AlbumCell.self, forCellReuseIdentifier: AlbumCell.identifier)
    }

    private func titleForAlbum(_ album: PHAssetCollection) -> NSAttributedString {
        let text = NSMutableAttributedString()

        text.append(NSAttributedString(string: album.localizedTitle ?? "", attributes: settings.theme.albumTitleAttributes))

        return text
    }
}
