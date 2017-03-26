//
//  FilterCollectionView.swift
//  liubai
//
//  Created by 李江波 on 2017/3/24.
//  Copyright © 2017年 lijiangbo. All rights reserved.
//

import UIKit

class FilterCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource {

    let FilterCollectionViewCellID = "FilterCollectionViewCellID"
    let filterImgArr = ["美颜", "原图", "怀旧", "绿巨人", "卡通", "素描", "水晶球效果", "浮雕效果", "上下模糊中间清晰"]
    var clickItem: ((_ item: Int)->())?
    
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: CGRect(x: 0, y: 0, width: SCREENW, height: 80), collectionViewLayout: FilterCollectionViewFlowLayout())
        backgroundColor = UIColor.clear
        delegate = self
        dataSource = self
        bounces = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        register(UINib(nibName: "FilterCollectionCell", bundle: nil), forCellWithReuseIdentifier: FilterCollectionViewCellID)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterImgArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCollectionViewCellID, for: indexPath) as! FilterCollectionCell
        
        cell.filterName.text = filterImgArr[indexPath.row]
        cell.filterImg.image = UIImage(named: "11")?.circleImage()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        clickItem?(indexPath.item)
    }

}

class FilterCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        let margin: CGFloat = 8.0
        let width = (SCREENW - margin * 4.0) / 5.0
        itemSize = CGSize(width: width, height: width)
        minimumLineSpacing = margin
        minimumInteritemSpacing = 0
        scrollDirection = .horizontal
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
