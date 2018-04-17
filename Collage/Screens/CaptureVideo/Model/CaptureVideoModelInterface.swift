/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import Foundation

protocol CaptureVideoModelInterface: BaseModelInterface {
    func saveImages(onSucces: (() -> Void)?, onError: ((Error) -> Void)?)
    func setImagesData(_ data: [Data])
}
