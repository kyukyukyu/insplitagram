//
//  Insplitagram.swift
//  Insplitagram
//
//  Created by Sanggyu Nam on 2018. 8. 2..
//  Copyright © 2018년 Sanggyu Nam. All rights reserved.
//

import Foundation
import AVFoundation

func trimOneMinute(inUrl: URL, outUrl: URL) -> Bool {
    let options = [ AVURLAssetPreferPreciseDurationAndTimingKey: true ]
    let asset = AVURLAsset(url: inUrl, options: options)
    
    let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough)
    guard exportSession != nil else {
        return false
    }
    
    let sixtySeconds = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 1))
    exportSession?.outputURL = outUrl
    exportSession?.outputFileType = AVFileType.mov
    exportSession?.timeRange = sixtySeconds
    
    let dispatchGroup = DispatchGroup()
    dispatchGroup.enter()
    
    exportSession?.exportAsynchronously {
        dispatchGroup.leave()
    }
    
    dispatchGroup.wait()
    return exportSession!.error == nil
}
