//
//  AllPhotoCollectionCell.swift
//  liubai
//
//  Created by 李江波 on 2017/3/23.
//  Copyright © 2017年 lijiangbo. All rights reserved.
//

import UIKit

class AllPhotoCollectionCell: UICollectionViewCell {

    @IBOutlet weak var img: UIImageView!
    
    var photo: UIImage? {
        didSet{
            img.image = photo
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    
}
