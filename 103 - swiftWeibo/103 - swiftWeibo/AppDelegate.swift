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
        
        let net = SimpleNetwork()
        net.demo()
        
        return true
    }

}

