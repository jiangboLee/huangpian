//
//  UIAlert.swift
//  liubai
//
//  Created by 李江波 on 2017/3/22.
//  Copyright © 2017年 lijiangbo. All rights reserved.
//

import UIKit

class LJBAlertView: NSObject {
    
    /// 声明单例
    static let sharedAlertView: LJBAlertView = {
        let sharedAlertView = LJBAlertView()
        return sharedAlertView
    }()
    
    func alert(titleName: String, message: String, buttonTitle: String, tager: UIViewController) {

        let alertAction = UIAlertAction(title: buttonTitle, style: .default, handler: nil)
        let alertV = UIAlertController(title: titleName, message: message, preferredStyle: .alert)
        alertV.addAction(alertAction)
        tager.present(alertV, animated: true, completion: nil)
    }
}
