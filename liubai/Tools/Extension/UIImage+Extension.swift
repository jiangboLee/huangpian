//
//  UIImage+Extension.swift
//  liubai
//
//  Created by 李江波 on 2017/3/13.
//  Copyright © 2017年 lijiangbo. All rights reserved.
//

import UIKit

extension UIImage {
    
    //截取屏幕
    class func snapShotCurrentWindow() -> UIImage {
        
        let window = UIApplication.shared.keyWindow!
        //开启图片的上下文
        UIGraphicsBeginImageContextWithOptions(window.frame.size, true, 0)
        //将当前的window绘制到图形的上下文
        window.drawHierarchy(in: window.frame, afterScreenUpdates: true)
        //从图片的上下文中获取图片
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        //关闭图片的上下文
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    //缩放图片
    func imgScale(width: CGFloat) -> UIImage {
        
        if self.size.width < width {
            return self
        }
        let H = self.size.height / self.size.width * width
        let imgBounds = CGRect(x: 0, y: 0, width: width, height: H)
        //开启图片的上下文
        UIGraphicsBeginImageContextWithOptions(imgBounds.size, true, 0)
        //将当前的image绘制到图形的上下文
        self.draw(in: imgBounds)
        //从图片的上下文中获取图片
        let img = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return img!
    }
    
    //生成圆角图片
    func circleImage() -> UIImage {
        
        let imageWH = self.size.width
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0)
        let path = UIBezierPath.init(ovalIn: CGRect(x: 0, y: 0, width: imageWH, height: imageWH))
        path.addClip()
        self.draw(at: CGPoint(x: 0, y: 0))
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}














