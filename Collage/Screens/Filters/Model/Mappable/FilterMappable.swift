/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import ObjectMapper

final class FilterMappable: Mappable {
    private let keys = CFiltersListMappable.FilterMappable.self
    
    var name     = ""
    var ciFilter = ""
    
    required init?(map: Map) { }
    
    init() { }
    
    func mapping(map: Map) {
        name     <- map[keys.name]
        ciFilter <- map[keys.ciFilter]
    }
}
