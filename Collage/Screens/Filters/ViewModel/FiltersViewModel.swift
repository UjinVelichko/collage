/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import UIKit
import RxSwift
import RxCocoa

typealias FilteredCollage = (images: [UIImage], pattern: CollageMappable, filter: FilterMappable, selected: [Int])

final class FiltersViewModel: BaseViewModel, BaseViewModelInterface {
    //*** FiltersCollectionView dataSourse
    let filters = BehaviorRelay<[FilterMappable]>(value: [])
    //*** View to viewModel binding events
    let cellDidChoose = PublishSubject<Int>()
    let imageDidTape  = PublishSubject<Int>()
    //*** viewModel events
    let showFilteredCollage = PublishSubject<FilteredCollage>()

    private let imagesReady = PublishSubject<[UIImage]>()
    private let filterReady = PublishSubject<FilterMappable>()
    private let selectedIndexes = BehaviorRelay<[Int]>(value: [])
    
    private var model: FiltersModelInterface!
    
// MARK: - Lifecycle
    
    override init() {
        super.init()
        
        subscribeOnViewControllerLifrcycle()
        eventsBinding()
        uiEventsSubscription()
    }
    
// MARK: - BaseViewModelInterface
    
    func setModel(_ model: BaseModelInterface) {
        guard let injectedModel = model as? FiltersModelInterface else {
            fatalError(BaseInterfacesError.model(String(describing: FiltersModelInterface.self),
                                                 String(describing: model.self)).localizedDescription)
        }
        
        self.model = injectedModel
    }
    
// MARK: - UIViewController lifecycle and events binding
    
    private func subscribeOnViewControllerLifrcycle() {
        viewDidLoad.observeWhisSubscribtion(subscribe: MainScheduler.instance) { [weak self] event in
            self?.getImages()
            self?.getFilters()
        }.disposed(by: disposeBag)
    }
    
    private func eventsBinding() {
        // show collage
        Observable.combineLatest(initialDataReady.asObservable(),
                                 imagesReady.asObservable(),
                                 filterReady.asObservable(),
                                 selectedIndexes.asObservable(),
                                 viewDidLayoutSubviews.asObservable()) { pattern, images, filter, indexes, didLayout in
                                    guard let collagePattern = pattern as? CollageMappable else {
                                        fatalError(BaseInterfacesError.initialData(String(describing: CollageMappable.self),
                                                                                   String(describing: pattern.self)).localizedDescription)
                                    }
                                    
                                    return (images, collagePattern, filter, indexes)
            }.bind(to: showFilteredCollage)
            .disposed(by: disposeBag)
    }
    
// MARK: - UI events
    
    private func uiEventsSubscription() {
        // cell choosing
        cellDidChoose.observeWhisSubscribtion { [weak self] event in
            guard let strongSelf = self,
                let index = event.element, index < strongSelf.filters.value.count else { return }
            
            strongSelf.filterReady.onNext(strongSelf.filters.value[index])
            }.disposed(by: disposeBag)
        // collage image did tape
        imageDidTape
            .observeWhisSubscribtion { [weak self] event in
                guard let strongSelf = self,
                    let index = event.element else { return }
                var indexes = strongSelf.selectedIndexes.value
                
                if indexes.contains(index) { indexes = indexes.filter { $0 != index } }
                else { indexes.append(index) }
                
                strongSelf.selectedIndexes.accept(indexes)
            }.disposed(by: disposeBag)
    }
    
// MARK: - Get filters and images
    
    private func getFilters() {
        model.getFilters(onSucces: { [weak self] filtersList in
            self?.filters.accept(filtersList)
            
            if let filter = filtersList.first { self?.filterReady.onNext(filter) }
        }) { error in
            Alert.show(message: error.localizedDescription)
        }
    }
    
    private func getImages() {
        var selected: [Int] = []
        
        let images: [UIImage]? = model.getPathesToImages()?
            .enumerated()
            .map {
                selected.append($0)
            
                if let image = UIImage(contentsOfFile: $1) { return image }
                else { return UIImage() }
            }
        
        if images != nil {
            imagesReady.onNext(images!)
            selectedIndexes.accept(selected)
        }
    }
}
