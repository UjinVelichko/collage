/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import RxSwift
import RxCocoa

final class CaptureVideoModel: CaptureVideoModelInterface {
    private let imagesDataQueue = DispatchQueue(label: "imagesDataQueue", qos: .default, attributes: .concurrent)
    private var images: [Data]  = []

    func saveImages(onSucces: (() -> Void)?, onError: ((Error) -> Void)?) {
        guard !getImagesData().isEmpty else { return }
        
        saveImagesAs(data: getImagesData(), onSucces: onSucces, onError: onError)
    }
    
    func setImagesData(_ data: [Data]) {
        imagesDataQueue.async(flags: .barrier) { [weak self] in self?.images = data }
    }
    
    private func getImagesData() -> [Data] {
        var data: [Data]!
        
        imagesDataQueue.sync { data = images }
        
        return data
    }
}

