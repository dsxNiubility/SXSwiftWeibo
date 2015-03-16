//
//  StatusesData.swift
//  HMWeibo04
//
//  Created by apple on 15/3/5.
//  Copyright (c) 2015年 heima. All rights reserved.
//

import UIKit

/**
    关于业务模型

    - 专门处理"被动"的业务，模型类永远不知道谁会在什么时候调用它！
    - 准备好跟数据模型相关的数据
*/
/// 加载微博数据 URL
private let WB_Home_Timeline_URL = "https://api.weibo.com/2/statuses/home_timeline.json"

///  微博数据列表模型
class StatusesData: NSObject, J2MProtocol {
    ///  微博记录数组
    var statuses: [Status]?
    ///  微博总数
    var total_number: Int = 0
    ///  未读数辆
    var has_unread: Int = 0
    
    static func customeClassMapping() -> [String: String]? {
        return ["statuses": "\(Status.self)"]
    }
    
    ///  刷新微博数据 - 专门加载网络数据以及错误处理的回调
    ///  一旦加载成功，负责字典转模型，回调传回转换过的模型数据
    class func loadStatus(maxId:Int = 0,completion: (data: StatusesData?, error: NSError?)->()) {
        
        /// 上拉刷新
        if maxId > 0 {
            
        }
        
        let net = NetworkManager.sharedManager
        if let token = AccessToken.loadAccessToken()?.access_token {
            let params = ["access_token": token,"max_id":"\(maxId)"]
            
            // 发送网络异步请求
            net.requestJSON(.GET, WB_Home_Timeline_URL, params) { (result, error) -> () in
                
                if error != nil {
                    // 错误处理
                    completion(data: nil, error: error!)
                    return
                }
                
                // 字典转模型
                var modelTools = SXSwiftJ2M.sharedManager
                var data = modelTools.swiftObjWithDict(result as! NSDictionary, cls: StatusesData.self) as? StatusesData
                
                /// 保存微博数组
                self.saveStatusData(data?.statuses)
                
                /// 第一次加载时不需要设置刷新标记
                if maxId != 0 {
                self.updateRefreshState(maxId)
                }
                
                // 如果有下载图像的 url，就先下载图像
                if let urls = StatusesData.pictureURLs(data?.statuses) {
                    net.downloadImages(urls) { (_, _) -> () in
                        // 回调通知视图控制器刷新数据
                        completion(data: data, error: nil)
                    }
                } else {
                    // 如果没有要下载的图像，直接回调 -> 将模型通知给视图控制器
                    completion(data: data, error: nil)
                }

            }
        }
    }
    
    ///  更新 maxId & topId 之间记录的刷新状态
    class func updateRefreshState(maxId: Int) {
        let sql = "UPDATE T_Status SET refresh = 1 \n" +
        "WHERE id > \(maxId);"
        println(maxId)
        SQLite.sharedSQLite.execSQL(sql)
    }
    
    /// 保存微博数据 （传进来一个模型数组）
    class func saveStatusData (statuses:[Status]?){
        if statuses == nil{
            return
        }
        
        /// 开启事务 然后下面提交事务
        SQLite.sharedSQLite.execSQL("BEGIN TRANSACTION")
        
        for s in statuses!{
            
            /// 配图记录保存
            if !StatusPictureURL.savePictures(s.id, pictures: s.pic_urls) {
                
                /// 一旦出现错误 就回滚 放弃这一轮的所有操作
                println("配图插入出现错误")
                SQLite.sharedSQLite.execSQL("ROLLBACK TRANSACTION")
                break
            }
            
            /// 用户记录保存
            if s.user != nil{
                if !s.user!.insertDB() {
                    println("用户数据插入出现错误")
                    SQLite.sharedSQLite.execSQL("ROLLBACK TRANSACTION")
                    break
                }
            }
            
            // 3. 微博记录
            if !s.insertDB() {
                println("插入微博数据错误")
                SQLite.sharedSQLite.execSQL("ROLLBACK TRANSACTION")
                break
            }
            
            // 4. 转发微博的记录（用户/配图）
            if s.retweeted_status != nil {
                // 存在转发微博
                // 保存转发微博
                if !s.retweeted_status!.insertDB() {
                    println("插入转发微博数据错误")
                    SQLite.sharedSQLite.execSQL("ROLLBACK TRANSACTION")
                    break
                }
            }

        }
        
        SQLite.sharedSQLite.execSQL("COMMIT TRANSACTION")
    }
    

    
    
    
    ///  取出给定的微博数据中所有图片的 URL 数组
    ///
    ///  :param: statuses 微博数据数组，可以为空
    ///
    ///  :returns: 微博数组中的 url 完整数组，可以为空
    class func pictureURLs(statuses: [Status]?) -> [String]? {
        
