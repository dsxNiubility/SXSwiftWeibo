//
//  SimpleNetwork.swift
//  SimpleNetwork
//
//  Created by apple on 15/3/2.
//  Copyright (c) 2015年 heima. All rights reserved.
//

import Foundation

///  常用的网络访问方法
public enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
}

public class SimpleNetwork {

//    func demo() {
//        requestJSON(.GET, "", params: nil) { (result, error) -> () in
//            
//        }
//    }
    public func demo(){
        println("demo")
    }
    
//    func requestJSON(method: HTTPMethod, _ urlString: String, params: [String: String]?, completion:((result: AnyObject?, error: NSError?) -> ())) {
//        
//    }
    // 定义闭包类型，类型别名－> 首字母一定要大写
    public typealias Completion = (result: AnyObject?, error: NSError?) -> ()
    
    
static let errorDomain = "com.dsxlocal.error"
    
    ///  请求 JSON
    ///
    ///  :param: method     HTTP 访问方法
    ///  :param: urlString  urlString
    ///  :param: params     可选参数字典
    ///  :param: completion 完成回调
    public func requestJSON(method: HTTPMethod, _ urlString: String, _ params: [String: String]?, completion: Completion) {
        
        // 实例化
        if let request = request(method, urlString, params){
            
            
            session!.dataTaskWithRequest(request, completionHandler: { (data, _, error) -> Void in
                
                
                // 如果有错误，直接回调，将错误返回
                if error != nil{
                    completion(result: nil, error: error)
                    return
                }
                
                let json:AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil)
                
                // 判断反序列化是否成功
                if json == nil{
                    let error = NSError(domain: SimpleNetwork.errorDomain, code: -1, userInfo: ["error":"反序列化失败"])
                    completion(result: nil, error: error)
                }else{
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completion(result: json, error: nil)
                    })
                }
            }).resume()
            
            return
        }
        
        let error = NSError(domain: SimpleNetwork.errorDomain, code: -1, userInfo: ["error":"反序列化失败"])
        completion(result: nil, error: error)
    }
    
    ///  返回网络访问的请求
    ///
    ///  :param: method    HTTP 访问方法
    ///  :param: urlString urlString
    ///  :param: params    可选参数字典
    ///
    ///  :returns: 可选网络请求
    func request(method:HTTPMethod, _ urlString: String, _ params:[String:String]?) ->NSURLRequest?{
        
        if urlString.isEmpty{
            return nil
        }
        
        var urlStr = urlString
        var req:NSMutableURLRequest?
        
        if method == .GET{
            
            let query = queryString(params)
            
            if query != nil{
                urlStr += "?" + query!
            }
            req = NSMutableURLRequest(URL: NSURL(string: urlStr)!)
        }else{
            
            if let query = queryString(params){
                req = NSMutableURLRequest(URL: NSURL(string: urlStr)!)
                
                // MARK:- 先哥
                req!.HTTPMethod = method.rawValue
                
                // lossy 是否允许松散的转换，无所谓的
                req!.HTTPBody = query.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
            
            }
        }
        return req
    }
    
    
    ///  生成查询字符串
    ///
    ///  :param: params 可选字典
    ///
    ///  :returns: 拼接完成的字符串
    func queryString(params: [String: String]?) -> String? {
        
        // 0. 判断参数
        if params == nil {
            return nil
        }
        
        // 涉及到数组的使用技巧
        // 1. 定义一个数组
        var array = [String]()
        // 2. 遍历字典
        for (k, v) in params! {
            let str = k + "=" + v.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            array.append(str)
        }
        
        return join("&", array)
    }
    
    ///  公共的初始化函数，外部就能够调用了
    public init() {}
    
    lazy var session:NSURLSession? = {
        return NSURLSession.sharedSession()
    }()
}
