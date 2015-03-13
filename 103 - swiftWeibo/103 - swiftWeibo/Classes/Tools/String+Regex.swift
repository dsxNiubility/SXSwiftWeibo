
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


}