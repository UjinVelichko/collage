/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import ObjectMapper

final class CollagePositionMappable: Mappable {
    private let keys = CCollagePatternsMappableKeys.CollageMappable.CollagePositionMappable.self
    
    var x      = 0
    var y      = 0
    var width  = 0
    var height = 0
    
    required init?(map: Map) { }
    
    init() { }
    
    func mapping(map: Map) {
        x      <- map[keys.x]
        y      <- map[keys.y]
        width  <- map[keys.width]
        height <- map[keys.height]
    }
}
