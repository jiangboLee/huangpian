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
        //按钮
        let button1 = UIButton(type: .custom)
        button1.setTitle("效果1", for: .normal)
        button1.setTitleColor(UIColor.red, for: .normal)
        button1.addTarget(self, action: #selector(clickButton1), for: .touchUpInside)
        button1.sizeToFit()
        view.addSubview(button1)
        button1.snp.makeConstraints { (make) in
            make.leading.bottom.equalTo(self.view)
        }
        
        let button2 = UIButton(type: .custom)
        button2.setTitle("效果2", for: .normal)
        button2.setTitleColor(UIColor.red, for: .normal)
        button2.addTarget(self, action: #selector(clickButton2), for: .touchUpInside)
        button2.sizeToFit()
        view.addSubview(button2)
        button2.snp.makeConstraints { (make) in
            make.right.bottom.equalTo(self.view)
        }

    }
    
    func clickButton1() {
        //设置滤镜效果
        let passthroughFilter = GPUImageHueFilter()
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
    
    
    func clickButton2() {
        
        //设置滤镜效果
        let passthroughFilter = GPUImageSepiaFilter()
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true, completion: nil)
    }
}

extension PhotosController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
}


















