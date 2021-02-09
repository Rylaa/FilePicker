//
//  ImagePickerController.swift
//
//
//  Created by Yusuf Demirkoparan on 29.04.2020.
//  
//

import UIKit
import Photos

fileprivate let localizedDone = Bundle(identifier: "com.apple.UIKit")?.localizedString(forKey: "Done", value: "Done", table: "") ?? "Done"

// MARK: ImagePickerController
@objcMembers open class ImagePickerController: UINavigationController {
    // MARK: Public properties
    public weak var imagePickerDelegate: ImagePickerControllerDelegate?
    public var settings: Settings = Settings()
    public var doneButton: UIBarButtonItem = UIBarButtonItem(title: localizedDone, style: .done, target: nil, action: nil)
    public var cancelButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
    public var albumButton: UIButton = UIButton(type: .custom)
    public var selectedAssets: [PHAsset] {
        get {
            return assetStore.assets
        }
    }

    // MARK: Internal properties
    var assetStore: AssetStore
    var onSelection: ((_ asset: PHAsset) -> Void)?
    var onDeselection: ((_ asset: PHAsset) -> Void)?
    var onCancel: ((_ assets: [PHAsset]) -> Void)?
    var onFinish: ((_ assets: [PHAsset]) -> Void)?
    
    let assetsViewController: AssetsViewController
    let albumsViewController = AlbumsViewController()
    let dropdownTransitionDelegate = DropdownTransitionDelegate()
    let zoomTransitionDelegate = ZoomTransitionDelegate()

    lazy var albums: [PHAssetCollection] = {
        // We don't want collections without assets.
        // I would like to do that with PHFetchOptions: fetchOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0")
        // But that doesn't work...
        // This seems suuuuuper ineffective...
        let fetchOptions = settings.fetch.assets.options.copy() as! PHFetchOptions
        fetchOptions.fetchLimit = 1

        return settings.fetch.album.fetchResults.filter {
            $0.count > 0
        }.flatMap {
            $0.objects(at: IndexSet(integersIn: 0..<$0.count))
        }.filter {
            // We can't use estimatedAssetCount on the collection
            // It returns NSNotFound. So actually fetch the assets...
            let assetsFetchResult = PHAsset.fetchAssets(in: $0, options: fetchOptions)
            return assetsFetchResult.count > 0
        }
    }()

    public init(selectedAssets: [PHAsset] = []) {
        assetStore = AssetStore(assets: selectedAssets)
        assetsViewController = AssetsViewController(store: assetStore)
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            // Disables iOS 13 swipe to dismiss - to force user to press cancel or done.
            isModalInPresentation = true
        }
        
        // Sync settings
        albumsViewController.settings = settings
        assetsViewController.settings = settings
        
        // Setup view controllers
        albumsViewController.delegate = self
        assetsViewController.delegate = self
        
        viewControllers = [assetsViewController]
        view.backgroundColor = settings.theme.backgroundColor
        delegate = zoomTransitionDelegate

        // Turn off translucency so drop down can match its color
        navigationBar.isTranslucent = false
        navigationBar.isOpaque = true
        
        // Setup buttons
        let firstViewController = viewControllers.first
        albumButton.setTitleColor(albumButton.tintColor, for: .normal)
        albumButton.titleLabel?.font = .systemFont(ofSize: 16)
        albumButton.titleLabel?.adjustsFontSizeToFitWidth = true

        let arrowView = ArrowView(frame: CGRect(x: 0, y: 0, width: 8, height: 8))
        arrowView.backgroundColor = .clear
        arrowView.strokeColor = albumButton.tintColor
        let image = arrowView.asImage

        albumButton.setImage(image, for: .normal)
        albumButton.semanticContentAttribute = .forceRightToLeft // To set image to the right without having to calculate insets/constraints.
        albumButton.addTarget(self, action: #selector(ImagePickerController.albumsButtonPressed(_:)), for: .touchUpInside)
        firstViewController?.navigationItem.titleView = albumButton

        doneButton.target = self
        doneButton.action = #selector(doneButtonPressed(_:))
        doneButton.setTitleTextAttributes(
            [NSAttributedString.Key.foregroundColor: UIColor.fadedBlue], for: .normal)
        firstViewController?.navigationItem.rightBarButtonItem = doneButton

        cancelButton.target = self
        cancelButton.action = #selector(cancelButtonPressed(_:))
        cancelButton.setTitleTextAttributes(
                   [NSAttributedString.Key.foregroundColor: UIColor.fadedBlue], for: .normal)
        firstViewController?.navigationItem.leftBarButtonItem = cancelButton
        
        updatedDoneButton()
        updateAlbumButton()

        // We need to have some color to be able to match with the drop down
        if navigationBar.barTintColor == nil {
            navigationBar.barTintColor = .white
        }

        if let firstAlbum = albums.first {
            select(album: firstAlbum)
        }
    }

    func updatedDoneButton() {
        doneButton.title = assetStore.count > 0 ? localizedDone + " (\(assetStore.count))" : localizedDone
        
        doneButton.isEnabled = assetStore.count >= settings.selection.min
    }

    func updateAlbumButton() {
        albumButton.isHidden = albums.count < 2
    }
}

