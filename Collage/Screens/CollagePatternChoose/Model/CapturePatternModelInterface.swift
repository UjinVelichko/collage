/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import ObjectMapper

protocol CapturePatternModelInterface: BaseModelInterface {
    func getCollagePatterns(onSucces: (([CollageMappable]) -> Void)?, onError: ((Error) -> Void)?)
}
