//
//  TagCollectionViewCell.swift
//  AJTagLayout
//
//  Created by 张龙 on 2020/8/27.
//  Copyright © 2020 Amiee. All rights reserved.
//

import UIKit

class TagCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.layer.cornerRadius = 4
        contentView.layer.borderColor = UIColor.black.cgColor
        contentView.layer.borderWidth = 1
    }
    
    var tagName = "" {
        didSet {
            label.text = tagName
        }
    }
}
