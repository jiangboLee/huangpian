//
//  AppDelegate.swift
//  liubai
//
//  Created by 李江波 on 2017/2/25.
//  Copyright © 2017年 lijiangbo. All rights reserved.
//  1219224872
// 58d4eac765b6d60c4e00040c 友盟

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //友盟推送58d4eac765b6d60c4e00040c
        UMessage.start(withAppkey: "58d4eac765b6d60c4e00040c", launchOptions: launchOptions)
//        UMessage.start(withAppkey: "58d4eac765b6d60c4e00040c", launchOptions: launchOptions, httpsEnable: true)
        
        UMessage.registerForRemoteNotifications()
        //iOS10必须加下面这段代码。
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.alert,.badge,.sound], completionHandler: { (granted, error) in
                if granted {
                //允许点击
                } else {
                //点击不允许
                }
            })
            
        } else {
            // Fallback on earlier versions
        }
        UMessage.setLogEnabled(true)
        
        //友盟统计
        UMAnalyticsConfig.sharedInstance().appKey = "58d4eac765b6d60c4e00040c"
        UMAnalyticsConfig.sharedInstance().channelId = "App Store"
        //版本
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        MobClick.setAppVersion(version as? String ?? "")
        MobClick.start(withConfigure: UMAnalyticsConfig.sharedInstance())
        
        
        UMSocialManager.default().openLog(true)
        // 设置友盟appkey
        UMSocialManager.default().umSocialAppkey = "58d4eac765b6d60c4e00040c"
        
        configUSharePlatforms()
        
        return true
    }
    
    func configUSharePlatforms() {
        
        /* 设置微信的appKey和appSecret */
        UMSocialManager.default().setPlaform(.wechatSession, appKey: "wxdc1e388c3822c80b", appSecret: "3baf1193c85774b3fd9d18447d76cab0", redirectURL: "http://www.jianshu.com/u/3cd8d0f74b3a")
        UMSocialManager.default().setPlaform(.QQ, appKey: "1105923615", appSecret: nil, redirectURL: "http://www.jianshu.com/u/3cd8d0f74b3a")
        UMSocialManager.default().setPlaform(.sina, appKey: "1497207940", appSecret: "5d72cdca0afb7fc5cae8a0e99b2137be", redirectURL: "http://www.baidu.com")
    }
    //MARK: 完整的接受通知代码
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        UMessage.didReceiveRemoteNotification(userInfo)
    }
    //iOS10新增：处理前台收到通知的代理方法
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let useInfo = notification.request.content.userInfo
        if (notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self))! {
            //应用处于前台时的远程推送接受
            //关闭U-Push自带的弹出框
            UMessage.setAutoAlert(false)
            //必须加这句代码
            UMessage.didReceiveRemoteNotification(useInfo)
        } else {
             //应用处于前台时的本地推送接受
        }
        //当应用处于前台时提示设置，需要哪个可以设置哪一个
        completionHandler([.sound, .badge, .alert])
    }
    //iOS10新增：处理后台点击通知的代理方法
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if (response.notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self))! {
            //应用处于后台时的远程推送接受
            //必须加这句代码
            UMessage.didReceiveRemoteNotification(userInfo)
        } else {
            //应用处于后台时的本地推送接受
        }
        
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        let result = UMSocialManager.default().handleOpen(url)
        if !result {
            
        }
        return result
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let result = UMSocialManager.default().handleOpen(url)
        if !result {
            
        }
        return result
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        
        let result = UMSocialManager.default().handleOpen(url)
        if !result {
            
        }
        return result
    }
    
    
    

}

