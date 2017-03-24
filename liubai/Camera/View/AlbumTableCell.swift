//
//  AlbumTableCell.swift
//  liubai
//
//  Created by 李江波 on 2017/3/23.
//  Copyright © 2017年 lijiangbo. All rights reserved.
//

import UIKit

class AlbumTableCell: UITableViewCell {

    @IBOutlet weak var albumCount: UILabel!
    @IBOutlet weak var albumTitle: UILabel!
    @IBOutlet weak var coverImage: UIImageView!
    
    var item: AlbumItem? {
    
        didSet {
        
            albumTitle.text = item?.title
            albumCount.text = String.init(format: "%d", (item?.fetchResult.count)!) + "张"
        }
    }
    var cover: UIImage? {
    
        didSet {
            
            coverImage.image = cover
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    
}
