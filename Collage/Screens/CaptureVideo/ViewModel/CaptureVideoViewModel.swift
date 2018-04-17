/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import RxSwift
import RxCocoa

final class CaptureVideoViewModel: BaseViewModel, BaseViewModelInterface {
    //*** View to viewModel binding events
    let newImage       = PublishSubject<UIImage>()
    let videoRecording = PublishSubject<Bool>()
    //*** viewModel events
    let startVideoCapture       = PublishSubject<Bool>()
    let navigateToCollageChoose = BehaviorRelay(value: false)
    
    private let imagesSaved = PublishSubject<Bool>()
    
    private var model: CaptureVideoModelInterface!
    
// MARK: - Lifecycle
    
    override init() {
        super.init()
        
        subscribeOnViewControllerLifrcycle()
        uiEventsProcessing()
    }

// MARK: - BaseViewModelInterface
    
    func setModel(_ model: BaseModelInterface) {
        guard let injectedModel = model as? CaptureVideoModel else {
            fatalError(BaseInterfacesError.model(String(describing: CaptureVideoModel.self),
                                                     String(describing: model.self)).localizedDescription)            
        }
        
        self.model = injectedModel
    }

// MARK: - UIViewController lifecycle
    
    private func subscribeOnViewControllerLifrcycle() {
        viewDidAppear
            .observeWhisSubscribtion { [weak self] event in
                self?.startVideoCapture.onNext(true)
        }.disposed(by: disposeBag)
    }
    
// MARK: - UI events
    
    private func uiEventsProcessing() {
        // collage images
        var images: [UIImage] = []
        
        newImage
            .observe { [weak self] event in
                guard let image = event.element else { return }
                
                images.append(image)
                
                if images.count == CCaptureVideoVC.collageElementsCount {
                    self?.setImages(images)
                    images.removeAll()
                }                                
            }.disposed(by: disposeBag)
        // recording event
        videoRecording
            .map { _ in return false }
            .bind(to: imagesSaved)
            .disposed(by: disposeBag)
        // next button tape
        nextButtonTape
            .observeWhisSubscribtion { [weak self] event in
                self?.saveImages()
            }.disposed(by: disposeBag)
        // next button enabled
        Observable
            .combineLatest(videoRecording.asObservable(), imagesSaved.asObservable()) { recording, saved in return !recording && saved }
            .bind(to: nextButtonEnable)
            .disposed(by: disposeBag)
    }
    
// MARK: - Save images
    
    private func saveImages() {
        model.saveImages(onSucces: { [weak self] in
            self?.navigateToCollageChoose.accept(true)
        }) { error in
            Alert.show(message: error.localizedDescription)
        }
    }
    
    private func setImages(_ images: [UIImage]) {
        var data: [Data] = []
        
        for image in images {
            if let imageData = UIImageJPEGRepresentation(image, CCaptureVideoVC.imageCompression) { data.append(imageData) }
        }
        
        model.setImagesData(data)
        
        imagesSaved.onNext(true)
    }
}
