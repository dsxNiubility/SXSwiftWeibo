//
//  SXSwiftJ2M.swift
//  105 - SXSwiftJ2M
//
//  Created by 董 尚先 on 15/3/4.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

import Foundation

@objc protocol J2MProtocol{
    
    /**
    自定义的类型映射表
    
    - returns: 返回[属性名：自定义对象名称]
    */
    static func customeClassMapping()->[String:String]?
}

public class SXSwiftJ2M {
    
    /// 创建单例
    public static let sharedManager = SXSwiftJ2M()

/// MARK:- 使用字典转模型
    /**
    使用字典转模型
    
    - parameter dict: 数据字典
    - parameter cls:  模型的类
    
    - returns: 实例化类的对象
    */
   public func swiftObjWithDict(dict:NSDictionary,cls:AnyClass) ->AnyObject?{
        
        /// 取出模型类字典
        let dictInfo = GetAllModelInfo(cls)
        
        /// 实例化对象
        let obj:AnyObject = cls.alloc()
    
        autoreleasepool{
        
        for(k,v) in dictInfo{
            
            if let value:AnyObject = dict[k]{
//                println("要设置数值的 \(value) + key \(k)")
                
                /// 如果是基本数据类型直接kvc
                if v.isEmpty && !(value === NSNull()){   // $$$$$
                    obj.setValue(value, forKey: k)
                }else {
                
                    let type = "\(value.classForCoder)" // $$$$$ 取出某一个对象所属的类
                    
//                    println("自定义对象  \(value) \(k) \(v) 类型是 \(type) ")
                    
                    if type == "NSDictionary" {
                        // value 是字典－> 将 value 的字典转换成 Info 的对象
                        
                        if let subObj:AnyObject? = swiftObjWithDict(value as!NSDictionary, cls: NSClassFromString(v)){
                            
                            obj.setValue(subObj, forKey: k)
                        }
                        
                    } else if type == "NSArray" {
                        // value 是数组
                        // 如果是数组如何处理？ 遍历数组，继续处理数组中的字典
                        if let subObj:AnyObject? = swiftObjWithArray(value as!NSArray, cls: NSClassFromString(v)){
                            
                            obj.setValue(subObj, forKey: k)
                        }
                    }
                }
            }
        }
    }
//        println(dictInfo)
        return obj
           }
    
   
/// MARK:- 将数组转化成模型数组
    /**
    将数组转化成模型数组
    
    - parameter array: 数组
    - parameter cls:   模型类
    
    - returns: 模型数组
    */
    public func swiftObjWithArray(array:NSArray,cls:AnyClass) ->AnyObject?{
        
        var result = [AnyObject]()
        
        for value in array{
            let type = "\(value.classForCoder)"   // $$$$$
            
            if type == "NSDictionary"{
                
                if let subObj:AnyObject = swiftObjWithDict(value as! NSDictionary, cls: cls){
                    result.append(subObj)   // $$$$$
                }
                
            } else if type == "NSArray"{
                if let subObj:AnyObject = swiftObjWithArray(value as! NSArray, cls: cls){
                    result.append(subObj)
                }
            }
        }
        
        return result
    }

    /// 缓存字典
    var modleCache = [String:[String:String]]() // $$$$$
    
/// MARK:- 获取模型类的所有信息
    /**
    获取模型类的所有信息
    
    - parameter cls: 模型类
    
    - returns: 完整信息字典
    */
    func GetAllModelInfo(cls:AnyClass)->[String:String]{
        
        /// 先判断是否已经被缓存
        if let cache = modleCache["\(cls)"]{
//            println("\(cls)类已经被缓存")
            return cache
        }
        
        /// 循环查找父类，但是不会处理NSObject
        var currentcls:AnyClass = cls
        
        /// 定义模型字典
        var dictInfo = [String:String]()
        
        /// 循环遍历直到NSObject
        while let parent:AnyClass = currentcls.superclass(){  // $$$$$
            
            dictInfo.merge(GetModelInfo(currentcls))
            
            currentcls = parent
        }
        
        /// 写入缓存
        modleCache["\(cls)"] = dictInfo
        
        return dictInfo
    }
    
/// MARK:- 获取给定类的信息
    func GetModelInfo(cls:AnyClass) ->[String:String]{
        
        /// 判断是否遵循了协议，一旦遵循协议就是有自定义对象
        var mapping:[String : String]?
        if (cls.respondsToSelector("customeClassMapping")){    // $$$$$
            
            /// 得到属性字典
            mapping = cls.customeClassMapping()
            
//            println(mapping!)
        }
        
        /// 必须用UInt32否则不能调用
        var count:UInt32 = 0
        
        let ivars = class_copyIvarList(cls, &count)
        
        print("有 \(count) 个属性")
        
        var dictInfo = [String:String]()
        
        for i in 0..<count{
            /// 必须再强转成Int否则不能用来做下标
            let ivar = ivars[Int(i)]
            
            let cname = ivar_getName(ivar)
            let name = String.fromCString(cname)!
            
            /// 去属性字典中取，如果没有就使用后面的变量
            let type = mapping?[name] ?? ""   // $$$$$
            
            dictInfo[name] = type
            
        }
        /// 释放
        free(ivars)
        return dictInfo
    }
    
/// MARK:- 加载属性列表
    func loadProperties(cls:AnyClass){
        /// 必须用UInt32否则不能调用
        var count:UInt32 = 0

        let properties = class_copyPropertyList(cls, &count)
        
        print("有 \(count) 个属性")
        
        for i in 0..<count{
            /// 必须再强转成Int否则不能用来做下标
            let property = properties[Int(i)]
            
            let cname = property_getName(property)
            let name = String.fromCString(cname)!
            
            let ctype = property_getAttributes(property)
            let type = String.fromCString(ctype)!
            
            print(name + "--------" + type)
        }
        /// 释放
        free(properties)
        /// 基本数据类型不对，swift数组和字符串不对
    }
    
/// MARK:- 加载成员变量
    func loadIVars(cls:AnyClass){
        
        /// 必须用UInt32否则不能调用
        var count:UInt32 = 0
        
        let ivars = class_copyIvarList(cls, &count)
        
        print("有 \(count) 个属性")
        
        for i in 0..<count{
            /// 必须再强转成Int否则不能用来做下标
            let ivar = ivars[Int(i)]
            
            let cname = ivar_getName(ivar)
            let name = String.fromCString(cname)!
            
            let ctype = ivar_getTypeEncoding(ivar)
            let type = String.fromCString(ctype)!
            
            print(name + "--------" + type)
        }
        /// 释放
        free(ivars)
        /// 能够检测通过
    }
    
}

/// 相当于添加分类，泛型，拼接字典
extension Dictionary{
    mutating func merge<K,V>(dict:[K:V]){
        for (k,v) in dict{
            self.updateValue(v as! Value, forKey: k as! Key)
        }
    }
}
