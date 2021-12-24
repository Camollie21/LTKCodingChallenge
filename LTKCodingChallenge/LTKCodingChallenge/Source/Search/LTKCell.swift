//
//  LTKCell.swift
//  LTKCodingChallenge
//
//  Created by Cameron Ollivierre on 12/22/21.
//

import Foundation
import UIKit

class LTKCell:UITableViewCell {
   
    @IBOutlet weak var poster: UIImageView?
    
    var onReuse: () -> Void = {}
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onReuse()
        poster?.image = nil
      }
}
