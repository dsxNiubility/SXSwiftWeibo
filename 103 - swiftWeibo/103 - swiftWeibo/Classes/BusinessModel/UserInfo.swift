//
//  UserInfo.swift
//  HMWeibo04
//
//  Created by apple on 15/3/5.
//  Copyright (c) 2015年 heima. All rights reserved.
//

import UIKit

///  用户信息
class UserInfo: NSObject {
    
    ///  用户UID
    var id: Int = 0
    ///  用户昵称
    var screen_name: String?
    ///  友好显示名称
    var name: String?
    ///  用户头像地址（中图），50×50像素
    var profile_image_url: String?
    ///  用户头像地址（大图），180×180像素
    var avatar_large: String?
    ///  用户创建（注册）时间
    var created_at: String?
    ///  是否是微博认证用户，即加V用户，true：是，false：否
    var verified: Bool = false
    ///  认证类型 -1：没有认证，0，认证用户，2,3,5: 企业认证，220: 草根明星
    var verified_type: Int = -1{
        didSet {
            switch verified_type {
            case 0:     // 大V
                verifiedImage = UIImage(named: "avatar_vip")
            case 2,3,5: // 企业认证
                verifiedImage = UIImage(named: "avatar_enterprise_vip")
            case 220:   // 达人
                verifiedImage = UIImage(named: "avatar_grassroot")
            default:
                verifiedImage = nil
            }
        }
    }
    
    ///  认证图标
    var verifiedImage: UIImage?
    
    ///  会员等级 0~6
    var mbrank: Int = 0{
        didSet {
            if mbrank > 0 && mbrank < 7 {
                mbImage = UIImage(named: "common_icon_membership_level\(mbrank)")
            }else {
                mbImage = nil
            }
        }
    }
    
    var mbImage:UIImage?
    
    // 使用记录集实例化用户数据
    init(record: [AnyObject]?) {
        // id userId, screen_name, name, profile_image_url, avatar_large, created_at user_created_at, verified, mbrank
        if record == nil {
            return
        }
        
        id = record![0] as! Int
        screen_name = record![1] as? String
        name = record![2] as? String
        profile_image_url = record![3] as? String
        avatar_large = record![4] as? String
        created_at = record![5] as? String
        verified = record![6] as! Bool
        mbrank = record![7] as! Int
    }
    
    ///  使用用户id从本地数据库加载用户记录
    convenience init(pkId: Int) {
        let sql = "SELECT id, screen_name, name, profile_image_url, avatar_large, created_at, verified, mbrank \n" +
        "FROM T_User WHERE id = \(pkId)"
        
        let record = SQLite.sharedSQLite.execRow(sql)
        self.init(record: record)
    }
    

    
    
    // 插入 或者 更新用户数据
    func insertDB() -> Bool {
        
        // INSERT OR REPLACE 能够插入或者更新 记录
        // !!! 字段中，必须要包含 主键
        let sql = "INSERT OR REPLACE INTO T_User \n" +
            "(id, screen_name, name, profile_image_url, avatar_large, created_at, verified, mbrank) \n" +
            "VALUES \n" +
        "(\(id), '\(screen_name!)', '\(name!)', '\(profile_image_url!)', '\(avatar_large!)', '\(created_at!)', \(Int(verified)), \(mbrank))"
        
        // 打印出来的 SQL 可以直接粘贴进行调试
        println(sql)
        
        return SQLite.sharedSQLite.execSQL(sql)
    }
}
