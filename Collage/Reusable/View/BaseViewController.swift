/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import UIKit
import RxSwift

class BaseViewController<T: BaseViewModel>: UIViewController {
    //*** Lifecycle events
    private let viewWillAppearEvent        = PublishSubject<Bool>()
    private let viewDidLoadEvent           = PublishSubject<Bool>()
    private let viewDidAppearEvent         = PublishSubject<Bool>()
    private let viewDidLayoutSubviewsEvent = PublishSubject<Bool>()
    //*** Buttons
    let nextButton = UIBarButtonItem(title: nil, style: .plain, target: self, action: nil)
    
    let disposeBag = DisposeBag()
    
// MARK: - ViewModel
    
    var viewModel: T! {
        didSet {
            bindEvents()
        }
    }

// MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()

        viewDidLoadEvent.onNext(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewWillAppearEvent.onNext(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewDidAppearEvent.onNext(true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        viewDidLayoutSubviewsEvent.onNext(true)
    }

// MARK: - Setup
    
    private func setupUI() {
        navigationItem.rightBarButtonItem = nextButton
    }
    
// MARK: - Events binding
    
    private func bindEvents() {
        // lifecycle events
        viewWillAppearEvent
            .asObservable()
            .bind(to: viewModel.viewWillAppear)
            .disposed(by: disposeBag)
        viewDidLoadEvent
            .asObservable()
            .observeOn(MainScheduler.instance)
            .bind(to: viewModel.viewDidLoad)
            .disposed(by: disposeBag)
        viewDidAppearEvent
            .asObservable()
            .bind(to: viewModel.viewDidAppear)
            .disposed(by: disposeBag)
        viewDidLayoutSubviewsEvent
            .asObservable()
            .bind(to: viewModel.viewDidLayoutSubviews)
            .disposed(by: disposeBag)
        // next button
        viewModel.nextButtonEnable
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        nextButton.rx
            .tap
            .bind(to: viewModel.nextButtonTape)
            .disposed(by: disposeBag)
    }
}
