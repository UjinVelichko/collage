/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import AVFoundation
import UIKit

final class CameraCapture: NSObject, CameraCaptureInterface {
    //*** View
    private weak var containerView: UIView?
    //*** Capture session
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    //*** MovieOutput
    private let movieOutput = AVCaptureMovieFileOutput()
    //*** CIContext
    let context = CIContext()
    //*** Mode
    private var videoMode: VideoMode = .movieOutput
    //*** Number of frames, that we are want to get
    var numberOfFrames = 0
    //*** Flags
    var isRecording  = false
    var inBackground = false
    
    weak var delegate: CameraCaptureDelegate?
    
// MARK: - CameraCaptureInterface
    
    func runSession(for containerView: UIView, frames: Int, error: ((Error?) -> Void)?) {
        self.containerView = containerView
        numberOfFrames     = frames
        
        setupCaptureSession { [weak self] setupError in
            if setupError != nil { error?(setupError) }
            else {
                self?.captureSession?.startRunning()
                self?.supportOrientation()
            }
        }
    }
    
    func record(_ start: Bool) throws -> Void {
        guard captureSession != nil,
            videoMode == .movieOutput,
            !start && isRecording || start && !isRecording  else { return }
        
        if start {
            let filePath = try CBaseModelInterface.tempMovieName.tempFilePath()
            
            movieOutput.startRecording(to: filePath, recordingDelegate: self)
        } else { movieOutput.stopRecording() }
    }
    
    func videoWillRecording() -> Bool {
        return isRecording
    }
    
// MARK: App lifecycle
    
    func applicationDidEnterBackground() {
        inBackground = true
        
        movieOutput.stopRecording()
        captureSession?.stopRunning()
    }
    
    func applicationWillEnterForeground() {
        captureSession?.startRunning()
    }
    
    func applicationDidBecomeActive() {
       inBackground = false
    }

// MARK: View lifecycle
    
    func layoutSubviews() {
        supportOrientation()
    }
    
// MARK: Delegate
    
    func setDelegate(_ delegate: CameraCaptureDelegate) {
        self.delegate = delegate
    }
    
// MARK: - Orientation support
    
    private func supportOrientation() {
        guard let connection = videoPreviewLayer?.connection else { return }
        
        let orientation = UIApplication.shared.statusBarOrientation
        
        if connection.isVideoOrientationSupported {
            switch (orientation) {
                case .portrait: updatePreviewLayer(orientation: .portrait)
                case .landscapeRight: updatePreviewLayer(orientation: .landscapeRight)
                case .landscapeLeft: updatePreviewLayer(orientation: .landscapeLeft)
                default: updatePreviewLayer(orientation: .portrait)
            }
        }
    }
    
    private func updatePreviewLayer(orientation: AVCaptureVideoOrientation) {
        DispatchQueue.main.async {
            guard self.containerView != nil else { return }
            
            self.videoPreviewLayer?.connection?.videoOrientation = orientation
            self.videoPreviewLayer?.frame                        = self.containerView!.bounds
        }
    }
    
// MARK: - Capture session configuration
    
    private func setupCaptureSession(_ callback: ((CameraCaptureError?) -> Void)? = nil) {
        DispatchQueue.main.async {
            guard self.captureSession == nil else {
                callback?(nil)
                
                return
            }
            
            guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
                callback?(.device)
                
                return
            }
            
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                
                self.captureSession = AVCaptureSession()
                
                guard self.captureSession != nil else {
                    callback?(.session)
                    
                    return
                }
                
                self.captureSession?.addInput(input)// Set the input device on the capture session
                
                switch self.videoMode {
                    case .movieOutput: self.configureMovieOutput()
                    case .videoDataOutput: self.configureVideoDataOutput()
                }
                
                callback?(nil)
            } catch { callback?(.deviceInput(error.localizedDescription)) }
        }
    }
    
    private func configureMovieOutput() {
        movieOutput.movieFragmentInterval = kCMTimeInvalid
        
        captureSession?.addOutput(movieOutput)
        setVideoPreview()
    }
    
    private func configureVideoDataOutput() {
        let videoOutput = AVCaptureVideoDataOutput()
        
        captureSession?.addOutput(videoOutput)
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global())
        setVideoPreview()
    }
    
    // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer
    private func setVideoPreview() {
        guard let containerView = self.containerView else { return }
        
        videoPreviewLayer               = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame        = containerView.layer.bounds
        
        if videoPreviewLayer != nil { containerView.layer.addSublayer(videoPreviewLayer!) }
    }
}
