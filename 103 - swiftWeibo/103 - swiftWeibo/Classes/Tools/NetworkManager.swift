
//
//  NetworkManager.swift
//  103 - swiftWeibo
//
//  Created by 董 尚先 on 15/3/2.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

import Foundation
import SimpleNetwork

class NetworkManager {
    
    private static let instance = NetworkManager()
    
    class var sharedManager:NetworkManager{
        return instance
    }
    
    typealias Completion = (result:AnyObject?,error:NSError?) ->()
    
    // 隔离一层大框架
    private let net = SimpleNetwork()
    
    // 自己写个一模一样的方法 调大框架的方法
    func requestJSON(method:HTTPMethod, _ urlString:String, _ params:[String:String]?,completion:Completion){
        
        net.requestJSON(method, urlString, params, completion: completion)
    
    }
    
    
}