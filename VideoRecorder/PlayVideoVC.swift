//
//  PlayVideoVC.swift
//  VideoRecorder
//
//  Created by YourtionGuo on 17/11/2016.
//  Copyright © 2016 Yourtion. All rights reserved.
//

import UIKit
import AVFoundation

class PlayVideoVC: UIViewController {
    
    open var videoUrl:URL!
    
    var player: AVPlayer? = nil
    var playerLayer: AVPlayerLayer? = nil
    var playerItem: AVPlayerItem? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        guard (videoUrl) != nil else {
            return
        }
        let movieAsset = AVURLAsset(url: videoUrl)
        self.playerItem = AVPlayerItem(asset: movieAsset)
        self.player = AVPlayer(playerItem: self.playerItem)
        
        self.playerLayer = AVPlayerLayer(player: self.player)
        self.playerLayer?.frame = self.view.bounds
        self.playerLayer?.videoGravity = AVLayerVideoGravityResizeAspect
        self.view.layer.addSublayer(self.playerLayer!)
        
        self.player?.play()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
