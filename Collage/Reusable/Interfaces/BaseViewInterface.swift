/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import UIKit

protocol BaseViewInterface: class {
    func setViewModel(_ viewModel: BaseViewModelInterface, whis initialData: Any?)
}

