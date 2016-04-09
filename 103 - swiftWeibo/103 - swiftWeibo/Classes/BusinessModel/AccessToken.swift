//
//  AccessToken.swift
//  103 - swiftWeibo
//
//  Created by 董 尚先 on 15/3/3.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

import UIKit


class AccessToken:NSObject,NSCoding{
    
    var access_token:String?
    
    ///  token过期日期
    var expiresDate: NSDate?
    
    var remind_in: NSNumber?
    
    var expires_in :NSNumber?{
        didSet{
            expiresDate = NSDate(timeIntervalSinceNow: expires_in!.doubleValue)
            print("过期时间为--：\(expiresDate)")
        }
    }
    
    
    var isExpired:Bool{
        
        // 判断过期时间和系统时间，如果后面比较结果是升序，那就是当前日期比过期时间大。就是过期
        return expiresDate?.compare(NSDate()) == NSComparisonResult.OrderedAscending
    }
    
    var uid : Int = 0
    
    /// 传入字典的构造方法
    init(dict:NSDictionary){
        super.init()
        self.setValuesForKeysWithDictionary(dict as [NSObject : AnyObject] as [NSObject:AnyObject])
    }
    
    /// 将数据保存到沙盒
    func saveAccessToken(){
        NSKeyedArchiver.archiveRootObject(self, toFile: AccessToken.tokenPath())
        
        print("accesstoken地址是" + AccessToken.tokenPath())
    }
    
    /// 从沙盒读取 token 数据
    class func loadAccessToken() -> AccessToken? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(tokenPath()) as? AccessToken
    }
    
    /// 返回保存的沙盒路径
    class func tokenPath() -> String {
        var path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last as!String
        path = (path as NSString).stringByAppendingPathComponent("SXWeiboToken.plist")
        
        return path
    }
    
    
    /// 普通的构造方法
    override init() {}
    
    func encodeWithCoder(encode: NSCoder) {
        encode.encodeObject(access_token)
        encode.encodeObject(expiresDate)
        encode.encodeInteger(uid, forKey: "uid")
    }
    
    required init?(coder decoder:NSCoder){
        access_token = decoder.decodeObject() as?String
        expiresDate = decoder.decodeObject() as?NSDate
        uid = decoder.decodeIntegerForKey("uid")
    }

    
}