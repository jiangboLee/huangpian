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
    //带缓存的图片管理对象
    lazy var imageManager = PHCachingImageManager()
    var albumitemsCount = 0
    
    //滤镜视图
    lazy var filterView: FilterCollectionView = {
        let filterView = FilterCollectionView()
        filterView.clickItem = { (i) in
            
            self.chooseFilter(i)
        }
        self.view.addSubview(filterView)
        filterView.snp.makeConstraints({ (make) in
            make.right.left.equalTo(self.view)
            make.height.equalTo(80)
            make.bottom.equalTo(self.view).offset(-80)
        })
        return filterView
    }()
    
    var clearView: UIView!
    //按钮
    var closeButton: UIButton!
    var OrientationButton: UIButton!
    var flashButton: UIButton!
    var mirrorButton: UIButton!
    var allPhotoesButton: UIButton!
    var takePhotoButton: UIButton!
    var filterButton: UIButton!
    //保存按钮
    lazy var takePhoto_Save: UIButton = {
        let takePhoto_Save = UIButton(type: .custom)
        takePhoto_Save.setBackgroundImage(#imageLiteral(resourceName: "save_icon_save"), for: .normal)
        self.view.addSubview(takePhoto_Save)
        takePhoto_Save.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view).offset(-12)
            make.centerX.equalTo(self.view)
        }
        takePhoto_Save.addTarget(self, action: #selector(takePhotoSave), for: .touchUpInside)
        return takePhoto_Save
    }()
    //取消按钮
    lazy var takePhoto_Cancel: UIButton = {
        let takePhoto_Cancel = UIButton(type: .custom)
        takePhoto_Cancel.setBackgroundImage(#imageLiteral(resourceName: "save_icon_back"), for: .normal)
        self.view.addSubview(takePhoto_Cancel)
        takePhoto_Cancel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.takePhoto_Save)
            make.left.equalTo(self.view).offset(18)
        }
        takePhoto_Cancel.addTarget(self, action: #selector(takePhotoCancel), for: .touchUpInside)
        return takePhoto_Cancel
    }()
    //分享按钮
    lazy var takePhoto_Share: UIButton = {
        let takePhoto_Share = UIButton(type: .custom)
        takePhoto_Share.setBackgroundImage(#imageLiteral(resourceName: "save_icon_share"), for: .normal)
        self.view.addSubview(takePhoto_Share)
        takePhoto_Share.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.takePhoto_Save)
            make.right.equalTo(self.view).offset(-18)
        }
        takePhoto_Share.addTarget(self, action: #selector(sharePhoto), for: .touchUpInside)
        return takePhoto_Share
    }()
    
    //是否拍照还是照片处理
    var isTakePhoto: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        //创建滤镜
        let beautifulFilter = GPUImageBeautifyFilter()
        //创建预览视图
        let filterView = GPUImageView(frame: self.view.bounds)
        view.addSubview(filterView)
        filterVideoView = filterView
        //为摄像头添加滤镜
        videoCamera.addTarget(beautifulFilter)
        //把滤镜挂在view上
        beautifulFilter.addTarget(filterView)
        
        filter = beautifulFilter
        
        //启动摄像头
//        videoCamera.startCapture();
        
        //所有按钮的父视图
        clearView = UIView(frame: view.bounds)
        clearView.backgroundColor = UIColor.clear
