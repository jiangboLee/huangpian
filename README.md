# Ptoo
美图
几个月之前，直播美颜，各种美颜相机满天飞。看到自己老婆天天拿着美颜相机拍照，所以决定自己写一个美颜相机让她用，虽然已经上线，[下载地址](https://itunes.apple.com/us/app/ptoo/id1219224872?mt=8)，但是还是基本不打开我的APP。（没办法，功能实在没别人多，只有几种滤镜拍照）。由于公司一直都是用OC，所以打算用Swift3.0练练手。

现在将源码与大家分享。

![作品展示.gif](http://upload-images.jianshu.io/upload_images/2868618-7b6d7c6102007b91.gif?imageMogr2/auto-orient/strip)

也是好几个月前的写的。里面的都写也都快忘得差不多了。不过里面的功能每个功能块注释还是很详细的~（年纪大了，记性越来越差了，再加上好久没写Swift了）。现在就展示几个功能吧~

#### 开关闪光灯
```objective-c
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
```
#### 镜像变化
```objective-c
//MARK: 镜像变化
    /// 镜像变化
    func mirrorChange() {
        
        if videoCamera.horizontallyMirrorFrontFacingCamera == false {
            
            videoCamera.horizontallyMirrorFrontFacingCamera = true
        } else {
        
            videoCamera.horizontallyMirrorFrontFacingCamera = false
        }
    }
```

#### 聚焦
```objective-c
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
```

等等~有兴趣的自己下载看哈。隔了几个月都看不懂了。/(ㄒoㄒ)/~~   
