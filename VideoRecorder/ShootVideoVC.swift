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
let VIDEO_FOLDER = "videoFolder.mov"

class ShootVideoVC: UIViewController,AVCaptureFileOutputRecordingDelegate {
    @IBOutlet weak var preView: UIView!
    
    var captureSession:AVCaptureSession? = nil
    var captureDevice:AVCaptureDevice? = nil
    var captureMovieFileOutput:AVCaptureMovieFileOutput? = nil
    var captureVideoPreviewLayer:AVCaptureVideoPreviewLayer? = nil
    
    var fileUrl:URL? = nil
    var finalUrl:URL? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupCapture()
        self.captureSession?.startRunning()
    }
    
    func setupCapture() {
        // 创建会话 (AVCaptureSession) 对象
        self.captureSession = AVCaptureSession()
        // 设置会话的 sessionPreset 属性
        if (self.captureSession?.canSetSessionPreset(AVCaptureSessionPreset640x480))! {
            self.captureSession?.canSetSessionPreset(AVCaptureSessionPreset640x480)
        }
        // 获取摄像头输入设备， 创建 AVCaptureDeviceInput 对象
        guard let videoDevice = self._getVideoDeviceWithPosition(.back) else {
            print("---- 取得摄像头时出现问题----")
            return
        }
        // 添加一个音频输入设备
        guard let audioDevice = self._getAudioDevice() else {
            print("---- 取得麦克风时出现问题----")
            return
        }
        self.captureDevice = videoDevice
        var videoInput:AVCaptureDeviceInput
        var audioInput:AVCaptureDeviceInput
        do {
            // 视频输入对象
            videoInput = try AVCaptureDeviceInput(device: videoDevice)
            //  音频输入对象
            audioInput = try AVCaptureDeviceInput(device: audioDevice)
        } catch {
            return
        }
        if (self.captureSession?.canAddInput(videoInput))! {
            // 将视频输入对象添加到会话 (AVCaptureSession) 中
            self.captureSession?.addInput(videoInput)
        }
        if (self.captureSession?.canAddInput(audioInput))! {
            // 将音频输入对象添加到会话 (AVCaptureSession) 中
            self.captureSession?.addInput(audioInput)
        }
        // 拍摄视频输出对象
        self.captureMovieFileOutput = AVCaptureMovieFileOutput()
        if (self.captureSession?.canAddOutput(self.captureMovieFileOutput))! {
            // 将设备输出添加到会话中
            self.captureSession?.addOutput(self.captureMovieFileOutput)
        }
        
        // 通过会话 (AVCaptureSession) 创建预览层
        self.captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        // 显示在视图表面的图层
        let layer = preView.layer
        layer.masksToBounds = true
        self.captureVideoPreviewLayer?.frame = layer.bounds
        self.captureVideoPreviewLayer?.masksToBounds = true
        self.captureVideoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        layer.addSublayer(self.captureVideoPreviewLayer!)
    }
    
    func compressVideo(_ url:URL) {
        let start = NSDate()
        // 通过文件的 url 获取到这个文件的资源
        let avAsset = AVURLAsset(url: url)
        // 用 AVAssetExportSession 这个类来导出资源中的属性
        let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: avAsset)
        if compatiblePresets.contains(AVAssetExportPresetMediumQuality) {
            // 通过资源（AVURLAsset）来定义 AVAssetExportSession
            let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetMediumQuality)
            // 设置导出文件的存放路径
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
            let filename = "output-\(formatter.string(from: Date())).mp4"
            let outputFielPath = NSTemporaryDirectory().appending(filename)
            let saveUrl = NSURL.fileURL(withPath: outputFielPath)
            self.finalUrl = saveUrl
            exportSession?.outputURL = saveUrl
            // 是否对网络进行优化
            exportSession?.shouldOptimizeForNetworkUse = true
            // 转换成MP4格式
            exportSession?.outputFileType = AVFileTypeMPEG4
            // 开始导出,导出后执行完成的block
            exportSession?.exportAsynchronously(completionHandler: {
                if exportSession?.status == AVAssetExportSessionStatus.completed {
                    let time = -start.timeIntervalSinceNow
                    print(time)
                    print ("File Size: \(self._getFileSize(saveUrl.path))")
                } else {
                    print("Compress Error: \(exportSession?.error)")
                }
            })
        }
    }
    
    func _getVideoDeviceWithPosition(_ position:AVCaptureDevicePosition) -> AVCaptureDevice! {
        let deviceTypes = [AVCaptureDeviceType.builtInWideAngleCamera, AVCaptureDeviceType.builtInTelephotoCamera]
        let devices = AVCaptureDeviceDiscoverySession.init(deviceTypes: deviceTypes, mediaType: AVMediaTypeVideo, position: position).devices
        return devices?.first
    }
    
    func _getAudioDevice() -> AVCaptureDevice! {
        let deviceTypes = [AVCaptureDeviceType.builtInMicrophone]
        let devices = AVCaptureDeviceDiscoverySession.init(deviceTypes: deviceTypes, mediaType: AVMediaTypeAudio, position: .unspecified).devices
        return devices?.first
    }
    
    func _getFileSize(_ path:String) -> Int {
        var fileSize = 0
        do {
            let outputFileAttributes = try FileManager().attributesOfItem(atPath: path) as NSDictionary?
            if let attr = outputFileAttributes {
                fileSize = Int(attr.fileSize())
            }
        } catch {
            print("_getFileSize \(error)")
        }
        return fileSize
    }
    
    @IBAction func record(_ sender: Any) {
        let btn = sender as! UIButton
        btn.isSelected = !btn.isSelected
        if btn.isSelected {
            let captureConnection = self.captureMovieFileOutput?.connection(withMediaType: AVMediaTypeVideo)
             // 预览图层和视频方向保持一致
            captureConnection?.videoOrientation = (self.captureVideoPreviewLayer?.connection.videoOrientation)!
            let outputFielPath = NSTemporaryDirectory().appending(VIDEO_FOLDER)
            self.fileUrl = NSURL.fileURL(withPath: outputFielPath)
            self.captureMovieFileOutput?.startRecording(toOutputFileURL: self.fileUrl, recordingDelegate: self)
        } else {
            self.captureMovieFileOutput?.stopRecording()
//            self.captureSession?.stopRunning()
        }
    }
    @IBAction func playOrg(_ sender: Any) {
        let playVC = PlayVideoVC(nibName: "PlayVideoVC", bundle: nil)
        playVC.videoUrl = self.fileUrl
        self.present(playVC, animated: true, completion: nil)
    }
    
    @IBAction func playCom(_ sender: Any) {
        let playVC = PlayVideoVC(nibName: "PlayVideoVC", bundle: nil)
        playVC.videoUrl = self.finalUrl
        self.present(playVC, animated: true, completion: nil)
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        print("---- 开始录制 ----")
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        print ("File Size:", self._getFileSize((outputFileURL?.path)!))
        self.compressVideo(outputFileURL)
        print("---- 录制结束 ----")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
