//
//  AllPhotosController.swift
//  liubai
//
//  Created by 李江波 on 2017/3/23.
//  Copyright © 2017年 lijiangbo. All rights reserved.
//

import UIKit
import Photos
import SVProgressHUD

class AllPhotosController: UIViewController {

    let collectionCellID = "collectionCellID"
    let tableView_CellID = "tableView_CellID"
    
    var imageArr = [UIImage]() {
    
        didSet{
            photoesCollection?.reloadData()
        }
    }
    var assets: [PHAsset]?
    var photoesCollection: UICollectionView?
    var a: CGFloat = 0.1
    var imgArrAdd: ((_ albumResult: PHFetchResult<PHAsset>)->())?
    var aboveView: UIView!
    //相册集合
    lazy var albumTableV: UITableView = {
        let tableV = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        tableV.delegate = self
        tableV.dataSource = self
        tableV.rowHeight = 60
        return tableV
    }()
    var itemArr: [AlbumItem]? {
        
        didSet{
            albumTableV.reloadData()
        }
    }
    var coverImg: (()->())?
    var coverImgArr = [UIImage]() {
        
        didSet {
            albumTableV.reloadData()
        }
    }
    //选取相册后重新刷新
    var refreshAlbum: ((_ albumResult: PHFetchResult<PHAsset>)->())?
    //当前目标相册
    var nowAlbum: PHFetchResult<PHAsset>?
    var chooseAlbumButton: UIButton!
    var isSelect: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        aboveView = UIView()
        aboveView.backgroundColor = UIColor.red
        view.addSubview(aboveView)
        aboveView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(view)
            make.height.equalTo(view).multipliedBy(0.1)
        }
        aboveView.layoutIfNeeded()
        
        let backButton = UIButton(type: .custom)
        backButton.setTitle("返回", for: .normal)
        backButton.setTitleColor(UIColor.blue, for: .normal)
        aboveView.addSubview(backButton)
        backButton.snp.makeConstraints { (make) in
            make.width.equalTo(70)
            make.height.equalTo(aboveView)
            make.left.top.equalTo(aboveView)
        }
        backButton.addTarget(self, action: #selector(backButtonClick), for: .touchUpInside)
        
        chooseAlbumButton = UIButton(type: .custom)
        chooseAlbumButton.setTitle("选取相册", for: .normal)
        chooseAlbumButton.setTitleColor(UIColor.blue, for: .normal)
        aboveView.addSubview(chooseAlbumButton)
        chooseAlbumButton.snp.makeConstraints { (make) in
            make.width.equalTo(100)
            make.height.equalTo(aboveView)
            make.centerX.top.equalTo(aboveView)
        }
        chooseAlbumButton.addTarget(self, action: #selector(chooseAlbumButtonClick), for: .touchUpInside)
        
        let photoCollection = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: AllPhotoesFlowLayout())
        photoCollection.backgroundColor = UIColor.white
        view.insertSubview(photoCollection, belowSubview: aboveView)
        photoCollection.snp.makeConstraints { (make) in
            make.right.left.bottom.equalTo(view)
            make.top.equalTo(aboveView.snp.bottom)
        }
        
        photoCollection.delegate = self
        photoCollection.dataSource = self
        photoCollection.register(UINib(nibName: "AllPhotoCollectionCell", bundle: nil), forCellWithReuseIdentifier: collectionCellID)
        photoesCollection = photoCollection
        
        albumTableV.register(UINib(nibName: "AlbumTableCell", bundle: nil), forCellReuseIdentifier: tableView_CellID)
        view.insertSubview(albumTableV, belowSubview: aboveView)
        albumTableV.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.height.equalTo(SCREENH * 0.35)
            make.bottom.equalTo(aboveView)
        }
    }
    
    func backButtonClick() {
        albumTableV.isHidden = true
        dismiss(animated: true, completion: nil)
    }
    //MARK: 点击选择相册
    func chooseAlbumButtonClick() {
        let isS = !isSelect
        if isS {
            isSelect = true
            coverImg?()
            UIView.animate(withDuration: 0.8) {
                
                self.albumTableV.frame.origin.y = SCREENH * 0.1
            }
        } else {
            isSelect = false
            UIView.animate(withDuration: 0.8) {
                self.albumTableV.frame.origin.y = -SCREENH * 0.4
            }
        }
    }
  
    override func viewWillAppear(_ animated: Bool) {
        photoesCollection?.isUserInteractionEnabled = true
    }
}

extension AllPhotosController: UICollectionViewDelegate,UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return imageArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionCellID, for: indexPath) as! AllPhotoCollectionCell
        cell.photo = imageArr[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let opetions = PHImageRequestOptions()
        //允许从iCloud下载
        opetions.isNetworkAccessAllowed = true
        a = 0.1
        let timer = Timer(timeInterval: 0.4, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .commonModes)
        
        PHImageManager.default().requestImage(for: (assets![indexPath.item]), targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: opetions) { (image, _) in
            timer.invalidate()
            SVProgressHUD.dismiss()
            guard let img = image else {
                SVProgressHUD.showError(withStatus: "此照片保存在iCloud,您没有联网，无法下载哦")
                return
            }
            let photosVC = PhotosController()
            photosVC.chooseImage = img.imgScale(width: SCREENW)
            self.present(photosVC, animated: true, completion: nil)
        }
        collectionView.isUserInteractionEnabled = false
    }
    
    func timerAction() {
        if a < 0.8 {
            a += 0.1
        }
        SVProgressHUD.showProgress(Float(a), status: "正在从iCloud下载")
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.item == imageArr.count - 9 {
            imgArrAdd?(nowAlbum!)
        }
    }
}

extension AllPhotosController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return itemArr?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: tableView_CellID, for: indexPath) as! AlbumTableCell
        cell.item = itemArr?[indexPath.row]
        if coverImgArr.count > 0 {
            
            cell.cover = coverImgArr[indexPath.row]
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let albumResult = itemArr?[indexPath.row].fetchResult
        nowAlbum = albumResult
        refreshAlbum?(albumResult!)
        imageArr.removeAll()
        assets?.removeAll()
        UIView.animate(withDuration: 0.8) {
            self.albumTableV.frame.origin.y = -SCREENH * 0.4
        }
    }
}
