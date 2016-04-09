
//
//  NetworkManager.swift
//  103 - swiftWeibo
//
//  Created by 董 尚先 on 15/3/2.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

import Foundation

class NetworkManager {
    
    private static let instance = NetworkManager()
    
    class var sharedManager:NetworkManager{
        return instance
    }
    
    typealias Completion = (result:AnyObject?,error:NSError?) ->()
    
    // 隔离一层大框架
    private let net = SimpleNetwork()
    
    /**
    请求JSON
    
    - parameter method:     GET 还是 POST
    - parameter urlString:  URLstr
    - parameter params:     可选参数列表
    - parameter completion: 完成回调
    */
    func requestJSON(method:HTTPMethod, _ urlString:String, _ params:[String:String]?, _ completion:Completion){
        
        net.requestJSON(method, urlString, params,  completion)
    
    }
    
    ///  异步下载网路图像
    ///
    ///  - parameter urlString:  urlString
    ///  - parameter completion: 完成回调
    func requestImage(urlString: String, _ completion: Completion) {
        
        net.requestImage(urlString, completion)
    }
    
    ///  完整的 URL 缓存路径
    func fullImageCachePath(urlString: String) -> String {
        
        return net.fullImageCachePath(urlString)
    }
    
    ///  下载多张图片
    ///
    ///  - parameter urls:       图片 URL 数组
    ///  - parameter completion: 所有图片下载完成后的回调
    func downloadImages(urls: [String], _ completion: Completion) {
        
        net.downloadImages(urls, completion)
    }
    
    ///  下载图像并且保存到沙盒
    ///
    ///  - parameter urlString:  urlString
    ///  - parameter completion: 完成回调
    func downloadImage(urlString: String, _ completion: Completion) {
        
        net.downloadImage(urlString, completion)
    }
    
    
    
}