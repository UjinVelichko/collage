/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import UIKit
import RxSwift

class RecordButton: UIButton {
    private var originalRecordLayerCornerRadius: CGFloat = 0
    private var originalRecordLayerSide: CGFloat         = 0
    private var originalRecordLayerPoint                 = CGPoint()
    private var recordLayer                              = CALayer()
    
    let isRecording = PublishSubject<Bool>()
    
    private let disposeBag = DisposeBag()
    
// MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
        subscribeOnStateChanged()
    }
    
    private func setup() {
        let constants = CRecordButton.self
        
        // border
        backgroundColor    = UIColor.clear
        layer.cornerRadius = frame.width / 2
        layer.borderColor  = UIColor.white.cgColor
        layer.borderWidth  = constants.borderWidth
        // record
        layer.addSublayer(recordLayer)
        
        recordLayer.backgroundColor = UIColor.red.cgColor
        recordLayer.frame           = CGRect(x: frame.width * (1 - constants.recordLayerFrameScale) / 2,
                                             y: frame.height * (1 - constants.recordLayerFrameScale) / 2,
                                             width: frame.width * constants.recordLayerFrameScale,
                                             height: frame.height * constants.recordLayerFrameScale)
        recordLayer.cornerRadius    = recordLayer.frame.width / 2
        // original
        originalRecordLayerCornerRadius = recordLayer.cornerRadius
        originalRecordLayerSide         = recordLayer.frame.width
        originalRecordLayerPoint        = CGPoint(x: recordLayer.frame.origin.x, y: recordLayer.frame.origin.y)
    }
    
// MARK: - Interaction events
    
    private func subscribeOnStateChanged() {
        isRecording
            .observeWhisSubscribtion { [weak self] event in
                guard let recording = event.element,
                    let strongSelf = self else { return}
                
                let side   = (recording ? CRecordButton.stopRecordScale : 1)
                let corner = (recording ? strongSelf.originalRecordLayerCornerRadius * CRecordButton.stopRecordCornerScale : strongSelf.originalRecordLayerCornerRadius)
                
                strongSelf.iconChangeAnimation(sideMultiplier: CGFloat(side), cornerTo: corner, duration: CRecordButton.animationDuration)
            }.disposed(by: disposeBag)
    }

// MARK: - Animation
    
    private func iconChangeAnimation(sideMultiplier: CGFloat, cornerTo: CGFloat, duration: CFTimeInterval) {
        DispatchQueue.main.async {
            // bounds
            let oldBounds = self.recordLayer.bounds
            var newBounds = self.recordLayer.bounds
            
            newBounds.size = CGSize(width: self.originalRecordLayerSide * sideMultiplier, height: self.originalRecordLayerSide * sideMultiplier)
            
            let boundsAnimation       = CABasicAnimation(keyPath: "bounds")
            boundsAnimation.fromValue = oldBounds
            boundsAnimation.toValue   = newBounds
            // corner radius
            let cornerRadiusAnimation       = CABasicAnimation(keyPath: "cornerRadius")
            cornerRadiusAnimation.fromValue = self.layer.cornerRadius
            cornerRadiusAnimation.toValue   = cornerTo
            // performing
            let animationGroup            = CAAnimationGroup()
            animationGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            animationGroup.duration       = duration
            animationGroup.animations     = [boundsAnimation, cornerRadiusAnimation]
            
            self.recordLayer.add(animationGroup, forKey: String(describing: CAAnimationGroup.self))
            // setting new values for animated properties
            self.recordLayer.frame = CGRect(x: self.originalRecordLayerPoint.x + self.originalRecordLayerSide * (1 - sideMultiplier) / 2,
                                            y: self.originalRecordLayerPoint.y + self.originalRecordLayerSide * (1 - sideMultiplier) / 2,
                                            width: self.originalRecordLayerSide * sideMultiplier,
                                            height: self.originalRecordLayerSide * sideMultiplier)
            
            self.recordLayer.cornerRadius = cornerTo
        }
    }
}
