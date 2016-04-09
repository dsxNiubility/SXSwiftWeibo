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
            print(token)
            print(token.uid)
            
            showMainInterface()
        }else{
            // 添加通知监听，监听用户登录成功
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "showMainInterface", name: WB_Login_Successed_Notification, object: nil)
        }
        
        return true
    }
    
    /// 测试两次上拉刷新
    func loadTwoRefreshDemo() {
        // 加载数据测试代码 － 第一次刷新，都是从服务器加载数据！
        StatusesData.loadStatus(0) { (data, error) -> () in
            // 第一次加载的数据
            if let statuses = data?.statuses {
                // 模拟上拉刷新
                // 取出最后一条记录中的 id，id -1 -> maxId
                let mId = statuses.last!.id
                let tId = statuses.first!.id
                print("maxId \(mId) ---- topId \(tId)")
                
                // 上拉刷新
                StatusesData.loadStatus(maxId: (mId - 1), completion: { (data, error) -> () in
                    print("第一次上拉刷新结束")
                    
                    // 再一次加载的数据
                    if let statuses = data?.statuses {
                        // 模拟上拉刷新
                        // 取出最后一条记录中的 id，id -1 -> maxId
                        let mId = statuses.last!.id
                        let tId = statuses.first!.id
                        print("2222 maxId \(mId) ---- topId \(tId)")
                        
                        // 上拉刷新
                        StatusesData.loadStatus(maxId: (mId - 1), completion: { (data, error) -> () in
                            print("第二次上拉刷新结束")
                        })
                    }
                })
            }
        }
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