extension ImagePickerController: AlbumsViewControllerDelegate {
    func didDismissAlbumsViewController(_ albumsViewController: AlbumsViewController) {
        rotateButtonArrow()
    }
    
    func albumsViewController(_ albumsViewController: AlbumsViewController, didSelectAlbum album: PHAssetCollection) {
        select(album: album)
        albumsViewController.dismiss(animated: true)
    }

    func select(album: PHAssetCollection) {
        assetsViewController.showAssets(in: album)
        albumButton.setTitle((album.localizedTitle ?? "") + " ", for: .normal)
        albumButton.sizeToFit()
    }
}

extension ImagePickerController: AssetsViewControllerDelegate {
    func assetsViewController(_ assetsViewController: AssetsViewController, didSelectAsset asset: PHAsset) {
        if settings.selection.unselectOnReachingMax && assetStore.count > settings.selection.max {
            if let first = assetStore.removeFirst() {
                assetsViewController.unselect(asset:first)
                imagePickerDelegate?.imagePicker(self, didDeselectAsset: first)
            }
        }
        updatedDoneButton()
       // imagePickerDelegate?.imagePicker(self, didSelectAsset: asset)
    }

    func assetsViewController(_ assetsViewController: AssetsViewController, didDeselectAsset asset: PHAsset) {
        updatedDoneButton()
        imagePickerDelegate?.imagePicker(self, didDeselectAsset: asset)
    }

    func assetsViewController(_ assetsViewController: AssetsViewController, didLongPressCell cell: AssetCollectionViewCell, displayingAsset asset: PHAsset) {
        let previewViewController = PreviewBuilder.createPreviewController(for: asset, with: settings)
        
        zoomTransitionDelegate.zoomedOutView = cell.imageView
        zoomTransitionDelegate.zoomedInView = previewViewController.imageView
        
        pushViewController(previewViewController, animated: true)
    }
}

extension ImagePickerController {
    @objc func albumsButtonPressed(_ sender: UIButton) {
        albumsViewController.albums = albums
        
        // Setup presentation controller
        albumsViewController.transitioningDelegate = dropdownTransitionDelegate
        albumsViewController.modalPresentationStyle = .custom
        rotateButtonArrow()
        
        present(albumsViewController, animated: true)
    }

    @objc func doneButtonPressed(_ sender: UIBarButtonItem) {
        imagePickerDelegate?.imagePicker(self, didFinishWithAssets: assetStore.assets)
        
        if settings.dismiss.enabled {
            dismiss(animated: true)
        }
    }

    @objc func cancelButtonPressed(_ sender: UIBarButtonItem) {
        imagePickerDelegate?.imagePicker(self, didCancelWithAssets: assetStore.assets)
        
        if settings.dismiss.enabled {
            dismiss(animated: true)
        }
    }
    
    func rotateButtonArrow() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let imageView = self?.albumButton.imageView else { return }
            imageView.transform = imageView.transform.rotated(by: .pi)
        }
    }
}


/// Delegate of the image picker
public protocol ImagePickerControllerDelegate: class {
    /// An asset was selected
    /// - Parameter imagePicker: The image picker that asset was selected in
    /// - Parameter asset: selected asset
    func imagePicker(_ imagePicker: ImagePickerController, didSelectAsset asset: PHAsset)

    /// An asset was deselected
    /// - Parameter imagePicker: The image picker that asset was deselected in
    /// - Parameter asset: deselected asset
    func imagePicker(_ imagePicker: ImagePickerController, didDeselectAsset asset: PHAsset)

    /// User finished with selecting assets
    /// - Parameter imagePicker: The image picker that assets where selected in
    /// - Parameter assets: Selected assets
    func imagePicker(_ imagePicker: ImagePickerController, didFinishWithAssets assets: [PHAsset])

    /// User canceled selecting assets
    /// - Parameter imagePicker: The image picker that asset was selected in
    /// - Parameter assets: Assets selected when user canceled
    func imagePicker(_ imagePicker: ImagePickerController, didCancelWithAssets assets: [PHAsset])

    /// Selection limit reach
    /// - Parameter imagePicker: The image picker that selection limit was reached in.
    /// - Parameter count: Number of selected assets.
    func imagePicker(_ imagePicker: ImagePickerController, didReachSelectionLimit count: Int)
}

extension ImagePickerController {
    public static var currentAuthorization : PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus()
    }
}

/// ImagePickerControllerDelegate closure wrapper
extension ImagePickerController: ImagePickerControllerDelegate {
    public func imagePicker(_ imagePicker: ImagePickerController, didSelectAsset asset: PHAsset) {
        onSelection?(asset)
    }

    public func imagePicker(_ imagePicker: ImagePickerController, didDeselectAsset asset: PHAsset) {
        onDeselection?(asset)
    }

    public func imagePicker(_ imagePicker: ImagePickerController, didFinishWithAssets assets: [PHAsset]) {
        onFinish?(assets)
    }

    public func imagePicker(_ imagePicker: ImagePickerController, didCancelWithAssets assets: [PHAsset]) {
        onCancel?(assets)
    }

    public func imagePicker(_ imagePicker: ImagePickerController, didReachSelectionLimit count: Int) {
        
    }
}
