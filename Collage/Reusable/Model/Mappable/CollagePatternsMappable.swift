/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import ObjectMapper

final class CollagePatternsMappable: Mappable {
    private let keys = CCollagePatternsMappableKeys.self
    
    var patterns: [CollageMappable] = []
    
    required init?(map: Map) { }
    
    init() { }
    
    func mapping(map: Map) {
        patterns <- map[keys.patterns]
    }
}

