/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import Foundation

enum CameraCaptureError: Error {
    case device
    case session
    case deviceInput(String)
    case tempFilepath(String)
    case tempFilDelete(String)
    case filepathURL(String)
    case finishRecording(String)
}

extension CameraCaptureError: LocalizedError {
    var errorDescription: String? {
        var desc: String!
        
        switch self {
            case .device: desc = "Can't create captureDevice"
            case .session: desc = "Can't create captureSession"
            case .deviceInput(let localizedDescription): desc = localizedDescription
            case .tempFilepath(let fileName): desc = "Can't get filepath in temp directory for file: " + fileName
            case .tempFilDelete(let localizedDescription): desc = localizedDescription
            case .filepathURL(let path): desc = "Can't create url whis filepath: " + path
            case .finishRecording(let localizedDescription): desc = localizedDescription
        }
        
        return desc
    }
}
