/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import ObjectMapper

protocol FiltersModelInterface: BaseModelInterface {
    func getFilters(onSucces: (([FilterMappable]) -> Void)?, onError: ((Error) -> Void)?)
}
