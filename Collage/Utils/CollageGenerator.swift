/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import UIKit

final class CollageGenerator {
// MARK: - Generate
    
    static func generate(whis collage: CollageMappable,
                         container: UIView,
                         images: [UIImage] = [],
                         filterName: String = "",
                         selectedIndexes: [Int] = [],
                         interacted: Bool = false,
                         imageViewsCallback: (([UIImageView]) -> Void)? = nil) {
        createFilteredImage(whis: filterName, for: images, selected: selectedIndexes) { images in
            let imageViews = self.getImageViews(container)
            var images     = images
            
            if images.isEmpty {
                images = collage.positions.map { _ in UIImage() }
            }
            
            UIView.animate(withDuration: CCollageGenerator.positionAnimationDuration) {
                let collageElemets = makeCollage(collage,
                                                 container: container,
                                                 images: images,
                                                 selectedIndexes: selectedIndexes,
                                                 existingElements: imageViews,
                                                 noInteraction: !interacted)
                
                container.layoutIfNeeded()
                imageViewsCallback?(collageElemets)
            }
        }
    }
    
    private static func getImageViews(_ container: UIView) -> [UIImageView] {
        return container.subviews
            .filter { $0 is UIImageView }
            .map { $0 as! UIImageView }
    }
    
// MARK: - Udate or create collage elements
    
    private static func makeCollage(_ collage: CollageMappable,
                                    container: UIView,
                                    images: [UIImage],
                                    selectedIndexes: [Int],
                                    existingElements imageViews: [UIImageView],
                                    noInteraction: Bool) -> [UIImageView] {
        guard !collage.positions.isEmpty else { return [] }
        
        var collageElements: [UIImageView] = []
        
        for i in 0...collage.positions.count - 1 {
            var collageImageView = UIImageView()
            
            if i < imageViews.count && !imageViews.isEmpty {
                collageImageView = imageViews[i]
            } else { container.addSubview(collageImageView) }
            
            collageElements.append(collageImageView)
            
            if i < images.count {
                configImageView(collageImageView, selected: selectedIndexes.contains(i), noInteraction: noInteraction)
                
                positionView(collageImageView: collageImageView,
                             containerFrame: container.frame,
                             sourceSize: CGSize(width: CGFloat(collage.width), height: CGFloat(collage.height)),
                             pattern: collage.positions[i],
                             image: images[i])
            } else { collageImageView.removeFromSuperview() }
        }
        
        if collageElements.count < imageViews.count {
            for i in collageElements.count...imageViews.count - 1 {
                imageViews[i].removeFromSuperview()
            }
        }
        
        container.layoutIfNeeded()
        
        return collageElements
    }
    
// MARK: - Element position
    
    private static func positionView(collageImageView: UIImageView,
                                     containerFrame: CGRect,
                                     sourceSize: CGSize,
                                     pattern: CollagePositionMappable,
                                     image: UIImage) {
        let partX = CGFloat(Int(containerFrame.width / sourceSize.width))
        let partY = CGFloat(Int(containerFrame.height / sourceSize.height))
        
        collageImageView.frame = CGRect(x: CGFloat(pattern.x) * partX,
                                        y: CGFloat(pattern.y) * partY,
                                        width: CGFloat(pattern.width) * partX,
                                        height: CGFloat(pattern.height) * partY)
        
        if pattern.height < pattern.width {
            if let cgImageFromUIImage = image.cgImage {
                rotateImage(cgImageFromUIImage, originalImageSize: image.size, withRotation: 90 * CGFloat(Double.pi / 180)) { rotatedImage in
                    collageImageView.image = rotatedImage
                }
            } else {// image is CIImage based
                cgImageFrom(ciBased: image, success: { cgImageFromCIImage in
                    rotateImage(cgImageFromCIImage, originalImageSize: image.size, withRotation: 90 * CGFloat(Double.pi / 180)) { rotatedImage in
                        collageImageView.image = rotatedImage
                    }
                }) { return }
            }
        } else { collageImageView.image = image }
    }
    
