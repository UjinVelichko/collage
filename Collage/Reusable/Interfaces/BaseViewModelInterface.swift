/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import Foundation

protocol BaseViewModelInterface: class {
    init()
    
    func setModel(_ model: BaseModelInterface)
}