//        clearView.isUserInteractionEnabled = false
        view.addSubview(clearView)
        
        //设置聚焦图片
        setFocusImage(image: #imageLiteral(resourceName: "takepic_icon_focus"))
        
        //关闭
        closeButton = UIButton(type: .custom)
        closeButton.setBackgroundImage(#imageLiteral(resourceName: "takepic_icon_close"), for: .normal)
        clearView.addSubview(closeButton)
        closeButton.snp.makeConstraints { (make) in
            make.top.equalTo(view).offset(15)
            make.left.equalTo(view).offset(15)
        }
        closeButton.addTarget(self, action: #selector(closeClick), for: .touchUpInside)
        
        //切换摄像头按钮
        OrientationButton = UIButton(type: .custom)
        OrientationButton.setBackgroundImage(#imageLiteral(resourceName: "takepic_icon_reverse"), for: .normal)
        clearView.addSubview(OrientationButton)
        OrientationButton.snp.makeConstraints { (make) in
            make.right.equalTo(view).offset(-22)
            make.centerY.equalTo(closeButton)
        }
        OrientationButton.addTarget(self, action: #selector(changeOrientation), for: .touchUpInside)
        
        clearView.layoutSubviews() //提前确定约束
        //闪光灯
        flashButton = UIButton(type: .custom)
        flashButton.setBackgroundImage(#imageLiteral(resourceName: "takepic_icon_flashlight_normal"), for: .normal)
        clearView.addSubview(flashButton)
        let width = (OrientationButton.center.x - closeButton.center.x) / 3
        flashButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(closeButton)
            make.centerX.equalTo(OrientationButton).offset(-width)
        }
        flashButton.addTarget(self, action: #selector(flashModeChange(button:)), for: .touchUpInside)
        
        //镜像
        mirrorButton = UIButton(type: .custom)
        mirrorButton.setBackgroundImage(#imageLiteral(resourceName: "takepic_icon_mirror"), for: .normal)
        clearView.addSubview(mirrorButton)
        mirrorButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(closeButton)
            make.centerX.equalTo(closeButton).offset(width)
        }
        mirrorButton.addTarget(self, action: #selector(mirrorChange), for: .touchUpInside)
        
        //拍照
        takePhotoButton = UIButton(type: .custom)
        takePhotoButton.setBackgroundImage(#imageLiteral(resourceName: "takepic_icon_takepicButton"), for: .normal)
        clearView.addSubview(takePhotoButton)
        takePhotoButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(view).offset(-30)
            make.centerX.equalTo(view)
        }
        takePhotoButton.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
    
        //相册按钮
        allPhotoesButton = UIButton(type: .custom)
        allPhotoesButton.setBackgroundImage(#imageLiteral(resourceName: "takepic_icon_photoAlbum"), for: .normal)
        clearView.addSubview(allPhotoesButton)
        allPhotoesButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(takePhotoButton)
            make.right.equalTo(takePhotoButton.snp.left).offset(-76.5)
        }
        allPhotoesButton.addTarget(self, action: #selector(openAllPhotoes), for: .touchUpInside)
        //滤镜按钮
        filterButton = UIButton(type: .custom)
        filterButton.setBackgroundImage(#imageLiteral(resourceName: "takepic_icon_filter"), for: .normal)
        clearView.addSubview(filterButton)
        filterButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(takePhotoButton)
            make.left.equalTo(takePhotoButton.snp.right).offset(76.5)
        }
        filterButton.addTarget(self, action: #selector(openFilters(button:)), for: .touchUpInside)
    }
    
    //MARK: 关闭
    func closeClick() {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: 点开滤镜
    func openFilters(button: UIButton) {
        button.isSelected = !button.isSelected
        if button.isSelected {
            
            filterView.isHidden = false
            takePhotoButton.setBackgroundImage(#imageLiteral(resourceName: "takepic_filter_icon_elected"), for: .normal)
            takePhotoButton.snp.updateConstraints({ (make) in
                make.bottom.equalTo(view).offset(-8)
            })
        } else {
        
            filterView.isHidden = true
            takePhotoButton.setBackgroundImage(#imageLiteral(resourceName: "takepic_icon_takepicButton"), for: .normal)
            takePhotoButton.snp.updateConstraints({ (make) in
                make.bottom.equalTo(view).offset(-30)
            })
        }
    }
    //选择滤镜
    func chooseFilter(_ item: Int) {
        
        videoCamera.removeAllTargets()
        switch item {
        case 0:
            filter = GPUImageBeautifyFilter()
            break
        case 1:
            filter = GPUImageFilter()
            break
        case 2:
            filter = GPUImageSepiaFilter()
            break
        case 3:
            filter = GPUImageHueFilter()
            break
        case 4:
            filter = GPUImageSmoothToonFilter()
            break
        case 5:
            filter = GPUImageSketchFilter()
            break
        case 6:
            filter = GPUImageGlassSphereFilter()
            break
        case 7:
            filter = GPUImageEmbossFilter()
            break
        case 8:
            filter = GPUImageTiltShiftFilter()
            break
        default:
            break
        }
        videoCamera.addTarget(filter as! GPUImageInput!)
        filter?.addTarget(filterVideoView)
    }
    
    //MARK: 打开相簿
    func openAllPhotoes() {
        
        let size = AllPhotoesFlowLayout().itemSize
        let itemArr = getAlbumItem()
        let result1 = itemArr.first?.fetchResult
        albumitemsCount = 0
        guard let result = result1 else { return  }
        getAlbumItemFetchResults(assetsFetchResults: result, thumbnailSize: size) { (imageArr,assets) in
            
            let allPhotoesVC = AllPhotosController()
            allPhotoesVC.imageArr = imageArr
            allPhotoesVC.assets = assets
            allPhotoesVC.itemArr = itemArr
            allPhotoesVC.nowAlbum = result
            allPhotoesVC.imgArrAdd = { (nowAlbum) in
                
                self.fetchImage(assetsFetchResults: nowAlbum, thumbnailSize: size) { (imageArr,assets) in
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
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            imageManager.requestImage(for: album.fetchResult[0], targetSize: CGSize(width: 56, height: 56), contentMode: .aspectFit, options: options, resultHandler: { (image, _) in
                
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

        imageManager.stopCachingImagesForAllAssets()
    }
    //获取图片
    fileprivate func fetchImage(assetsFetchResults: PHFetchResult<PHAsset>, thumbnailSize: CGSize, finishedCallBack: @escaping (_ imageArr: [UIImage], _ assets: [PHAsset]) -> () ) {
    
        var imageArr: [UIImage] = []
        var assets: [PHAsset] = []
        var a = -1
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
        
        for i in ((a == -1) ? (albumitemsCount-60) : a)..<albumitemsCount {
            let asset = assetsFetchResults[i]
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            options.isNetworkAccessAllowed = true
            imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFit, options: options, resultHandler: { (image, nfo) in
                imageArr.append(image!)
                assets.append(asset)
                //!!!一定要回到主线程刷新
                DispatchQueue.main.async {
                    
                    if i == self.albumitemsCount - 1 {
                        finishedCallBack(imageArr, assets)
                        return
                    }
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
            self.clearView.isHidden = true
            self.filterView.isHidden = true
            self.takePhoto_Save.isHidden = false
            self.takePhoto_Cancel.isHidden = false
            self.takePhoto_Share.isHidden = false
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
                    
                    self.takePhotoCancel()
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
    //MARK: 分享
    func sharePhoto() {
        
        UMSocialShareUIConfig.shareInstance().shareTitleViewConfig.isShow = true
        UMSocialShareUIConfig.shareInstance().shareTitleViewConfig.shareTitleViewTitleString = "分享至"
        UMSocialShareUIConfig.shareInstance().sharePageGroupViewConfig.sharePageGroupViewPostionType = .bottom
        UMSocialShareUIConfig.shareInstance().sharePageScrollViewConfig.shareScrollViewPageMaxColumnCountForPortraitAndBottom = 3
        UMSocialShareUIConfig.shareInstance().shareCancelControlConfig.isShow = false
        UMSocialShareUIConfig.shareInstance().shareContainerConfig.isShareContainerHaveGradient = false
        
        UMSocialUIManager.showShareMenuViewInWindow { (platformType, userInfo) in
            
            let messageObject = UMSocialMessageObject.init()
            let shareObject = UMShareImageObject.init()
            shareObject.thumbImage = UIImage(named: "AppIcon")
            shareObject.shareImage = self.takePhotoImg?.image
            messageObject.shareObject = shareObject
            UMSocialManager.default().share(to: platformType, messageObject: messageObject, currentViewController: self, completion: { (data, error) in
                
                if error != nil {
                
                } else {
                
                }
            })
        }
    }
    
    //MARK: 取消保存
    func takePhotoCancel() {
        
        if isTakePhoto {
            
            self.takePhotoImg?.isHidden = true
            self.takePhotoImg?.removeFromSuperview()
            self.clearView.isHidden = false
            if self.filterButton.isSelected {
                self.filterView.isHidden = false
            } else {
                self.filterView.isHidden = true
            }
            self.takePhoto_Save.isHidden = true
            self.takePhoto_Cancel.isHidden = true
            self.takePhoto_Share.isHidden = true
        }
    }
    
    //MARK: 聚焦
    func setFocusImage(image: UIImage) {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(focus(tap:)))
        clearView.addGestureRecognizer(tap)
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(focusDisdance(pinch:)))
        clearView.addGestureRecognizer(pinch)
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
    func flashModeChange(button: UIButton) {
        if flashMode == .off {
            
            if videoCamera.inputCamera.hasFlash && videoCamera.inputCamera.hasTorch {
                
                try? videoCamera.inputCamera.lockForConfiguration()
                if videoCamera.inputCamera.isTorchModeSupported(.on) {
                    
                    videoCamera.inputCamera.torchMode = .on
                    videoCamera.inputCamera.flashMode = .on
                    flashMode = .on
                    button.setBackgroundImage(#imageLiteral(resourceName: "takepic_icon_flashlight_selected"), for: .normal)
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
                    button.setBackgroundImage(#imageLiteral(resourceName: "takepic_icon_flashlight_normal"), for: .normal)
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
            
            videoCamera = GPUImageStillCamera(sessionPreset: AVCaptureSessionPresetHigh, cameraPosition: AVCaptureDevicePosition.front)
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
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        videoCamera.startCapture()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        videoCamera.stopCapture()
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