        // 如果数据为空直接返回
        if statuses == nil {
            return nil
        }
        
        // 遍历数组
        var list = [String]()
        
        for status in statuses! {
            // 继续遍历 pic_urls
            if let urls = status.pictureUrls {
                for pic in urls {
                    list.append(pic.thumbnail_pic!)
                }
            }
        }
        
        if list.count > 0 {
            return list
        } else {
            return nil
        }
    }
}

///  微博模型
class Status: NSObject, J2MProtocol {
    ///  微博创建时间
    var created_at: String?
    ///  微博ID
    var id: Int = 0
    ///  微博信息内容
    var text: String?
    ///  微博来源
    var source: String?
    
    /// 去掉 href 的来源字符串
    var sourceStr: String {
        return source?.removeHref() ?? ""
    }
    
    ///  转发数
    var reposts_count: Int = 0
    ///  评论数
    var comments_count: Int = 0
    ///  表态数
    var attitudes_count: Int = 0
    ///  配图数组
    var pic_urls: [StatusPictureURL]?
    
    /// 要显示的配图数组
    /// 如果是原创微博，就使用 pic_urls
    /// 如果是转发微博，使用 retweeted_status.pic_urls
    var pictureUrls: [StatusPictureURL]? {
        if retweeted_status != nil {
            return retweeted_status?.pic_urls
        } else {
            return pic_urls
        }
    }
    
    /// 所有大图的 URL － 计算属性
    var largeUrls: [String]? {
        get {
            // 可以使用 kvc 直接拿值
            var urls = self.valueForKeyPath("pictureUrls.large_pic") as? NSArray
            return urls as? [String]
        }
    }
    
    /// 用户信息
    var user: UserInfo?
    /// 转发微博
    var retweeted_status: Status?
    
    static func customeClassMapping() -> [String : String]? {
        return ["pic_urls": "\(StatusPictureURL.self)",
        "user": "\(UserInfo.self)",
        "retweeted_status": "\(Status.self)",]
    }
    
    // 保存微博数据
    func insertDB() -> Bool {
        // 如果 Xcode 6.3 Bata 2/3 直接写 ?? 会非常非常慢,要先拆开
        let userId = user?.id ?? 0
        let retId = retweeted_status?.id ?? 0
        
        // 判断数据是否已经存在，如果存在就不再插入
        var sql = "SELECT count(*) FROM T_Status WHERE id = \(id);"
        if SQLite.sharedSQLite.execCount(sql) > 0 {
            return true
        }
        
        // 之所以只使用 INSERT，是因为 INSERT AND REPLACE 会在更新数据的时候，直接将 refresh 重新设置为 0
        sql = "INSERT INTO T_Status \n" +
            "(id, text, source, created_at, reposts_count, comments_count, attitudes_count, userId, retweetedId) \n" +
            "VALUES \n" +
        "(\(id), '\(text!)', '\(source!)', '\(created_at!)', \(reposts_count), \(comments_count), \(attitudes_count), \(userId), \(retId));"
        
        return SQLite.sharedSQLite.execSQL(sql)
    }

}

///  微博配图模型
class StatusPictureURL: NSObject {
    ///  缩略图 URL
    var thumbnail_pic: String?{
        didSet{
            var str = thumbnail_pic!
            large_pic = str.stringByReplacingOccurrencesOfString("thumbnail", withString: "large")
        }
    }
    ///  大图 URL
    var large_pic: String?
    
    /// MARK: - 对配图进行缓存
    /// 把配图数据保存到数据库 （传入一个微博ID和配图的链接数组）
    class func savePictures(statusId:Int,pictures:[StatusPictureURL]?) -> Bool {
        
        if pictures == nil {
            /// 如果微博没有图片 直接就当执行完成了
            return true
        }
        
        let sql = "SELECT count(*) FROM T_StatusPic WHERE statusId = \(statusId);"
        if  SQLite.sharedSQLite.execCount(sql) > 0 {
            return true
        }
        
        for pic in pictures! {
            
            /// 只要遍历中有一个图片失败，就返回一个false，那边会进行回滚
            if !pic.insertDB(statusId){
                return false
            }
        }
        return true
    }
    
    /// 插入到数据库
    func insertDB(statusId:Int) -> Bool {
        let sql = "INSERT INTO T_StatusPic (statusId, thumbnail_pic) VALUES (\(statusId), '\(thumbnail_pic!)');"
        
        return SQLite.sharedSQLite.execSQL(sql)
    }
}
