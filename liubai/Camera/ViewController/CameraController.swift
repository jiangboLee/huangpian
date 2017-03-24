//
//  CameraController.swift
//  liubai
//
//  Created by 李江波 on 2017/2/26.
//  Copyright © 2017年 lijiangbo. All rights reserved.
//

import UIKit
import GPUImage
import SVProgressHUD
import Photos

class CameraController: UIViewController {

    lazy var videoCamera: GPUImageStillCamera = {
        let videoCamera = GPUImageStillCamera(sessionPreset: AVCaptureSessionPresetHigh, cameraPosition: AVCaptureDevicePosition.front)
        videoCamera?.outputImageOrientation = .portrait
        //镜像
        videoCamera?.horizontallyMirrorRearFacingCamera = false
        videoCamera?.horizontallyMirrorFrontFacingCamera = true
        
        return videoCamera!
    }()
    
    var filterVideoView: GPUImageView?
    var filter: GPUImageOutput?
    var flashMode: AVCaptureFlashMode = .off
    var focusLayer: CALayer?
    var beginScale: CGFloat = 1.0
    var endScale: CGFloat = 1.0
    var takePhotoImg: UIImageView?
    //相册属性
    fileprivate var AlbumItems: [AlbumItem] = [] // 相册列表
    fileprivate var imageManager: PHCachingImageManager! //带缓存的图片管理对象
    var albumitemsCount = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blue
        //创建滤镜
        let beautifulFilter = GPUImageSketchFilter()
        //创建预览视图
        let filterView = GPUImageView(frame: self.view.bounds)
        view.addSubview(filterView)
        filterVideoView = filterView
        //为摄像头添加滤镜
        videoCamera.addTarget(beautifulFilter)
        //把滤镜挂在view上
        beautifulFilter.addTarget(filterView)
        
        //设置聚焦图片
        setFocusImage(image: UIImage(named: "11")!)
        
        filter = beautifulFilter
        
        //启动摄像头
        videoCamera.startCapture();
        
