//
//  ProductCell.swift
//  LTKCodingChallenge
//
//  Created by Cameron Ollivierre on 12/23/21.
//

import Foundation
import UIKit

class ProductCell:UITableViewCell {
    @IBOutlet weak var productImage: UIImageView?
    
    var onReuse: () -> Void = {}
    
    /* to prevent left over images mismatching with the text while the new image loads
     we set the cell poster image to nil before reuse */
    override func prepareForReuse() {
        super.prepareForReuse()
        onReuse()
        productImage?.image = nil
      }
}
