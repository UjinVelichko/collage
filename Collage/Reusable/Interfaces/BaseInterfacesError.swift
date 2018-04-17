/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import Foundation

enum BaseInterfacesError: Error {
    case viewModel(String, String)
    case model(String, String)
    case initialData(String, String)
}

extension BaseInterfacesError: LocalizedError {
    var errorDescription: String? {
        var desc: String!
        
        switch self {
            case .viewModel(let expectedType, let currentType): desc = "ViewModel must be " + expectedType + " not - " + currentType
            case .model(let expectedType, let currentType): desc = "Model must be " + expectedType + " not - " + currentType
            case .initialData(let expectedType, let currentType): desc = "Initial data must be " + expectedType + " not - " + currentType
        }
        
        return desc
    }
}
