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
        
        UIImageWriteToSavedPhotosAlbum((takePhotoImg?.image)!, self, #selector(didFinishSaving(image:error:contextInfo:)), nil)
    }
    @objc func didFinishSaving(image: UIImage, error:Error?, contextInfo: AnyObject) {
        
        if error != nil {
            SVProgressHUD.showError(withStatus: "保存失败")
            return
        }
        self.takePhotoImg?.isHidden = true
        self.takePhotoImg?.removeFromSuperview()
        SVProgressHUD.showSuccess(withStatus: "保存成功")
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
