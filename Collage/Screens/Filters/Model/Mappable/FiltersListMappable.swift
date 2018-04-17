/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import ObjectMapper

final class FiltersListMappable: Mappable {
    private let keys = CFiltersListMappable.self
    
    var filters: [FilterMappable] = []
    
    required init?(map: Map) { }
    
    init() { }
    
    func mapping(map: Map) {
        filters <- map[keys.filters]
    }
}

