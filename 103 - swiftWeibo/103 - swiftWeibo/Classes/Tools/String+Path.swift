//
//  String+Path.swift
//  01-工资表
//
//  Created by 刘凡 on 15/3/14.
//  Copyright (c) 2015年 itheima. All rights reserved.
//

import Foundation

extension String {
    ///  在字符串前拼接文档目录
    func documentPath() -> String {
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).last as! String
        
        return path.stringByAppendingPathComponent(self)
    }
    
    ///  在字符串前拼接缓存目录
    func cachePath() -> String {
        let path = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).last as! String
        
        return path.stringByAppendingPathComponent(self)
    }
    
    ///  在字符串前拼接临时目录
    func tempPath() -> String {
        return NSTemporaryDirectory().stringByAppendingPathComponent(self)
    }
}