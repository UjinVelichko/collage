/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import ObjectMapper

final class CollageMappable: Mappable {
    private let keys = CCollagePatternsMappableKeys.CollageMappable.self
    
    var name   = ""
    var height = 0
    var width  = 0
    
    var positions: [CollagePositionMappable] = []

    required init?(map: Map) { }

    init() { }
    
    func mapping(map: Map) {
        name      <- map[keys.name]
        height    <- map[keys.height]
        width     <- map[keys.width]
        positions <- map[keys.positions]
    }
}

