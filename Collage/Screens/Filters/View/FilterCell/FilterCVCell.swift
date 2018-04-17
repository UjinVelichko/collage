/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import UIKit

class FilterCVCell: PickedCollectionViewCell {
    //*** Views
    @IBOutlet weak var imageView: UIImageView!
    //*** Labels
    @IBOutlet weak var filterNameLabel: UILabel!
    
// MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.layer.cornerRadius = layer.cornerRadius
    }
}
