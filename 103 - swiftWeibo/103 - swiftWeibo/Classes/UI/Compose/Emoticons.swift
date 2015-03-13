
//
//  Emoticons.swift
//  103 - swiftWeibo
//
//  Created by 董 尚先 on 15/3/12.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

import Foundation

/// 表情符号分组
class EmoticonsSection {
    
    /// 分组名称
    var name: String
    /// 类型
    var type: String
    /// 路径
    var path: String
    /// 表情符号的数组(每一个 section中应该包含21个表情符号，界面处理是最方便的)
    /// 其中21个表情符号中，最后一个删除(就不能使用plist中的数据)
    var emoticons: [Emoticon]
    
    init(dict: NSDictionary) {
        name = dict["emoticon_group_name"] as! String
        type = dict["emoticon_group_type"] as! String
        path = dict["emoticon_group_path"] as! String
        emoticons = [Emoticon]()
    }
    
    /// 加载表情符号的分组数据
    class func loadEmoticons() -> [EmoticonsSection] {
        let path = NSBundle.mainBundle().bundlePath.stringByAppendingPathComponent("Emoticons/emoticons.plist")
        
        /// array是用大plist加载的数组
        var array = NSArray(contentsOfFile: path)
        
        /// 对数组进行排序
        array = array?.sortedArrayUsingComparator{ (dict1, dict2) -> NSComparisonResult in
            
            let type1 = dict1["emoticon_group_type"] as! String
            let type2 = dict2["emoticon_group_type"] as! String
            
            return type1.compare(type2)
        }
        
        /// 遍历数组
        var result = [EmoticonsSection]()
        for dict in array as! [NSDictionary] {
            
            /// 取出大数组中的每一种表情的字典
            result += loadEmoticons(dict)
        }
        return result
    }
    
    /// 加载表情符号数组 传入的dict是大数组中的每一种表情字典
    class func loadEmoticons(dict:NSDictionary) -> [EmoticonsSection] {
        
        /// 取出主目录数组中的数据，加载不同目录的info.plist
        let group_path = dict["emoticon_group_path"] as! String
        let path = NSBundle.mainBundle().bundlePath.stringByAppendingPathComponent("Emoticons/\(group_path)/info.plist")
        
        /// infoDict是info的小字典
        var infoDict = NSDictionary(contentsOfFile: path)!
        
        /// list是每一个表情的组合的数组
        let list = infoDict["emoticon_group_emoticons"] as! NSArray
        
        var result = loadArrayEmoticons(list, dict: dict)
        
        return result
    }
    
    /// 返回表情数组， 传入的dict是小infoPlist生成的字典
    class func loadArrayEmoticons(list:NSArray,dict:NSDictionary) -> [EmoticonsSection] {
        
        /// 规定多少个可以组成一组
        let emoticonCount = 20
        
        /// 算出一共会组成多少组
        let objCount = (list.count - 1) / emoticonCount + 1
        
        var result = [EmoticonsSection]()
        
        for i in 0..<objCount {
            
            // 通过每一个info建立每一种的表情数组
            var emoticonSection = EmoticonsSection(dict: dict)
            
            for count in 0..<20 {
                let j = count + i * emoticonCount
                
                var dict: NSDictionary? = nil
                
                /// list是每一个表情的组合的数组
                if j < list.count {
                    dict = list[j] as? NSDictionary
                }
                /// 这个dict 是表情数组里的每一个表情自己的小字典
                let em = Emoticon(dict: dict, path: emoticonSection.path)
                emoticonSection.emoticons.append(em)
            }
            
            /// 添加删除按钮的模型
            let em = Emoticon(dict: nil, path: nil)
            em.isDeleteButton = true
            emoticonSection.emoticons.append(em)
            
            /// 将每一种添加到大数组
            result.append(emoticonSection)
        }
        return result
    }
}


/// 表情符号类
class Emoticon {
    
    /// emoji 的16进制字符串
    var code: String?
    /// emoji 字符串
    var emoji: String?
    
    /// 类型
    var type: String?
    /// 表情符号的文本 - 发送给服务器的文本
    var chs: String?
    /// 表情符号的图片 - 本地做图文混排使用的图片
    var png: String?
    /// 图像的完整路径
    var imagePath: String?
    /// 是否是删除按钮
    var isDeleteButton = false
    
    init(dict:NSDictionary?,path: String? ) {
        code = dict?["code"] as? String
        type = dict?["type"] as? String
        chs = dict?["chs"] as? String
        png = dict?["png"] as? String
        
        if path != nil && png != nil {
            imagePath = NSBundle.mainBundle().bundlePath.stringByAppendingPathComponent("Emoticons/\(path!)/\(png!)")
        }
        
        /// 计算 emoji
        if code != nil {
            let scanner = NSScanner(string: code!)
            
            var value:UInt32 = 0
            scanner.scanHexInt(&value)
            emoji = "\(Character(UnicodeScalar(value)))"
        }
    }
    
}