/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import Foundation

extension String {
    func tempFilePath() throws -> URL {
        guard let tempPath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(self)?.absoluteString else {
            throw CameraCaptureError.tempFilepath(self)
        }
        
        if FileManager.default.fileExists(atPath: tempPath) {
            do {
                try FileManager.default.removeItem(atPath: tempPath)
            }
        }
        
        if let urlPath = URL(string: tempPath) {
            return urlPath
        } else { throw CameraCaptureError.filepathURL(tempPath) }
    }
}
