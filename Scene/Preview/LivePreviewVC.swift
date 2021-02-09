//
//  LivePreviewVC.swift
// 
//
//  Created by Yusuf Demirkoparan on 29.04.2020.
//
//

import Foundation

import UIKit
import PhotosUI

class LivePreviewViewController: PreviewViewController {
    private let imageManager = PHCachingImageManager.default()
    private let livePhotoView = PHLivePhotoView()
    private let badgeView = UIImageView()

    override var asset: PHAsset? {
        didSet {
            guard let asset = asset else { return }

             // Load live photo for preview
            let targetSize = livePhotoView.frame.size.resize(by: UIScreen.main.scale)
            PHCachingImageManager.default().requestLivePhoto(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: settings.fetch.preview.livePhotoOptions) { [weak self] (livePhoto, _)  in
                guard let livePhoto = livePhoto else { return }
                self?.livePhotoView.livePhoto = livePhoto
                self?.positionBadgeView(for: livePhoto)
            }
        }
    }

    override var fullscreen: Bool {
        didSet {
            UIView.animate(withDuration: 0.3) {
                self.badgeView.alpha = self.fullscreen ? 0 : 1
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        livePhotoView.frame = scrollView.bounds
        livePhotoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        livePhotoView.contentMode = .scaleAspectFit
        scrollView.addSubview(livePhotoView)

        let badge = PHLivePhotoView.livePhotoBadgeImage(options: .overContent)
        badgeView.image = badge
        badgeView.sizeToFit()
        livePhotoView.addSubview(badgeView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        imageView.isHidden = true
    }

    override func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return livePhotoView
    }

    private func positionBadgeView(for livePhoto: PHLivePhoto?) {
        guard let livePhoto = livePhoto else {
            badgeView.frame.origin = .zero
            return
        }

        let imageFrame = ImageViewLayout.frameForImageWithSize(livePhoto.size, previousFrame: .zero, inContainerWithSize: livePhotoView.frame.size, usingContentMode: .scaleAspectFit)
        badgeView.frame.origin = imageFrame.origin
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        positionBadgeView(for: livePhotoView.livePhoto)
    }
}

extension LivePreviewViewController: PHLivePhotoViewDelegate {
    func livePhotoView(_ livePhotoView: PHLivePhotoView, willBeginPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        // Hide badge view if we aren't in fullscreen
        guard fullscreen == false else { return }
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.badgeView.alpha = 0
        }
    }

    func livePhotoView(_ livePhotoView: PHLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        // Show badge view if we aren't in fullscreen
        guard fullscreen == false else { return }
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.badgeView.alpha = 1
        }
    }
}
