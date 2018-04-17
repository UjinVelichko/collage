/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import UIKit
import RxSwift
import RxCocoa

final class FiltersVC: BaseViewController<FiltersViewModel>, BaseViewInterface {
    //*** Views
    @IBOutlet weak var filtersCollectionView: UICollectionView!
    @IBOutlet weak var collageContainerView: UIView!
    
    private let tapGesture = CollageTapGesture()
    
// MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindUI()
        eventsSubscription()
    }
    
// MARK: - BaseViewInterface
    
    func setViewModel(_ viewModel: BaseViewModelInterface, whis initialData: Any?) {
        guard let injectedViewModel = viewModel as? FiltersViewModel else {
            fatalError(BaseInterfacesError.viewModel(String(describing: FiltersViewModel.self),
                                                     String(describing: viewModel.self)).localizedDescription)
        }
        
        self.viewModel = injectedViewModel
        
        self.viewModel.initialDataReady.onNext(initialData)
    }
    
// MARK: - Setup
    
    private func setupUI() {
        // navigation
        navigationItem.title = CFiltersVC.title
        nextButton.title     = CFiltersVC.nextButtonTitle
        // filtersCollectionView
        let identifier = String(describing: FilterCVCell.self)
        
        filtersCollectionView.register(UINib.init(nibName: identifier, bundle: Bundle.init(for: FilterCVCell.self)),
                                       forCellWithReuseIdentifier: identifier)
        // tap gesture
        collageContainerView.addGestureRecognizer(tapGesture)
    }
    
// MARK: - UI binding and events subscribtion
    
    private func bindUI() {
        // patterns table
        viewModel.filters
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .bind(to: filtersCollectionView.rx.items(cellIdentifier: String(describing: FilterCVCell.self), cellType: FilterCVCell.self)) { row, filter, cell in
                guard let image = UIImage(named: CResources.Images.stub) else { return }
                
                CollageGenerator.createFilteredImage(whis: filter.ciFilter, for: [image]) { filteredImages in
                    cell.imageView.image      = filteredImages.first
                    cell.filterNameLabel.text = filter.name
                }
            }.disposed(by: disposeBag)
        filtersCollectionView.rx
            .itemSelected
            .map { $0.item }
            .bind(to: viewModel.cellDidChoose)
            .disposed(by: disposeBag)
        // tapGesture
        tapGesture
            .tapedImageViewIndex
            .bind(to: viewModel.imageDidTape)
            .disposed(by: disposeBag)
    }
    
    private func eventsSubscription() {
        // show collage
        viewModel.showFilteredCollage
            .observe { [weak self] event in
                guard let strongSelf = self,
                    let pattern = event.element?.pattern,
                    let images = event.element?.images,
                    let filter = event.element?.filter,
                    let selectedIndexes = event.element?.selected else { return }
                CollageGenerator.generate(whis: pattern,
                                          container: strongSelf.collageContainerView,
                                          images: images,
                                          filterName: filter.ciFilter,
                                          selectedIndexes: selectedIndexes,
                                          interacted: true)
            }.disposed(by: disposeBag)
        // select first pattern(by default)
        var disposeable = DisposeBag()
        
        viewModel.filters
            .asObservable()
            .observe(on: MainScheduler.asyncInstance) { [weak self] event in
                guard let strongSelf = self,
                    let patterns = event.element, !patterns.isEmpty else { return }
                
                disposeable = DisposeBag()
                
                strongSelf.filtersCollectionView.performBatchUpdates( {
                    strongSelf.filtersCollectionView.reloadData()
                }) { completition in
                    let firstItemIndexPath = IndexPath(item: 0, section: 0)
                    
                    if firstItemIndexPath.section <= strongSelf.filtersCollectionView.numberOfSections &&
                        firstItemIndexPath.row < strongSelf.filtersCollectionView.numberOfItems(inSection: firstItemIndexPath.section) {
                        strongSelf.filtersCollectionView.selectItem(at: firstItemIndexPath, animated: false, scrollPosition: .left)
                    }
                }
            }.disposed(by: disposeable)
    }
}
