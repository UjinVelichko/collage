/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

enum CCollagePatternsMappableKeys {
    static let patterns = "patterns"
    
    enum CollageMappable {
        static let name      = "name"
        static let height    = "height"
        static let width     = "width"
        static let positions = "positions"
        
        enum CollagePositionMappable {
            static let x      = "x"
            static let y      = "y"
            static let width  = "width"
            static let height = "height"
        }
    }
}
