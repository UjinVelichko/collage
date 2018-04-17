/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import RxSwift

extension PublishSubject {
    func observeWhisSubscribtion(on observeSheduler: SchedulerType = ConcurrentDispatchQueueScheduler(qos: .background),
                                 subscribe subscribeSheduler: SchedulerType = ConcurrentDispatchQueueScheduler(qos: .background),
                                 _ subscribeCallback: @escaping ((Event<E>) -> Void)) -> Disposable {
        return self
            .asObservable()
            .observeOn(observeSheduler)
            .subscribeOn(subscribeSheduler)
            .subscribe { event in
                subscribeCallback(event)
            }
    }
}
