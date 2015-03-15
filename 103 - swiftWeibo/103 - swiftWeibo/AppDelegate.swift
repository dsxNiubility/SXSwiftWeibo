//
//  AppDelegate.swift
//  103 - swiftWeibo
//
//  Created by 董 尚先 on 15/3/2.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        SQLite.sharedSQLite.openDatabase("sxweibo.db")
        
        /// 关于accessToken
        if let token = AccessToken.loadAccessToken() {
            println(token)
            println(token.uid)
            
            showMainInterface()
        }else{
            // 添加通知监听，监听用户登录成功
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "showMainInterface", name: WB_Login_Successed_Notification, object: nil)
        }
        
        return true
    }
    
    func showMainInterface(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: WB_Login_Successed_Notification, object: nil)
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        window!.rootViewController = (sb.instantiateInitialViewController() as!UIViewController)
        
        /// 添加导航栏主题
        setNavAppeareance()
    }
    
    func setNavAppeareance(){
        UINavigationBar.appearance().tintColor = UIColor.orangeColor()
    }

}

