/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import UIKit

class Injector {
    static func inject<ViewClass: BaseViewInterface,
        ViewModelClass: BaseViewModelInterface,
        ModelClass: BaseModelInterface>(to view: ViewClass, viewModel: ViewModelClass.Type, model: ModelClass.Type, _ initialData: Any? = nil) -> ViewClass {
        let viewModel = ViewModelClass()
        let model     = ModelClass()
        
        view.setViewModel(viewModel, whis: initialData)
        viewModel.setModel(model)
        
        return view
    }
}
