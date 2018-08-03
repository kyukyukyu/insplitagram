//
//  Insplitagram.swift
//  Insplitagram
//
//  Created by Sanggyu Nam on 2018. 8. 2..
//  Copyright © 2018년 Sanggyu Nam. All rights reserved.
//

import Foundation
import AVFoundation

func splitEveryOneMinute(srcUrl: URL, destDirUrl: URL) -> [URL] {
    let options = [ AVURLAssetPreferPreciseDurationAndTimingKey: true ]
    let asset = AVURLAsset(url: srcUrl, options: options)
    
    print("duration:", asset.duration)
    
    var outputUrls: [URL] = []
    var start = kCMTimeZero
    let splitDuration = CMTimeMakeWithSeconds(60, 1)
    while start < asset.duration {
        let range = CMTimeRangeMake(start, splitDuration)
        let outUrl = destDirUrl.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
        print("range:", range)
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough) else {
            break
        }
        exportSession.outputURL = outUrl
        exportSession.outputFileType = AVFileType.mov
        exportSession.timeRange = range
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        exportSession.exportAsynchronously {
            dispatchGroup.leave()
        }
        
        dispatchGroup.wait()
        
        if let error = exportSession.error {
            print("error in export session", error)
            break
        }
        
        outputUrls.append(outUrl)
        start = range.end
        print("finished one")
    }
    return outputUrls
}
