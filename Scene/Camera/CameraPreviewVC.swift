//
//  CameraPreviewVC.swift
// 
//
//  Created by Yusuf Demirkoparan on 29.04.2020.
//


import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    private let captureSession = AVCaptureSession()
    private let previewView = CameraPreviewView()
    private let captureSessionQueue = DispatchQueue(label: "session queue")

    override func viewDidLoad() {
        super.viewDidLoad()

        previewView.session = captureSession
        previewView.frame = view.bounds
        previewView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(previewView)
        
        requestAuthorization()
        setupSession()
    }

    private func requestAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
        case .notDetermined:
            captureSessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { [weak self] granted in
                if granted {
                    self?.captureSessionQueue.resume()
                } else {
                    // TODO: User didn't grant access. Show something?
                }
            })

        default:
            // TODO: User has denied access...show some sort of dialog..?
            break
        }
    }

    private func setupSession() {
        captureSessionQueue.async {

        }
    }
}

