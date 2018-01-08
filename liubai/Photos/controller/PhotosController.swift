//
//  PhotosController.swift
//  liubai
//
//  Created by 李江波 on 2017/3/13.
//  Copyright © 2017年 lijiangbo. All rights reserved.
//

import UIKit
import SnapKit
import GPUImage

class PhotosController: UIViewController, CTImageSmearViewControllerDelegate {

    var chooseImage: UIImage?
    var imgView: UIImageView!
    var lastRotation: CGFloat = 0.0
    var lastScale: CGFloat?
    var firstX: CGFloat?
    var firstY:CGFloat?
    
    
    
    //滤镜视图
    lazy var filterView: FilterCollectionView = {
        let filterView = FilterCollectionView()
        filterView.clickItem = { (i) in
            
            self.chooseFilterClick(i)
        }
        self.view.addSubview(filterView)
        filterView.snp.makeConstraints({ (make) in
            make.right.left.equalTo(self.view)
            make.height.equalTo(100)
            make.bottom.equalTo(self.view.snp.bottomMargin).offset(-60)
        })
        return filterView
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        let imageView = UIImageView(frame: CGRect(x: (SCREENW - (chooseImage?.size.width)!)/2, y: (SCREENH - (chooseImage?.size.height)!)/2, width: (chooseImage?.size.width)!, height: (chooseImage?.size.height)!))
        imageView.image = chooseImage
        view.addSubview(imageView)
        imgView = imageView
        imgView.isUserInteractionEnabled = true
        
        //旋转
        let rotateRecongnizer = UIRotationGestureRecognizer(target: self, action: #selector(rotateImage(rotateRecongnizer:)))
        rotateRecongnizer.delegate = self
        imgView.addGestureRecognizer(rotateRecongnizer)
        //捏合
        let pinchRecongnizer = UIPinchGestureRecognizer(target: self, action: #selector(changeImageSize(recognizer:)))
        pinchRecongnizer.delegate = self
        imgView.addGestureRecognizer(pinchRecongnizer)
        //移动
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moveImg(recognizer:)))
        
        imgView.addGestureRecognizer(panRecognizer)
        //取消按钮
        let cancelButton = UIButton(type: .custom)
        cancelButton.setBackgroundImage(#imageLiteral(resourceName: "photoAlbum_save_icon_close"), for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelClick), for: .touchUpInside)
        cancelButton.sizeToFit()
        view.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(18)
            make.top.equalTo(view.snp.topMargin)
        }
        
        //按钮
        let button1 = UIButton(type: .custom)
        button1.setBackgroundImage(#imageLiteral(resourceName: "takepic_icon_filter"), for: .normal)
        button1.addTarget(self, action: #selector(clickButton1(button:)), for: .touchUpInside)
        button1.sizeToFit()
        view.addSubview(button1)
        button1.snp.makeConstraints { (make) in
            make.leading.equalTo(view)
            make.bottom.equalTo(view.snp.bottomMargin);
        }
        //马赛克按钮
        let mosaicButton = UIButton(type: .custom)
        mosaicButton.setBackgroundImage(#imageLiteral(resourceName: "photoAlbum_icon_mosaic"), for: .normal)
        mosaicButton.addTarget(self, action: #selector(mosaicClick), for: .touchUpInside)
        mosaicButton.sizeToFit()
        view.addSubview(mosaicButton)
        mosaicButton.snp.makeConstraints { (make) in
            make.right.equalTo(view)
            make.bottom.equalTo(view.snp.bottomMargin)
        }
        //保存视频
        let saveButton = UIButton(type: .custom)
        saveButton.setBackgroundImage(#imageLiteral(resourceName: "photoAlbum_save_icon_save"), for: .normal)
        saveButton.addTarget(self, action: #selector(savePhoto), for: .touchUpInside)
        view.addSubview(saveButton)
        saveButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(button1)
            make.centerX.equalTo(view)
        }
        //分享按钮
        let shareButton = UIButton(type: .custom)
        shareButton.setBackgroundImage(#imageLiteral(resourceName: "photoAlbum_choosePic_share"), for: .normal)
        shareButton.addTarget(self, action: #selector(sharePhoto), for: .touchUpInside)
        view.addSubview(shareButton)
        shareButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(cancelButton)
            make.right.equalTo(view).offset(-18)
        }
        //换icon按钮
//        let changeIconButton = UIButton(type: .custom)
//        changeIconButton.setBackgroundImage(#imageLiteral(resourceName: "photoAlbum_choosePic_share"), for: .normal)
//        changeIconButton.addTarget(self, action: #selector(changeIcon), for: .touchUpInside)
//        view.addSubview(changeIconButton)
//        changeIconButton.snp.makeConstraints { (make) in
//            make.centerY.equalTo(cancelButton)
//            make.right.equalTo(view).offset(-100)
//        }
        
    }
    
    //MARK: 换icon
    func changeIcon() {
        
        if #available(iOS 10.3, *) {
            let iconName = UIApplication.shared.alternateIconName
            if iconName == nil {
                
                UIApplication.shared.setAlternateIconName("newIcon", completionHandler: { (error) in
                    
                    if error != nil {
                    
                        print(error!)
                    }
                })
            } else {
            
                UIApplication.shared.setAlternateIconName(nil, completionHandler: { (error) in
                    if error != nil {
                        
                        print(error!)
                    }
                })
            }
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    //MARK: 图片手势
    func rotateImage(rotateRecongnizer: UIRotationGestureRecognizer)  {
        
        if rotateRecongnizer.state == .ended {
            lastRotation = 0.0
            return
        }
        let currentTransform = imgView.transform
        let rotation = 0.0 - (lastRotation - rotateRecongnizer.rotation)
        let newTransform = currentTransform.rotated(by: rotation)
        imgView.transform = newTransform
        lastRotation = rotateRecongnizer.rotation
        
        
    }
    
    func changeImageSize(recognizer: UIPinchGestureRecognizer) {
        
        if recognizer.state == .began {
            lastScale = 1.0
        }
        let scale = 1.0 - (lastScale! - recognizer.scale)
        let currentTransform = imgView.transform
        let newTransform = currentTransform.scaledBy(x: scale, y: scale)
        imgView.transform = newTransform
        lastScale = recognizer.scale
    }
    
    func moveImg(recognizer: UIPanGestureRecognizer) {
        
        var translatePoint = recognizer.translation(in: view)
        if recognizer.state == .began {
            firstX = imgView.center.x
            firstY = imgView.center.y
        }
        translatePoint = CGPoint(x: firstX! + translatePoint.x, y: firstY! + translatePoint.y)
        imgView.center = translatePoint
    }
    
    func clickButton1(button: UIButton) {
        button.isSelected = !button.isSelected
        if button.isSelected {
            
            filterView.isHidden = false
        } else {
            
            filterView.isHidden = true
        }
    }
    //GPUImageSmoothToonFilter 卡通
    //GPUImageSketchFilter 素描
    //GPUImageGlassSphereFilter 水晶球效果
    //GPUImageEmbossFilter 浮雕效果
    //GPUImageTiltShiftFilter 上下模糊中间清晰
    //GPUImageSepiaFilter 怀旧
    //GPUImageHueFilter 绿巨人
    func chooseFilterClick(_ item: Int) {
        //设置滤镜效果
        var filter: GPUImageOutput! = GPUImageFilter()
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
        //设置要渲染区域
        filter.forceProcessing(at: chooseImage!.size)
        filter.useNextFrameForImageCapture()
        //设置数据源
        let stillImageSource = GPUImagePicture(image: chooseImage)
        //加上滤镜
        stillImageSource?.addTarget(filter as! GPUImageInput!)
        //开始渲染
        stillImageSource?.processImage()
        //获取渲染后的图片
        let newImage = filter.imageFromCurrentFramebuffer()
        
        imgView.image = newImage
    }
    
    func mosaicClick() {
        
        let mosaicVC = CTImageSmearViewController()
        mosaicVC.delegate = self
        mosaicVC.package(with: chooseImage)
        present(mosaicVC, animated: true, completion: nil)
        
    }
    
    func savePhoto() {
        let VC = CameraController()
        VC.takePhotoImg = imgView
        VC.isTakePhoto = false
        VC.takePhotoSave()        
    }
    
    func cancelClick() {
        dismiss(animated: true, completion: nil)
    }
    func didSmearPhoto(withResultImage image: UIImage!) {
        chooseImage = image
        imgView.image = chooseImage
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
            shareObject.shareImage = self.chooseImage
            messageObject.shareObject = shareObject
            UMSocialManager.default().share(to: platformType, messageObject: messageObject, currentViewController: self, completion: { (data, error) in
                
                if error != nil {
                    
                } else {
                    
                }
            })
        }
    }
}


extension PhotosController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true;
    }
}
















