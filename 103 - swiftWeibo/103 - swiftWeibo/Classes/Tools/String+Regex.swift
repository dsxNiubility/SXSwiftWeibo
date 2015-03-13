
//
//  String+Regex.swift
//  103 - swiftWeibo
//
//  Created by 董 尚先 on 15/3/13.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

import Foundation

extension String {
    /// 删除字符串中 href 的引用
    func removeHref() -> String? {
        
        // 0. pattern 匹配方案 - 要过滤字符串最重要的依据
        // <a href="http://www.xxx.com/abc">XXX软件</a>
        // () 是要提取的匹配内容，不使用括号，就是要忽略的内容
        let pattern = "<a.*?>(.*?)</a>"
        
        // 定义正则表达式
        // DotMatchesLineSeparators 使用 . 可以匹配换行符
        // CaseInsensitive 忽略大小写
        let regex = NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive | NSRegularExpressionOptions.DotMatchesLineSeparators, error: nil)!
        
        // 匹配文字
        // firstMatchInString 在字符串中查找第一个匹配的内容
        // rangeAtIndex 函数是使用正则最重要的函数 -> 从 result 中获取到匹配文字的 range
        // index == 0，取出与 pattern 刚好匹配的内容
        // index == 1，取出第一个(.*?)中要匹配的内容
        // index 可以依次递增，对于复杂字符串过滤，可以使用多几个 ()
        let text = self as NSString
        let length = text.length
        // 不能直接使用 String.length，包含UNICODE的编码长度，会出现数组越界
        //        let length = self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        
        if let result = regex.firstMatchInString(self, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, length)) {
            
            // 匹配到内容
            return text.substringWithRange(result.rangeAtIndex(1))
        }
        
        return nil
    }

    
    /// 过滤表情字符串，生成属性字符串
    /**
    1. 匹配所有的 [xxx] 的内容
    2. 准备结果属性字符串
    
    3. 倒着遍历查询到的匹配结果
        3.1 用查找到的字符串，去表情数组中查找对应的表情对象
        3.2 用表情对象生成属性文本(使用 图片 attachment 替换结果字符串中 range 对应的 文本)
    
    4. 返回结果
    */
    func emoticonString() -> NSAttributedString? {
        
        // 1. pattern - [] 是正则表达式的特殊字符
        let pattern = "\\[(.*?)\\]"
        
        // 2. regex
        let regex = NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive | NSRegularExpressionOptions.DotMatchesLineSeparators, error: nil)!
        
        let text = self as NSString
        // 3. 多个匹配，[NSTextCheckingResult]
        let checkingResults = regex.matchesInString(self, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, text.length))
        
        // !!! 结果字符串
        var attributeString = NSMutableAttributedString(string: self)
        
        // 4. 倒着遍历匹配结果
        for var i = checkingResults.count - 1; i >= 0; i-- {
            let result = checkingResults[i] as! NSTextCheckingResult
            
            // 表情符号的文字
            let str = text.substringWithRange(result.rangeAtIndex(0))
            let e = emoticon(str)
            
            // 替换图像
            if e?.png != nil {
                // 生成图片附件，替换属性文本
                let attString = SXEmoteTextAttachment.attributeString(e!, height: 18)
                
                // 替换属性文本
                attributeString.replaceCharactersInRange(result.rangeAtIndex(0), withAttributedString: attString)
            }
        }
        //        for result in checkingResults {
        //            println(text.substringWithRange(result.rangeAtIndex(0)))
        //
        //            // 表情符号的文字
        //            let str = text.substringWithRange(result.rangeAtIndex(0))
        //            let e = emoticon(str)
        //
        //            println(e?.png)
        //        }
        
        return attributeString
    }
    
    /// 在表情列表中查找表情符号对象
    private func emoticon(str: String) -> Emoticon? {
        let emoticons = EmoticonList.sharedEmoticonList.allEmoticons
        
        // 遍历数组
        var emoticon: Emoticon?
        
        for e in emoticons {
            if e.chs == str {
                emoticon = e
                break
            }
        }
        
        return emoticon
    }

}