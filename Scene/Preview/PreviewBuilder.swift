//
//  PreviewBuilder.swift
//  
//
//  Created by Yusuf Demirkoparan on 29.04.2020.
//
//

import Foundation
import Photos

class PreviewBuilder {
    static func createPreviewController(for asset: PHAsset, with settings: Settings) -> PreviewViewController {
        switch (asset.mediaType, asset.mediaSubtypes) {
        case (.video, _):
            let vc = VideoPreviewViewController()
            vc.settings = settings
            vc.asset = asset
            return vc
        case (.image, .photoLive):
            let vc = LivePreviewViewController()
            vc.settings = settings
            vc.asset = asset
            return vc
        default:
            let vc = PreviewViewController()
            vc.settings = settings
            vc.asset = asset
            return vc
        }
    }
}
