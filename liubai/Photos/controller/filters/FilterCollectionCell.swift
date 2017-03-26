//
//  FilterCollectionCell.swift
//  liubai
//
//  Created by 李江波 on 2017/3/24.
//  Copyright © 2017年 lijiangbo. All rights reserved.
//

import UIKit

class FilterCollectionCell: UICollectionViewCell {

    @IBOutlet weak var filterImg: UIImageView!
    
    @IBOutlet weak var filterName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
//        filterImg.layer.cornerRadius = filterImg.bounds.size.width / 2
//        filterImg.clipsToBounds = true
    }

}
