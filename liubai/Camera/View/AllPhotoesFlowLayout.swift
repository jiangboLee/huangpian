//
//  AllPhotoesFlowLayout.swift
//  liubai
//
//  Created by 李江波 on 2017/3/23.
//  Copyright © 2017年 lijiangbo. All rights reserved.
//

import UIKit

class AllPhotoesFlowLayout: UICollectionViewFlowLayout {
    
    let margin: CGFloat = 3
   
    override init() {
        super.init()
        let itemW = (SCREENW - 2 * margin) / 3
        let itemH = itemW
        itemSize = CGSize(width: itemW, height: itemH)
        scrollDirection = .vertical
        minimumLineSpacing = margin
        minimumInteritemSpacing = margin
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
