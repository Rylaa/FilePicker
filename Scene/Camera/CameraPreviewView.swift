//
//  CameraPreviewView.swift
//
//
//  Created by Yusuf Demirkoparan on 29.04.2020.
//  
//
import UIKit
import AVFoundation

class CameraPreviewView: UIView {
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }

    var session: AVCaptureSession? {
        didSet {
            videoPreviewLayer.session = session
        }
    }

    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}
