/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import UIKit

enum VideoMode {
    case movieOutput// recording video, than splitting by frames
    case videoDataOutput// receiving frames(each time, when it ready) whisout saving on device
}

protocol CameraCaptureDelegate: class {
    func imageReady(image: UIImage, error: Error?)
    func recordingStateChanged(isRecording: Bool)
}

protocol CameraCaptureInterface {
    //*** App lifecycle
    func applicationDidEnterBackground()
    func applicationWillEnterForeground()
    func applicationDidBecomeActive()
    //*** Capture session
    func runSession(for containerView: UIView, frames: Int, error: ((Error?) -> Void)?)
    func record(_ start: Bool) throws -> Void
    func videoWillRecording() -> Bool// the current selected action: start recording a video or initiate a stop
    //*** View lifecycle
    func layoutSubviews()
    //*** Delegate
    func setDelegate(_ delegate: CameraCaptureDelegate)
}

