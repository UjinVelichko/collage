/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import RxSwift
import RxCocoa

class BaseViewModel {
    //*** ViewController lifecycle(observe on child)
    let viewWillAppear        = PublishSubject<Bool>()
    let viewDidLoad           = PublishSubject<Bool>()
    let viewDidAppear         = PublishSubject<Bool>()
    let viewDidLayoutSubviews = PublishSubject<Bool>()
    //*** Initial data
    let initialDataReady = PublishSubject<Any?>()
    //*** Navigation next button
    let nextButtonTape   = PublishSubject<Void?>()
    let nextButtonEnable = BehaviorRelay(value: false)
    
    let disposeBag = DisposeBag()
}
