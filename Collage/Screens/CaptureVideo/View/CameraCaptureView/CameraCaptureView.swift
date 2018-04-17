/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import AVFoundation
import RxSwift

final class CameraCaptureView: UIView, CameraCaptureDelegate {
    //*** CameraCapure
    private let cameraCapture: CameraCaptureInterface = CameraCapture()
    //*** Events
    let startCapture = PublishSubject<Bool>()
    //*** Result
    let frameImmediately = PublishSubject<UIImage>()// emited each time when image from frame is ready
    let isVideoRecording = PublishSubject<Bool>()// emited each time when video become recording or stoped
    let recordVideo      = PublishSubject<Bool>()
    
    private let disposeBag = DisposeBag()
    
// MARK: - Lifecycle

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        cameraCapture.setDelegate(self)
        subscribeOnAppStatesChanged()
        eventsSubscription()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        cameraCapture.layoutSubviews()
    }
    
    private func subscribeOnAppStatesChanged() {
        let background = NotificationCenter.default.rx.notification(.UIApplicationDidEnterBackground)
        let foregraund = NotificationCenter.default.rx.notification(.UIApplicationWillEnterForeground)
        let active     = NotificationCenter.default.rx.notification(.UIApplicationDidBecomeActive)
        
        Observable.of(background, foregraund, active)
            .merge()
            .observe(on: MainScheduler.asyncInstance) { [weak self] event in
                guard let notification = event.element else { return }

                switch notification.name {
                    case .UIApplicationDidEnterBackground: self?.cameraCapture.applicationDidEnterBackground()
                    case .UIApplicationWillEnterForeground: self?.cameraCapture.applicationWillEnterForeground()
                    case .UIApplicationDidBecomeActive: self?.cameraCapture.applicationDidBecomeActive()
                    default: break
                }
            }.disposed(by: disposeBag)
    }
    
    private func eventsSubscription() {
        startCapture
            .observeWhisSubscribtion(on: MainScheduler.asyncInstance) { [weak self] event in
                guard let capture = event.element, capture else { return }
                
                self?.startVideoCapture()
            }.disposed(by: disposeBag)
        recordVideo
            .observeWhisSubscribtion(on: MainScheduler.asyncInstance) { [weak self] event in
                guard let start = event.element else { return }
                
                self?.recordVideo(start)
            }.disposed(by: disposeBag)
    }
    
// MARK: - Start video capture
    
    func startVideoCapture() {
        cameraCapture.runSession(for: self, frames: CCaptureVideoVC.collageElementsCount) { error in
            if error != nil { Alert.show(message: error!.localizedDescription) }
        }
    }
    
    func recordVideo(_ start: Bool) {
        do {
            try cameraCapture.record(start)
        } catch { Alert.show(message: error.localizedDescription) }
    }
    
    func videoWillRecording() -> Bool {
        return cameraCapture.videoWillRecording()
    }
    
// MARK: -  CameraCaptureDelegate
    
    func imageReady(image: UIImage, error: Error?) {
        guard error == nil else { fatalError(error!.localizedDescription) }
        
        frameImmediately.onNext(image)
    }
    
    func recordingStateChanged(isRecording: Bool) {
        isVideoRecording.onNext(isRecording)
    }
}





