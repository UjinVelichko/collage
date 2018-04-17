/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import UIKit
import RxSwift
import RxCocoa

final class CaptureVideoVC: BaseViewController<CaptureVideoViewModel>, BaseViewInterface {
    //*** Views
    @IBOutlet weak var cameraView: CameraCaptureView!
    //*** Buttons
    @IBOutlet weak var recordButton: RecordButton!
        
// MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bindUI()
        eventsSubscription()
    }
    
// MARK: - BaseViewInterface
    
    func setViewModel(_ viewModel: BaseViewModelInterface, whis initialData: Any?) {
        guard let injectedViewModel = viewModel as? CaptureVideoViewModel else {
            fatalError(BaseInterfacesError.viewModel(String(describing: CaptureVideoViewModel.self),
                                                     String(describing: viewModel.self)).localizedDescription)
        }
        
        self.viewModel = injectedViewModel
    }

// MARK: - UI setup
    
    private func setupUI() {
        navigationItem.title = CCaptureVideoVC.title
        nextButton.title     = CCaptureVideoVC.nextButtonTitle
    }
    
// MARK: - UI binding and events subscribtion
    
    private func bindUI() {
        // camera view frames
        cameraView.frameImmediately
            .bind(to: viewModel.newImage)
            .disposed(by: disposeBag)
        // bind the state of the recordButton to the current state of the recording process
        cameraView.isVideoRecording
            .bind(to: recordButton.isRecording)
            .disposed(by: disposeBag)
        viewModel.startVideoCapture
            .bind(to: cameraView.startCapture)
            .disposed(by: disposeBag)
        // recording event
        cameraView.isVideoRecording
            .bind(to: viewModel.videoRecording)
            .disposed(by: disposeBag)
        // record button is visible only when starting screen capture
        cameraView.startCapture
            .map { !$0 }
            .bind(to: recordButton.rx.isHidden)
            .disposed(by: disposeBag)
        // recording button tape
        recordButton.rx
            .tap
            .map { [weak self] in
                guard let strongSelf = self else { return false }
                
                return !strongSelf.cameraView.videoWillRecording()
            }.bind(to: cameraView.recordVideo)
            .disposed(by: disposeBag)
    }
    
    private func eventsSubscription() {
        // navigation
        viewModel.navigateToCollageChoose
            .asObservable()
            .observe(on: MainScheduler.asyncInstance) { [weak self] event in
                guard let navigate = event.element,
                    navigate else { return }
                self?.navigateToCollagePatternChoose()
            }.disposed(by: disposeBag)
    }
    
// MARK: - Navigation
    
    private func navigateToCollagePatternChoose() {
        guard let choosePatternController = storyboard?.instantiateViewController(withIdentifier: String(describing: CollagePatternVC.self)) as? CollagePatternVC else {
            return
        }
        
        navigationController?.pushViewController(Injector.inject(to: choosePatternController,
                                                                 viewModel: CollagePatternViewModel.self,
                                                                 model: CollagePatternModel.self), animated: true)
    }
}