    private static func configImageView(_ imageView: UIImageView, selected: Bool = false, noInteraction: Bool) {
        imageView.contentMode   = .scaleAspectFill
        imageView.clipsToBounds = true
        
        if noInteraction {
            imageView.layer.borderColor = CCollageGenerator.defBorderColor.cgColor
            imageView.layer.borderWidth = CCollageGenerator.defBorderWidth
        } else {
            imageView.layer.borderColor = (selected ? CCollageGenerator.selectedBorderColor.cgColor : CCollageGenerator.deselectedBorderColor.cgColor)
            imageView.layer.borderWidth = CCollageGenerator.selectedBorderWidth
        }
    }
    
// MARK: - Image processing
    
    static func createFilteredImage(whis name: String, for inputImages: [UIImage], selected: [Int] = [0], success: (([UIImage]) -> Void)?) {
        DispatchQueue.global().async {
            guard !name.isEmpty && !inputImages.isEmpty && !selected.isEmpty else {
                DispatchQueue.main.async { success?(inputImages) }
                
                return
            }

            var filteredImages = inputImages
            
            autoreleasepool {
                for i in 0...inputImages.count - 1 {
                    if !selected.contains(i) { continue }
                    
                    let inputImage = inputImages[i]
                
                    guard let inputCIImage = CIImage(image: inputImage),
                        let filter = CIFilter(name: name) else { continue }
                
                    filter.setDefaults()
                    filter.setValue(inputCIImage, forKey: kCIInputImageKey)
                
                    if let outputImage = filter.outputImage {
                        filteredImages[i] = UIImage(ciImage: outputImage)
                    }
                }
            }
            
            DispatchQueue.main.async { success?(filteredImages) }
        }
    }

    private static func rotateImage(_ cgImage: CGImage, originalImageSize: CGSize, withRotation radians: CGFloat, success: ((UIImage) -> Void)?) {
        DispatchQueue.global().async {
            let largestSize = CGFloat(max(originalImageSize.width, originalImageSize.height))
            
            guard let colorSpace = cgImage.colorSpace,
                let context = CGContext(data: nil,
                                        width: Int(largestSize),
                                        height: Int(largestSize),
                                        bitsPerComponent: cgImage.bitsPerComponent,
                                        bytesPerRow: 0,
                                        space: colorSpace,
                                        bitmapInfo: cgImage.bitmapInfo.rawValue) else { return }
            
            var drawRect    = CGRect.zero
            drawRect.size   = originalImageSize
            drawRect.origin = CGPoint(x: (largestSize - originalImageSize.width) / 2,
                                      y: (largestSize - originalImageSize.height) / 2)
            
            var transform = CGAffineTransform.identity
            transform     = transform.translatedBy(x: largestSize / 2, y: largestSize / 2)
            transform     = transform.rotated(by: CGFloat(radians))
            transform     = transform.translatedBy(x: -largestSize / 2, y: -largestSize / 2)
            
            context.concatenate(transform)
            context.draw(cgImage, in: drawRect)
            
            if let rotatedImage = context.makeImage() {
                drawRect = drawRect.applying(transform)
                
                if let rotatedImage = rotatedImage.cropping(to: drawRect) {
                    let rotatedUIImage = UIImage(cgImage: rotatedImage)
                    
                    DispatchQueue.main.async { success?(rotatedUIImage) }
                }
            }
        }
    }
        
    private static func cgImageFrom(ciBased image: UIImage, success: ((CGImage) -> Void)?, failure: (() -> Void)?) {
        autoreleasepool {
            guard let ciImage = image.ciImage else  {
                failure?()
                
                return
            }
            
            let context = CIContext()
            
            if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                success?(cgImage)
                
                context.clearCaches()
                
                return
            }
            
            context.clearCaches()
            
            failure?()
        }
    }
}

