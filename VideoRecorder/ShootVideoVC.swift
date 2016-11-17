//
//  ShootVideoVC.swift
//  VideoRecorder
//
//  Created by YourtionGuo on 17/11/2016.
//  Copyright © 2016 Yourtion. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary

let TIMER_INTERVAL = 0.05
let VIDEO_FOLDER = "videoFolder"

class ShootVideoVC: UIViewController {
    @IBOutlet weak var preView: UIView!
    
    var captureSession:AVCaptureSession? = nil
    var captureDevice:AVCaptureDevice? = nil
    var captureMovieFileOutput:AVCaptureMovieFileOutput? = nil
    var captureVideoPreviewLayer:AVCaptureVideoPreviewLayer? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupCapture()
    }
    
    func setupCapture() {
        self.captureSession = AVCaptureSession()
        self.captureMovieFileOutput = AVCaptureMovieFileOutput()
        if (self.captureSession?.canSetSessionPreset(AVCaptureSessionPreset640x480))! {
            self.captureSession?.canSetSessionPreset(AVCaptureSessionPreset640x480)
        }
        guard let videoCaptureDevice = self._getVideoDeviceWithPosition(.back) else {
            print("---- 取得摄像头时出现问题----")
            return
        }
        guard let audioCaptureDevice = self._getAudioDevice() else {
            print("---- 取得麦克风时出现问题----")
            return
        }
        self.captureDevice = videoCaptureDevice
        var captureVideoDeviceInput:AVCaptureDeviceInput
        var captureAudioDeviceInput:AVCaptureDeviceInput
        do {
            captureVideoDeviceInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            captureAudioDeviceInput = try AVCaptureDeviceInput(device: audioCaptureDevice)
        } catch {
            return
        }
        if (self.captureSession?.canAddInput(captureVideoDeviceInput))! {
            self.captureSession?.addInput(captureVideoDeviceInput)
        }
        if (self.captureSession?.canAddInput(captureAudioDeviceInput))! {
            self.captureSession?.addInput(captureAudioDeviceInput)
            let captureConnection = self.captureMovieFileOutput?.connection(withMediaType: AVMediaTypeVideo)
            if (captureConnection?.isVideoStabilizationSupported)! {
                captureConnection?.preferredVideoStabilizationMode = .auto
            }
        }
        
        self.captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        let layer = preView.layer
        layer.masksToBounds = true
        self.captureVideoPreviewLayer?.frame = layer.bounds
        self.captureVideoPreviewLayer?.masksToBounds = true
        self.captureVideoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        layer.addSublayer(self.captureVideoPreviewLayer!)
    }
    
    func _getVideoDeviceWithPosition(_ position:AVCaptureDevicePosition) -> AVCaptureDevice! {
        let deviceTypes = [AVCaptureDeviceType.builtInWideAngleCamera, AVCaptureDeviceType.builtInTelephotoCamera]
        let devices = AVCaptureDeviceDiscoverySession.init(deviceTypes: deviceTypes, mediaType: AVMediaTypeVideo, position: position).devices
        return devices?.first
    }
    
    func _getAudioDevice() -> AVCaptureDevice! {
        let deviceTypes = [AVCaptureDeviceType.builtInMicrophone]
        let devices = AVCaptureDeviceDiscoverySession.init(deviceTypes: deviceTypes, mediaType: AVMediaTypeVideo, position: .unspecified).devices
        return devices?.first
    }
    
    @IBAction func record(_ sender: Any) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
