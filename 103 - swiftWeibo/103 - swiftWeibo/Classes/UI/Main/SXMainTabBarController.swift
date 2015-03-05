//
//  SXMainTabBarController.swift
//  103 - swiftWeibo
//
//  Created by 董 尚先 on 15/3/5.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

import UIKit

class SXMainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        addControllers()
        
        weak var weakSelf = self  // $$$$$
        mainTabBar.composedButtonClicked = {
            let sb = UIStoryboard(name: "Compose", bundle: nil)
            
            weakSelf!.presentViewController(sb.instantiateInitialViewController() as! UIViewController, animated: true, completion: nil)
        }
        
    }

    @IBOutlet weak var mainTabBar: SXMainTabBar!

    
    func addControllers(){
        addchildController("Home", "首页", "tabbar_home", "tabbar_home_highlighted")
        addchildController("Message", "消息", "tabbar_message_center", "tabbar_message_center_highlighted")
        addchildController("Discover", "发现", "tabbar_discover", "tabbar_discover_highlighted")
        addchildController("Profile", "我", "tabbar_profile", "tabbar_profile_highlighted")
    }
    
    func addchildController(name:String , _ title:String, _ imageName:String, _ hightlight:String){
        let sb = UIStoryboard(name: name, bundle: nil)
        let nav = sb.instantiateInitialViewController() as! UINavigationController
        nav.tabBarItem.image = UIImage(named: imageName)
        nav.tabBarItem.selectedImage = UIImage(named: hightlight)?.imageWithRenderingMode(.AlwaysOriginal) // $$$$$
        nav.title = title
        
        nav.tabBarItem.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.orangeColor()], forState: UIControlState.Selected)
        
        self.addChildViewController(nav)  // $$$$$
    
    }
}
