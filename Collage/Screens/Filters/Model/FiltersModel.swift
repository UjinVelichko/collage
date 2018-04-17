/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import ObjectMapper

final class FiltersModel: FiltersModelInterface {
    func getFilters(onSucces: (([FilterMappable]) -> Void)?, onError: ((Error) -> Void)?) {
        JSONParser.loadJSON(name: CResources.JSON.filters, result: FiltersListMappable.self, onSuccess: { filterList in
            onSucces?(filterList.filters)
        }, onError: onError)
    }
}
