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
    let videoTrack = asset.tracks(withMediaType: AVMediaType.video).first!
    let audioTrack = asset.tracks(withMediaType: AVMediaType.audio).first!
    
    let composition = AVMutableComposition()
    let videoCompTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID())
    let audioCompTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())
    
    let sixtySeconds = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 1))
    try? videoCompTrack?.insertTimeRange(sixtySeconds, of: videoTrack, at: kCMTimeZero)
    try? audioCompTrack?.insertTimeRange(sixtySeconds, of: audioTrack, at: kCMTimeZero)
    
    let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetPassthrough)
    guard exportSession != nil else {
        return false
    }
    
    exportSession?.outputURL = outUrl
    exportSession?.outputFileType = AVFileType.mov
    //exportSession?.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 1))
    
    let dispatchGroup = DispatchGroup()
    dispatchGroup.enter()
    
    exportSession?.exportAsynchronously {
        dispatchGroup.leave()
    }
    
    dispatchGroup.wait()
    return exportSession!.error == nil
}
