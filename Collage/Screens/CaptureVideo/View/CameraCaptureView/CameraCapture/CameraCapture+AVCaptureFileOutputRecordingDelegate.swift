/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import AVFoundation
import UIKit

extension CameraCapture: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        isRecording = true
        
        delegate?.recordingStateChanged(isRecording: isRecording)
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        isRecording = false
        
        delegate?.recordingStateChanged(isRecording: isRecording)
        
        guard !inBackground else { return }
        // MARK: - TODO, I need to save the file if the application goes into the background and after connecting all the fragments(https://github.com/mkoehnke/MKOVideoMerge, https://github.com/barrettbreshears/AwesomeVideoCreator/blob/master/AwesomeVideoCreator/AwesomeVideoViewController.swift)
        guard error == nil else {
            delegate?.imageReady(image: UIImage(), error: error)
            
            return
        }
        
        DispatchQueue.global().async {
            let asset            = AVAsset(url: outputFileURL)
            let assetImgGenerate = AVAssetImageGenerator(asset: asset)
            
            assetImgGenerate.appliesPreferredTrackTransform = true
            
            let duration         = CMTimeGetSeconds(asset.duration)
            let interval         = duration / Double(self.numberOfFrames)
            var times: [NSValue] = []
            
            for i in 1...Int(self.numberOfFrames) {
                times.append(NSValue(time: CMTime(seconds: interval * Double(i), preferredTimescale: 1000)))
            }
            
            assetImgGenerate.generateCGImagesAsynchronously(forTimes: times) { requestedTime, cgImage, actualTime, result, error in
                if let cgImage = cgImage { self.delegate?.imageReady(image: UIImage(cgImage: cgImage), error: nil) }
            }
        }
    }
}
