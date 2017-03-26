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

class PhotosController: UIViewController {

    var chooseImage: UIImage?
    var imgView: UIImageView = UIImageView()
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
            make.bottom.equalTo(self.view).offset(-100)
        })
        return filterView
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let imageView = UIImageView(frame: CGRect(x: (SCREENW - (chooseImage?.size.width)!)/2, y: 0, width: (chooseImage?.size.width)!, height: (chooseImage?.size.height)!))
        imageView.image = chooseImage
        view.addSubview(imageView)
        imgView = imageView
        imgView.isUserInteractionEnabled = true
        
        //旋转
        let rotateRecongnizer = UIRotationGestureRecognizer(target: self, action: #selector(rotateImage(rotateRecongnizer:)))
        imgView.addGestureRecognizer(rotateRecongnizer)
        //捏合
        let pinchRecongnizer = UIPinchGestureRecognizer(target: self, action: #selector(changeImageSize(recognizer:)))
        imgView.addGestureRecognizer(pinchRecongnizer)
        //移动
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moveImg(recognizer:)))
        
        imgView.addGestureRecognizer(panRecognizer)
        //按钮
        let button1 = UIButton(type: .custom)
        button1.setTitle("滤镜", for: .normal)
        button1.setTitleColor(UIColor.red, for: .normal)
        button1.addTarget(self, action: #selector(clickButton1(button:)), for: .touchUpInside)
        button1.sizeToFit()
        view.addSubview(button1)
        button1.snp.makeConstraints { (make) in
            make.leading.bottom.equalTo(self.view)
        }
        
        let button2 = UIButton(type: .custom)
        button2.setTitle("马赛克", for: .normal)
        button2.setTitleColor(UIColor.red, for: .normal)
        button2.addTarget(self, action: #selector(clickButton2), for: .touchUpInside)
        button2.sizeToFit()
        view.addSubview(button2)
        button2.snp.makeConstraints { (make) in
            make.right.bottom.equalTo(self.view)
        }
        
        let saveButton = UIButton(type: .custom)
        saveButton.setTitle("效果2", for: .normal)
        saveButton.setTitleColor(UIColor.red, for: .normal)
        saveButton.addTarget(self, action: #selector(savePhoto), for: .touchUpInside)
        saveButton.sizeToFit()
        view.addSubview(saveButton)
        saveButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view)
            make.centerX.equalTo(self.view)
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
        
        var translatePoint = recognizer.translation(in: imgView)
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
    
    func clickButton2() {
        //设置滤镜效果
        let passthroughFilter = GPUImageSketchFilter()
        //设置要渲染区域
        passthroughFilter.forceProcessing(at: chooseImage!.size)
        passthroughFilter.useNextFrameForImageCapture()
        //设置数据源
        let stillImageSource = GPUImagePicture(image: chooseImage)
        //加上滤镜
        stillImageSource?.addTarget(passthroughFilter)
        //开始渲染
        stillImageSource?.processImage()
        //获取渲染后的图片
        let newImage = passthroughFilter.imageFromCurrentFramebuffer()
        
        imgView.image = newImage
    }
    //GPUImageSmoothToonFilter 卡通
    //GPUImageSketchFilter 素描
    //GPUImageGlassSphereFilter 水晶球效果
    //GPUImageEmbossFilter 浮雕效果
    //GPUImageTiltShiftFilter 上下模糊中间清晰
    //GPUImageSepiaFilter 怀旧
    //GPUImageHueFilter 绿巨人
    
    func savePhoto() {
        let VC = CameraController()
        VC.takePhotoImg = imgView
        VC.takePhotoSave()        
    }
    
}

extension PhotosController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
}


















