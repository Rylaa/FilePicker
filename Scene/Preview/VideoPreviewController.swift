//
//  VideoPreviewController.swift
//  
//
//  Created by Yusuf Demirkoparan on 29.04.2020.
//
//

import Foundation
import AVFoundation
import Foundation
import os
import Photos
import UIKit

class VideoPreviewViewController: PreviewViewController {
    private let playerView = PlayerView()
    private var pauseBarButton: UIBarButtonItem!
    private var playBarButton: UIBarButtonItem!
    private let imageManager = PHCachingImageManager.default()
    
    enum State {
        case playing
        case paused
    }
    
    override var asset: PHAsset? {
        didSet {
            guard let asset = asset, asset.mediaType == .video else {
                player = nil
                return
            }
            
            imageManager.requestAVAsset(forVideo: asset, options: settings.fetch.preview.videoOptions) { (avasset, audioMix, arguments) in
                guard let avasset = avasset as? AVURLAsset else { return }
                
            DispatchQueue.main.async { [weak self] in
                    self?.player = AVPlayer(url: avasset.url)
                    self?.updateState(.playing, animated: false)
                }
            }
        }
    }
    
    private var player: AVPlayer? {
        didSet {
            guard let player = player else { return }
            playerView.player = player
            
            NotificationCenter.default.addObserver(self, selector: #selector(reachedEnd(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)

        pauseBarButton = UIBarButtonItem(barButtonSystemItem: .pause, target: self, action: #selector(pausePressed(sender:)))
        playBarButton = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(playPressed(sender:)))
        
        playerView.frame = view.bounds
        playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(playerView)

        scrollView.isUserInteractionEnabled = false
        doubleTapRecognizer.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        playerView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playerView.isHidden = false
        view.sendSubviewToBack(scrollView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateState(.paused, animated: false)
        playerView.isHidden = true
        
        NotificationCenter.default.removeObserver(self)
    }
    
    private func updateState(_ state: State, animated: Bool = true) {
        switch state {
        case .playing:
            navigationItem.setRightBarButton(pauseBarButton, animated: animated)
            player?.play()
        case .paused:
            navigationItem.setRightBarButton(playBarButton, animated: animated)
            player?.pause()
        }
    }
    
    // MARK: React to events
    @objc func playPressed(sender: UIBarButtonItem) {
        if player?.currentTime() == player?.currentItem?.duration {
            player?.seek(to: .zero)
        }

        updateState(.playing)
    }
    
    @objc func pausePressed(sender: UIBarButtonItem) {
        updateState(.paused)
    }
    
    @objc func reachedEnd(notification: Notification) {
        player?.seek(to: .zero)
        updateState(.paused)
    }
}
