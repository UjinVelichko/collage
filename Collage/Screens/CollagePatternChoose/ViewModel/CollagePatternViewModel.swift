/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import UIKit
import RxSwift
import RxCocoa

typealias Collage             = (images: [UIImage], pattern: CollageMappable)
typealias ToFiltersNavigation = (pattern: CollageMappable, navigate: Bool)

final class CollagePatternViewModel: BaseViewModel, BaseViewModelInterface {
    //*** PatternCollectionView dataSourse
    let patterns = BehaviorRelay<[CollageMappable]>(value: [])
    //*** View to viewModel binding events
    let cellDidChoose = PublishSubject<Int>()
    //*** viewModel events
    lazy var navigateToFilters: Observable<ToFiltersNavigation> = {
        return Observable
            .combineLatest(patternReady.asObservable(), toFilters.asObservable()) { pattern, navigation in return (pattern, navigation) }
    } ()
    
    lazy var showCollage: Observable<Collage> = {
        return Observable
            .combineLatest(imagesReady.asObservable(),
                           patternReady.asObservable(),
                           viewDidLayoutSubviews.asObservable()) { imades, pattern, data in return (imades, pattern) }
    } ()

    private let imagesReady  = PublishSubject<[UIImage]>()
    private let patternReady = PublishSubject<CollageMappable>()
    private let toFilters    = PublishSubject<Bool>()
    
    private var model: CapturePatternModelInterface!
    
// MARK: - Lifecycle
    
    override init() {
        super.init()
        
        subscribeOnViewControllerLifrcycle()
        uiEventsSubscription()
    }    
    
// MARK: - BaseViewModelInterface
    
    func setModel(_ model: BaseModelInterface) {
        guard let injectedModel = model as? CapturePatternModelInterface else {
            fatalError(BaseInterfacesError.model(String(describing: CapturePatternModelInterface.self),
                                                 String(describing: model.self)).localizedDescription)
        }
        
        self.model = injectedModel
    }
    
// MARK: - UIViewController lifecycle
    
    private func subscribeOnViewControllerLifrcycle() {
        viewDidLoad.observeWhisSubscribtion(subscribe: MainScheduler.instance) { [weak self] event in
            self?.nextButtonEnable.accept(true)
            self?.getImages()
            self?.getCollagePatterns()
        }.disposed(by: disposeBag)
        
        viewDidAppear.observeWhisSubscribtion { [weak self] event in
            self?.toFilters.onNext(false)
        }.disposed(by: disposeBag)
    }
    
// MARK: - UI events
    
    private func uiEventsSubscription() {
        // cell choosing
        cellDidChoose.observeWhisSubscribtion { [weak self] event in
            guard let strongSelf = self,
                let index = event.element, index < strongSelf.patterns.value.count else { return }
            
            strongSelf.patternReady.onNext(strongSelf.patterns.value[index])
        }.disposed(by: disposeBag)
        // next button
        nextButtonTape
            .observeWhisSubscribtion { [weak self] event in
                self?.toFilters.onNext(true)
            }.disposed(by: disposeBag)
    }
    
// MARK: - Model actions
    
    private func getCollagePatterns() {
        model.getCollagePatterns(onSucces: { [weak self] patterns in
            self?.patterns.accept(patterns)
            
            if let pattern = patterns.first { self?.patternReady.onNext(pattern) }
        }) { error in
            Alert.show(message: error.localizedDescription)
        }
    }
    
    private func getImages() {
        let images: [UIImage]? = model.getPathesToImages()?.map {
            if let image = UIImage(contentsOfFile: $0) { return image }
            else { return UIImage() }
        }

        if images != nil { imagesReady.onNext(images!) }
    }
}
