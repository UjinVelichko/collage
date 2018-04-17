/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import ObjectMapper

final class CollagePatternModel: CapturePatternModelInterface {    
    func getCollagePatterns(onSucces: (([CollageMappable]) -> Void)?, onError: ((Error) -> Void)?) {
        JSONParser.loadJSON(name: CResources.JSON.patterns, result: CollagePatternsMappable.self, onSuccess: { collage in
            onSucces?(collage.patterns)
        }, onError: onError)
    }
}
