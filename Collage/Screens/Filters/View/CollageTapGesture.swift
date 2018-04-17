/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import UIKit
import UIKit.UIGestureRecognizerSubclass
import RxSwift

final class CollageTapGesture: UITapGestureRecognizer {
    let tapedImageViewIndex = PublishSubject<Int>()
    
// MARK: - UITapGestureRecognizer lifecycle
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        
        guard let subviews = view?.subviews, !subviews.isEmpty else { return }
        
        let loc = self.location(in: self.view)
        
        DispatchQueue.main.async {
            for i in 0...subviews.count - 1 {
                if let imageView = subviews[i] as? UIImageView {
                    let point = imageView.convert(loc, from: self.view)
                    
                    if imageView.bounds.contains(point) {
                        self.tapedImageViewIndex.onNext(i)
                        
                        break
                    }
                }
            }
        }
    }
}
