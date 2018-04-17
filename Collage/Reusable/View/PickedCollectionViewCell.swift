/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import UIKit

class PickedCollectionViewCell: UICollectionViewCell {
// MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUI()
    }
    
    override var isSelected: Bool {
        didSet {
            super.isSelected = isSelected
            
            performSelectAnimation()
        }
    }
    
// MARK: - Setup
    
    private func setUI() {
        layer.cornerRadius = CPickedCollectionViewCell.corner
        backgroundColor    = CPickedCollectionViewCell.defColor
    }
    
    // MARK: - Select animation
    
    private func performSelectAnimation() {
        UIView.animate(withDuration: CPickedCollectionViewCell.selectionAnimationDuration) {
            if self.isSelected {
                self.backgroundColor = CPickedCollectionViewCell.selectedColor
            } else { self.backgroundColor = CPickedCollectionViewCell.defColor  }
            
            self.superview?.layoutIfNeeded()
        }
    }
}

