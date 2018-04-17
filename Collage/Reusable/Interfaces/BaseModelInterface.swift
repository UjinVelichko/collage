/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import Foundation

protocol BaseModelInterface: class {
    init()
    
    func saveImagesAs(data: [Data], onSucces: (() -> Void)?, onError: ((Error) -> Void)?)
    func getPathesToImages() -> [String]?
}

extension BaseModelInterface {
    private func savePathesToImages(_ pathes: [String]) {
        UserDefaults.standard.set(pathes, forKey: CBaseModelInterface.imagesPathKey)
    }
    
    func getPathesToImages() -> [String]? {
        return UserDefaults.standard.stringArray(forKey: CBaseModelInterface.imagesPathKey)
    }
    
    func saveImagesAs(data: [Data], onSucces: (() -> Void)?, onError: ((Error) -> Void)?) {
        guard !data.isEmpty else { return }
        
        DispatchQueue.global().async {
            var pathes: [String] = []
            
            for i in 0...data.count - 1 {
                do {
                    let pathURL = try (CBaseModelInterface.imageName + i.description).tempFilePath()
                    
                    try data[i].write(to: pathURL)
                    
                    pathes.append(pathURL.path)
                } catch { onError?(error) }
            }
            
            self.savePathesToImages(pathes)
            onSucces?()
        }
    }
}

