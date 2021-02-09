//
//  Settings.swift
//  GEO-Isbank
//
//  Created by Yusuf Demirkoparan on 29.04.2020.
//  Copyright © 2020 Remzi Solmaz. All rights reserved.
//

import UIKit
import Photos

@objcMembers public class Settings : NSObject {
    public static let shared = Settings()

    // Move all theme related stuff to UIAppearance
    public class Theme : NSObject {
        /// Main background color
        public lazy var backgroundColor: UIColor = .white
        
        /// What color to fill the circle with
        public lazy var selectionFillColor: UIColor = UIView().tintColor
        
        /// Color for the actual selection icon
        public lazy var selectionStrokeColor: UIColor = .white
        
        /// Shadow color for the circle
        public lazy var selectionShadowColor: UIColor = .black
        
        public enum SelectionStyle {
            case checked
            case numbered
        }
        
        /// The icon to display inside the selection oval
        public lazy var selectionStyle: SelectionStyle = .checked
        
        public lazy var previewTitleAttributes : [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        
        public lazy var previewSubtitleAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        
        public lazy var albumTitleAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18),
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
    }

    public class Selection : NSObject {
        /// Max number of selections allowed
        public lazy var max: Int = Int.max
        
        /// Min number of selections you have to make
        public lazy var min: Int = 1
        
        /// If it reaches the max limit, unselect the first selection, and allow the new selection
        public lazy var unselectOnReachingMax : Bool = false
    }

    public class List : NSObject {
        /// How much spacing between cells
        public lazy var spacing: CGFloat = 2
        
        /// How many cells per row
        public lazy var cellsPerRow: (_ verticalSize: UIUserInterfaceSizeClass, _ horizontalSize: UIUserInterfaceSizeClass) -> Int = {(verticalSize: UIUserInterfaceSizeClass, horizontalSize: UIUserInterfaceSizeClass) -> Int in
            switch (verticalSize, horizontalSize) {
            case (.compact, .regular): // iPhone5-6 portrait
                return 3
            case (.compact, .compact): // iPhone5-6 landscape
                return 5
            case (.regular, .regular): // iPad portrait/landscape
                return 7
            default:
                return 3
            }
        }
    }

    public class Preview : NSObject {
        /// Is preview enabled?
        public lazy var enabled: Bool = true
    }

    public class Fetch : NSObject {
        public class Album : NSObject {
            /// Fetch options for albums/collections
            public lazy var options: PHFetchOptions = {
                let fetchOptions = PHFetchOptions()
                return fetchOptions
            }()

            /// Fetch results for asset collections you want to present to the user
            /// Some other fetch results that you might wanna use:
            ///                PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumFavorites, options: options),
            ///                PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: options),
            ///                PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumSelfPortraits, options: options),
            ///                PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumPanoramas, options: options),
            ///                PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumVideos, options: options),
            public lazy var fetchResults: [PHFetchResult<PHAssetCollection>] = [
                PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: options),
            ]
        }

        public class Assets : NSObject {
            /// Fetch options for assets

            /// Simple wrapper around PHAssetMediaType to ensure we only expose the supported types.
            public enum MediaTypes {
                case image
                case video

                fileprivate var assetMediaType: PHAssetMediaType {
                    switch self {
                    case .image:
                        return .image
                    case .video:
                        return .video
                    }
                }
            }
            public lazy var supportedMediaTypes: Set<MediaTypes> = [.image]

            public lazy var options: PHFetchOptions = {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [
                    NSSortDescriptor(key: "creationDate", ascending: false)
                ]

                let rawMediaTypes = supportedMediaTypes.map { $0.assetMediaType.rawValue }
                let predicate = NSPredicate(format: "mediaType IN %@", rawMediaTypes)
                fetchOptions.predicate = predicate

                return fetchOptions
            }()
        }

        public class Preview : NSObject {
            public lazy var photoOptions: PHImageRequestOptions = {
                let options = PHImageRequestOptions()
                options.isNetworkAccessAllowed = true

                return options
            }()

            public lazy var livePhotoOptions: PHLivePhotoRequestOptions = {
                let options = PHLivePhotoRequestOptions()
                options.isNetworkAccessAllowed = true
                return options
            }()

            public lazy var videoOptions: PHVideoRequestOptions = {
                let options = PHVideoRequestOptions()
                options.isNetworkAccessAllowed = true
                return options
            }()
        }

        /// Album fetch settings
        public lazy var album = Album()
        
        /// Asset fetch settings
        public lazy var assets = Assets()

        /// Preview fetch settings
        public lazy var preview = Preview()
    }
    
    public class Dismiss : NSObject {
        /// Should the image picker dismiss when done/cancelled
        public lazy var enabled = true
    }

    /// Theme settings
    public lazy var theme = Theme()
    
    /// Selection settings
    public lazy var selection = Selection()
    
    /// List settings
    public lazy var list = List()
    
    /// Fetch settings
    public lazy var fetch = Fetch()
    
    /// Dismiss settings
    public lazy var dismiss = Dismiss()

    /// Preview options
    public lazy var preview = Preview()
}


@objcMembers public class AssetStore : NSObject {
    public private(set) var assets: [PHAsset]

    public init(assets: [PHAsset] = []) {
        self.assets = assets
    }

    public var count: Int {
        return assets.count
    }

    func contains(_ asset: PHAsset) -> Bool {
        return assets.contains(asset)
    }

    func append(_ asset: PHAsset) {
        guard contains(asset) == false else { return }
        assets.append(asset)
    }

    func remove(_ asset: PHAsset) {
        guard let index = assets.firstIndex(of: asset) else { return }
        assets.remove(at: index)
    }
    
    func removeFirst() -> PHAsset? {
        return assets.removeFirst()
    }

    func index(of asset: PHAsset) -> Int? {
        return assets.firstIndex(of: asset)
    }
}
