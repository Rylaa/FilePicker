//
//  Photos+Extensions.swift
//  Pasabahce
//
//  Created by Yusuf Demirkoparan on 9.02.2021.
//  Copyright © 2021 Softtech A.Ş. All rights reserved.
//

import Foundation
import UIKit
import Photos

extension CGSize {
    func resize(by scale: CGFloat) -> CGSize {
        return CGSize(width: self.width * scale, height: self.height * scale)
    }
}

extension PHAsset {
    func getAssetThumbnail(asset: PHAsset) -> Data? {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: 100.0, height: 100.0), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        let data = thumbnail.jpegData(compressionQuality: 1.0)
        return data
    }
}


extension URL {
    func urlToData() -> Data? {
        var data: Data?
        data = try? Data(contentsOf: self)
        return data
    }
    
}
