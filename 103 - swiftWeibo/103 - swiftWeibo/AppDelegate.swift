//
//  AppDelegate.swift
//  103 - swiftWeibo
//
//  Created by 董 尚先 on 15/3/2.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

import UIKit
import SimpleNetwork

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        /// 关于accessToken
        if let token = AccessToken.loadAccessToken() {
            println(token)
            println(token.uid)
        }
        
        let net = SimpleNetwork()
        
        let urls = ["http://ww1.sinaimg.cn/thumbnail/62c13fbagw1epuww0k4xgj20c8552b29.jpg",
            "http://ww3.sinaimg.cn/thumbnail/e362b134jw1epuxb47zoyj20dw0ku421.jpg",
            "http://ww1.sinaimg.cn/thumbnail/e362b134jw1epuxbaym1sj20ku0dwgpu.jpg",
            "http://ww2.sinaimg.cn/thumbnail/e362b134jw1epuxbdhirmj20dw0kuae8.jpg"]
        
        net.downloadImages(urls, { (result, error) -> () in
            println("下载完毕")
        })
        
        /// 添加导航栏主题
        setNavAppeareance()
        return true
    }
    
    func setNavAppeareance(){
        UINavigationBar.appearance().tintColor = UIColor.orangeColor()
    }

}