        let OrientationButton = UIButton(type: .custom)
        OrientationButton.setTitle("前后摄像头", for: .normal)
        OrientationButton.setTitleColor(UIColor.red, for: .normal)
        view.addSubview(OrientationButton)
        OrientationButton.snp.makeConstraints { (make) in
            make.right.top.equalTo(view)
        }
        OrientationButton.addTarget(self, action: #selector(changeOrientation), for: .touchUpInside)
        
        let mirrorButton = UIButton(type: .custom)
        mirrorButton.setTitle("镜像", for: .normal)
        mirrorButton.setTitleColor(UIColor.red, for: .normal)
        view.addSubview(mirrorButton)
        mirrorButton.snp.makeConstraints { (make) in
            make.top.equalTo(OrientationButton.snp.bottom)
            make.right.equalTo(view)
        }
        mirrorButton.addTarget(self, action: #selector(mirrorChange), for: .touchUpInside)
        
        let flashButton = UIButton(type: .custom)
        flashButton.setTitle("闪光灯", for: .normal)
        flashButton.setTitleColor(UIColor.blue, for: .normal)
        view.addSubview(flashButton)
        flashButton.snp.makeConstraints { (make) in
            make.top.equalTo(mirrorButton.snp.bottom)
            make.right.equalTo(view)
        }
        flashButton.addTarget(self, action: #selector(flashModeChange), for: .touchUpInside)
        
        let takePhotoButton = UIButton(type: .custom)
        takePhotoButton.setTitle("拍照", for: .normal)
        takePhotoButton.setTitleColor(UIColor.brown, for: .normal)
        view.addSubview(takePhotoButton)
        takePhotoButton.snp.makeConstraints { (make) in
            make.top.equalTo(flashButton.snp.bottom)
            make.right.equalTo(view)
        }
        takePhotoButton.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        
        let takePhoto_Save = UIButton(type: .custom)
        takePhoto_Save.setTitle("保存", for: .normal)
        takePhoto_Save.setTitleColor(UIColor.brown, for: .normal)
        view.addSubview(takePhoto_Save)
        takePhoto_Save.snp.makeConstraints { (make) in
            make.top.equalTo(takePhotoButton.snp.bottom)
            make.right.equalTo(view)
        }
        takePhoto_Save.addTarget(self, action: #selector(takePhotoSave), for: .touchUpInside)
        
        let takePhoto_Cancel = UIButton(type: .custom)
        takePhoto_Cancel.setTitle("取消", for: .normal)
        takePhoto_Cancel.setTitleColor(UIColor.brown, for: .normal)
        view.addSubview(takePhoto_Cancel)
        takePhoto_Cancel.snp.makeConstraints { (make) in
            make.top.equalTo(takePhoto_Save.snp.bottom)
            make.right.equalTo(view)
        }
        takePhoto_Cancel.addTarget(self, action: #selector(takePhotoCancel), for: .touchUpInside)
        
        let allPhotoesButton = UIButton(type: .custom)
        allPhotoesButton.setTitle("相册", for: .normal)
        allPhotoesButton.setTitleColor(UIColor.brown, for: .normal)
        view.addSubview(allPhotoesButton)
        allPhotoesButton.snp.makeConstraints { (make) in
            make.top.equalTo(takePhoto_Cancel.snp.bottom)
            make.right.equalTo(view)
        }
        allPhotoesButton.addTarget(self, action: #selector(openAllPhotoes), for: .touchUpInside)
        
    }
    
    //MARK: 打开相簿
    func openAllPhotoes() {
        
        let size = AllPhotoesFlowLayout().itemSize
        let itemArr = getAlbumItem()
        let result = itemArr.first?.fetchResult
        albumitemsCount = 0
        getAlbumItemFetchResults(assetsFetchResults: result!, thumbnailSize: size) { (imageArr,assets) in
            
            let allPhotoesVC = AllPhotosController()
            allPhotoesVC.imageArr = imageArr
            allPhotoesVC.assets = assets
            allPhotoesVC.itemArr = itemArr
            allPhotoesVC.imgArrAdd = {
                
                self.fetchImage(assetsFetchResults: result!, thumbnailSize: size) { (imageArr,assets) in
                    allPhotoesVC.imageArr += imageArr
                    allPhotoesVC.assets? += assets
                }
            }
            allPhotoesVC.coverImg = {
                
                self.getAlbumCoverImg(itemArr, finishedCallBack: { (coverImgArr) in
                    allPhotoesVC.coverImgArr = coverImgArr
                })
            }
            allPhotoesVC.refreshAlbum = { (albumResult) in
                self.albumitemsCount = 0
                self.getAlbumItemFetchResults(assetsFetchResults: albumResult, thumbnailSize: size, finishedCallBack: { (imageArr, assets) in
                    allPhotoesVC.imageArr = imageArr
                    allPhotoesVC.assets = assets
                })
            }
            self.present(allPhotoesVC, animated: true, completion: nil)
        }
        
        
    }
    //MARK: 获取所有相册首页
    func getAlbumCoverImg(_ albumItems: [AlbumItem], finishedCallBack: @escaping (_ result: [UIImage])->()) {
        
        var coverImgArr: [UIImage] = []
        for i in 0..<albumItems.count {
            let album = albumItems[i]
            cachingImageManager()
            imageManager.requestImage(for: album.fetchResult[0], targetSize: CGSize(width: 56, height: 56), contentMode: .aspectFit, options: nil, resultHandler: { (image, _) in
                
                coverImgArr.append(image!)
                if i == albumItems.count - 1 {
                    finishedCallBack(coverImgArr)
                }
            })
        }
    }
    // MARK: - 获取指定的相册缩略图列表
    private func getAlbumItemFetchResults(assetsFetchResults: PHFetchResult<PHAsset>, thumbnailSize: CGSize, finishedCallBack: @escaping (_ result: [UIImage], _ assets: [PHAsset]) -> ()) {
        
        cachingImageManager()
        fetchImage(assetsFetchResults: assetsFetchResults, thumbnailSize: thumbnailSize) { (imageArr,assets) in
            finishedCallBack(imageArr,assets)
        }
    }
    //缓存管理
    fileprivate func cachingImageManager() {
        
        imageManager = PHCachingImageManager()
        imageManager.stopCachingImagesForAllAssets()
    }
    //获取图片
    fileprivate func fetchImage(assetsFetchResults: PHFetchResult<PHAsset>, thumbnailSize: CGSize, finishedCallBack: @escaping (_ imageArr: [UIImage], _ assets: [PHAsset]) -> () ) {
    
        var imageArr: [UIImage] = []
        var assets: [PHAsset] = []
        var a = 0
        if albumitemsCount == assetsFetchResults.count {
            return
        }
        if albumitemsCount < assetsFetchResults.count {
            albumitemsCount += 60
        }
        if albumitemsCount > assetsFetchResults.count {
            a = albumitemsCount - 60
            if a < 0 {
                a = 0
            }
            albumitemsCount = assetsFetchResults.count
        }
        
        for i in ((a > 0) ? (albumitemsCount-60) : a)..<albumitemsCount {
            let asset = assetsFetchResults[i]
            imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFit, options: nil, resultHandler: { (image, nfo) in
                imageArr.append(image!)
                assets.append(asset)
                if i == self.albumitemsCount - 1 {
                    finishedCallBack(imageArr, assets)
                }
            })
        }
    }
    
    // MARK: - 获取相册列表
    func getAlbumItem() -> [AlbumItem] {
        AlbumItems.removeAll()
        let smartOptions = PHFetchOptions()
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: smartOptions)
        self.convertCollection(smartAlbums as! PHFetchResult<AnyObject>)
        
        let userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        convertCollection(userCollections as! PHFetchResult<AnyObject>)
        //相册按包含的照片数量排序（降序）
        AlbumItems.sort { (item1, item2) -> Bool in
            return item1.fetchResult.count > item2.fetchResult.count
        }
        return AlbumItems
    }
    //转化处理获取到的相簿
    private func convertCollection(_ collection: PHFetchResult<AnyObject>) {
        
        for i in 0..<collection.count {
            let resultsOptions = PHFetchOptions()
            resultsOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            resultsOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            guard let c = collection[i] as? PHAssetCollection else { return  }
            let assetsFetchResult = PHAsset.fetchAssets(in: c, options: resultsOptions)
            //没有图片的空相簿不显示
            if assetsFetchResult.count > 0 {
                AlbumItems.append(AlbumItem(title: c.localizedTitle, fetchResult: assetsFetchResult))
            }
            
        }
    }
    
    //MARK: 拍照
    func takePhoto() {
        videoCamera.capturePhotoAsImageProcessedUp(toFilter: filter) { (photo: UIImage?, error: Error?) in
            
            guard let img = photo else {return}
            self.takePhotoImg = UIImageView(image: img)
            self.takePhotoImg!.frame = self.filterVideoView!.bounds
            self.filterVideoView?.addSubview(self.takePhotoImg!)
        }
    }
    
    func takePhotoSave() {
        
        let lastStatus = PHPhotoLibrary.authorizationStatus()
        PHPhotoLibrary.requestAuthorization { (status) in
            //回到主线程
            DispatchQueue.main.async {
                if status == PHAuthorizationStatus.denied {
                    if lastStatus == PHAuthorizationStatus.notDetermined {
                    
                        SVProgressHUD.showError(withStatus: "保存失败")
                        return
                    }
                    SVProgressHUD.showError(withStatus: "失败！请在系统设置中开启访问相册权限")
                } else if status == PHAuthorizationStatus.authorized {
                    self.saveImageToCustomAblum()
                } else if status == PHAuthorizationStatus.restricted {
                    SVProgressHUD.showError(withStatus: "系统原因，无法访问相册")
                }
            }
        }
    }
    
    func saveImageToCustomAblum() {
        guard let assets = asyncSaveImageWithPhotos() else {
            SVProgressHUD.showError(withStatus: "保存失败")
            return
        }
        guard let assetCollection = getAssetCollectionWithAppNameAndCreateIfNo()
        else {
            SVProgressHUD.showError(withStatus: "相册创建失败")
            return
        }
        PHPhotoLibrary.shared().performChanges({ 
            
            let collectionChangeRequest = PHAssetCollectionChangeRequest(for: assetCollection)
            collectionChangeRequest?.insertAssets(assets, at: IndexSet(integer: 0))
        }) { (success, error) in
            
            if success {
                SVProgressHUD.showSuccess(withStatus: "保存成功")
                DispatchQueue.main.async {
                    
                    self.takePhotoImg?.isHidden = true
                    self.takePhotoImg?.removeFromSuperview()
                }
            } else {
                SVProgressHUD.showError(withStatus: "保存失败")
            }
        }
        
        
    }
    //同步方式保存图片到系统的相机胶卷中---返回的是当前保存成功后相册图片对象集合
    func asyncSaveImageWithPhotos() -> PHFetchResult<PHAsset>? {
        
        var createdAssetID = ""
        let error: ()? = try? PHPhotoLibrary.shared().performChangesAndWait {
            createdAssetID = (PHAssetChangeRequest.creationRequestForAsset(from: (self.takePhotoImg?.image)!).placeholderForCreatedAsset?.localIdentifier)!
        }
        if error == nil {
            SVProgressHUD.showError(withStatus: "保存失败")
            return nil
        } else {
            SVProgressHUD.showSuccess(withStatus: "保存成功")
            return PHAsset.fetchAssets(withLocalIdentifiers: [createdAssetID], options: nil)
        }
        
    }
    //拥有与 APP 同名的自定义相册--如果没有则创建
    func getAssetCollectionWithAppNameAndCreateIfNo() -> PHAssetCollection? {
        let title = Bundle.main.infoDictionary?[String(kCFBundleNameKey)] as? String
        let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        for i in 0..<collections.count {
            if title == collections[i].localizedTitle {
                return collections[i]
            }
        }
        var createID = ""
        let error: ()? = try? PHPhotoLibrary.shared().performChangesAndWait {
            let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: title!)
            createID = request.placeholderForCreatedAssetCollection.localIdentifier
        }
        if error == nil {
            return nil
        } else {
            return PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [createID], options: nil).firstObject!
        }
    }
   
    func takePhotoCancel() {
        
        self.takePhotoImg?.isHidden = true
        self.takePhotoImg?.removeFromSuperview()
    }
    
    //MARK: 聚焦
    func setFocusImage(image: UIImage) {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(focus(tap:)))
        filterVideoView?.addGestureRecognizer(tap)
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(focusDisdance(pinch:)))
        filterVideoView?.addGestureRecognizer(pinch)
        pinch.delegate = self
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        imageView.image = image
        focusLayer = imageView.layer
        filterVideoView?.layer.addSublayer(focusLayer!)
        focusLayer?.isHidden = true
    }
    
    func focus(tap: UITapGestureRecognizer) {
        
        filterVideoView?.isUserInteractionEnabled = false
        var touchPoint = tap.location(in: tap.view)
        layerAnimationWithPoint(point: touchPoint)
        
        if videoCamera.cameraPosition() == AVCaptureDevicePosition.back {
            
            touchPoint = CGPoint(x: touchPoint.y / (tap.view?.bounds.size.height)!, y:1 - touchPoint.x / (tap.view?.bounds.size.width)!)
        } else {
        
            touchPoint = CGPoint(x: touchPoint.y / (tap.view?.bounds.size.height)!, y: touchPoint.x / (tap.view?.bounds.size.width)!)
        }
        if videoCamera.inputCamera.isExposureModeSupported(.autoExpose) && videoCamera.inputCamera.isExposurePointOfInterestSupported {
            
            try? videoCamera.inputCamera.lockForConfiguration()
            videoCamera.inputCamera.exposurePointOfInterest = touchPoint
            videoCamera.inputCamera.exposureMode = .autoExpose
            
            if videoCamera.inputCamera.isFocusPointOfInterestSupported && videoCamera.inputCamera.isFocusModeSupported(.autoFocus) {
                
                videoCamera.inputCamera.focusPointOfInterest = touchPoint
                videoCamera.inputCamera.focusMode = .autoFocus
            }
            videoCamera.inputCamera.unlockForConfiguration()
        }
    }
    
    /// 聚焦动画
    func layerAnimationWithPoint(point: CGPoint) {
        
        guard let fLayer = focusLayer else {
            return
        }
        fLayer.isHidden = false
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        fLayer.position = point
        fLayer.transform = CATransform3DMakeScale(2.0, 2.0, 1.0)
        CATransaction.commit()
        
        let animation = CABasicAnimation(keyPath: "transform")
        animation.toValue = NSValue.init(caTransform3D: CATransform3DMakeScale(1.0, 1.0, 1.0))
        animation.delegate = self
        animation.duration = 0.3
        animation.repeatCount = 1
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        fLayer.add(animation, forKey: "animation")
        
    }
    
    func focusDisdance(pinch: UIPinchGestureRecognizer) {
        
        endScale = beginScale * pinch.scale
        if endScale < 1.0 {
            endScale = 1.0
        }
        let maxScale: CGFloat = 4.0
        if endScale > maxScale {
            endScale = maxScale
        }
        UIView.animate(withDuration: 0.25) {
            
            try? self.videoCamera.inputCamera.lockForConfiguration()
            self.videoCamera.inputCamera.videoZoomFactor = self.endScale
            self.videoCamera.inputCamera.unlockForConfiguration()
        }
   
    }
    
    //MARK: 开关闪光灯
    //开关闪光灯
    func flashModeChange() {
        if flashMode == .off {
            
            if videoCamera.inputCamera.hasFlash && videoCamera.inputCamera.hasTorch {
                
                try? videoCamera.inputCamera.lockForConfiguration()
                if videoCamera.inputCamera.isTorchModeSupported(.on) {
                    
                    videoCamera.inputCamera.torchMode = .on
                    videoCamera.inputCamera.flashMode = .on
                    flashMode = .on
                }
                videoCamera.inputCamera.unlockForConfiguration()
            } else {
            
                LJBAlertView.sharedAlertView.alert(titleName: "提示", message: "只有后置摄像头支持闪光灯哦😁", buttonTitle: "确定", tager: self)
                
            }
        } else {
            if videoCamera.inputCamera.hasFlash && videoCamera.inputCamera.hasTorch {
                
                try? videoCamera.inputCamera.lockForConfiguration()
                if videoCamera.inputCamera.isTorchModeSupported(.off) {
                    
                    videoCamera.inputCamera.torchMode = .off
                    videoCamera.inputCamera.flashMode = .off
                    flashMode = .off
                }
                videoCamera.inputCamera.unlockForConfiguration()
            }
        }
    }
    //MARK: 镜像变化
    /// 镜像变化
    func mirrorChange() {
        
        if videoCamera.horizontallyMirrorFrontFacingCamera == false {
            
            videoCamera.horizontallyMirrorFrontFacingCamera = true
        } else {
        
            videoCamera.horizontallyMirrorFrontFacingCamera = false
        }
    }
    //MARK: 前后摄像头转换
    /// 前后摄像头转换
    func changeOrientation() {
        
        videoCamera.stopCapture()
        if videoCamera.cameraPosition() == AVCaptureDevicePosition.front {
            
            videoCamera = GPUImageStillCamera(sessionPreset: AVCaptureSessionPresetHigh, cameraPosition: AVCaptureDevicePosition.back)
        } else if videoCamera.cameraPosition() == AVCaptureDevicePosition.back {
            
            videoCamera = GPUImageStillCamera(sessionPreset: AVCaptureSessionPresetPhoto, cameraPosition: AVCaptureDevicePosition.front)
        }
        videoCamera.outputImageOrientation = UIInterfaceOrientation.portrait
        //镜像
        videoCamera.horizontallyMirrorRearFacingCamera = false
        videoCamera.horizontallyMirrorFrontFacingCamera = true
        
        videoCamera.addTarget(filter as! GPUImageInput!)
        filter?.addTarget(filterVideoView)
        
        beginScale = 1.0
        endScale = 1.0
        
        videoCamera.startCapture()
    }
    
    deinit {
        cachingImageManager()
        AlbumItems = []
    }

}

extension CameraController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer.isKind(of: UIPinchGestureRecognizer.self) {
            
            beginScale = endScale
        }
        return true
    }
}

extension CameraController: CAAnimationDelegate {

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        perform(#selector(focusLayerNormal), with: self, afterDelay: 0.5)
    }
    
    func focusLayerNormal() {
        
        filterVideoView?.isUserInteractionEnabled = true
        focusLayer?.isHidden = true
    }
}

// MARK:- =============相册
class AlbumItem {
    //相簿名称
    var title: String?
    //相簿内资源
    var fetchResult: PHFetchResult<PHAsset>
    init(title: String?, fetchResult: PHFetchResult<PHAsset>) {
        self.title = title
        self.fetchResult = fetchResult
    }
}
