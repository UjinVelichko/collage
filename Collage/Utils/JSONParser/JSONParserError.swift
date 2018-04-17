/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import Foundation

enum JSONParserError: Error {
    case invalidFileName(String)
    case mapObject(String, String)
}

extension JSONParserError: LocalizedError {
    var errorDescription: String? {
        var desc: String!
        
        switch self {
            case .invalidFileName(let name): desc = "No such file: " + name + ".json"
            case .mapObject(let objectType, let fileName): desc = "Can't get object of " + objectType  + " type from file: " + fileName
        }
        
        return desc
    }
}
