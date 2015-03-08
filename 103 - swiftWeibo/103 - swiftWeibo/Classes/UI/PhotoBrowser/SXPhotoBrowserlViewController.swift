//
//  SXPhotoBrowserlViewController.swift
//  103 - swiftWeibo
//
//  Created by 董 尚先 on 15/3/8.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

import UIKit

class SXPhotoBrowserlViewController: UIViewController {

    var urls:[String]?
    
    var selectedIndex:Int = 0
    
    /// 类方法创建控制器
    class func photoBrowserViewController() ->SXPhotoBrowserlViewController {
        let sb = UIStoryboard(name: "PhotoBrowser", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! SXPhotoBrowserlViewController
        
        return vc
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

       println("测试数据 \(urls) \(selectedIndex)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
