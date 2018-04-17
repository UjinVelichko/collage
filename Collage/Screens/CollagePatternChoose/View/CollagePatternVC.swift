/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import UIKit
import RxSwift
import RxCocoa

final class CollagePatternVC: BaseViewController<CollagePatternViewModel>, BaseViewInterface {    
    //*** Views
    @IBOutlet weak var patternCollectionView: UICollectionView!
    @IBOutlet weak var collageContainerView: UIView!
    
// MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindUI()
        eventsSubscription()
    }
    
// MARK: - BaseViewInterface
    
    func setViewModel(_ viewModel: BaseViewModelInterface, whis initialData: Any?) {
        guard let injectedViewModel = viewModel as? CollagePatternViewModel else {
            fatalError(BaseInterfacesError.viewModel(String(describing: CollagePatternViewModel.self),
                                                     String(describing: viewModel.self)).localizedDescription)
        }
        
        self.viewModel = injectedViewModel
    }
    
// MARK: - Setup
    
    private func setupUI() {
        // navigation
        navigationItem.title = CCollagePatternVC.title
        nextButton.title     = CCollagePatternVC.nextButtonTitle
        // patternCollectionView
        let identifier = String(describing: CollagePatternCVCell.self)
        
        patternCollectionView.register(UINib.init(nibName: identifier, bundle: Bundle.init(for: CollagePatternCVCell.self)),
                                       forCellWithReuseIdentifier: identifier)
    }
    
// MARK: - UI binding and events subscribtion
    
    private func bindUI() {
        // patterns table
        viewModel.patterns
            .observeOn(MainScheduler.asyncInstance)
            .bind(to: patternCollectionView.rx.items(cellIdentifier: String(describing: CollagePatternCVCell.self), cellType: CollagePatternCVCell.self)) { row, pattern, cell in
                CollageGenerator.generate(whis: pattern, container: cell.contentContainerView)
                
                cell.collageNameLabel.text = pattern.name
            }.disposed(by: disposeBag)
        patternCollectionView.rx
            .itemSelected
            .map { $0.item }
            .bind(to: viewModel.cellDidChoose)
            .disposed(by: disposeBag)
    }
    
    private func eventsSubscription() {
        // show collage
        viewModel.showCollage
            .observe(on: MainScheduler.asyncInstance) { [weak self] event in
                guard let strongSelf = self,
                    let pattern = event.element?.pattern,
                    let images = event.element?.images else { return }
                
                CollageGenerator.generate(whis: pattern, container: strongSelf.collageContainerView, images: images)
            }.disposed(by: disposeBag)
        // select first pattern(by default)
        var disposeable = DisposeBag()
        
        viewModel.patterns
            .asObservable()
            .observe(on: MainScheduler.asyncInstance) { [weak self] event in
                guard let strongSelf = self,
                    let patterns = event.element, !patterns.isEmpty else { return }
                
                disposeable = DisposeBag()
                
                strongSelf.patternCollectionView.performBatchUpdates( {
                    strongSelf.patternCollectionView.reloadData()
                }) { completition in
                    let firstItemIndexPath = IndexPath(item: 0, section: 0)
                    
                    if firstItemIndexPath.section <= strongSelf.patternCollectionView.numberOfSections &&
                        firstItemIndexPath.row < strongSelf.patternCollectionView.numberOfItems(inSection: firstItemIndexPath.section) {
                        strongSelf.patternCollectionView.selectItem(at: firstItemIndexPath, animated: false, scrollPosition: .left)
                    }
                }
            }.disposed(by: disposeable)
        // navigation
        viewModel.navigateToFilters
            .observe(on: MainScheduler.asyncInstance) { [weak self] event in
                guard let currentCollagePattern = event.element?.pattern,
                    event.element?.navigate == true else { return }
                
                self?.navigateToFilters(currentCollagePattern)
            }.disposed(by: disposeBag)
    }
    
// MARK: - Navigation
    
    private func navigateToFilters(_ currPattern: CollageMappable) {
        guard let filtersController = storyboard?.instantiateViewController(withIdentifier: String(describing: FiltersVC.self)) as? FiltersVC else {
            return
        }
        
        navigationController?.pushViewController(Injector.inject(to: filtersController,
                                                                 viewModel: FiltersViewModel.self,
                                                                 model: FiltersModel.self,
                                                                 currPattern), animated: true)
    }
}




