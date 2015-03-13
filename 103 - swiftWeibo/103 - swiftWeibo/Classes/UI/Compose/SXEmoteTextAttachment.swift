//
//  SXEmoteTextAttachment.swift
//  103 - swiftWeibo
//
//  Created by 董 尚先 on 15/3/12.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

import UIKit

class SXEmoteTextAttachment: NSTextAttachment {
    // 表情对应的文本符号
    var emoteString: String?
    
    /// 返回一个 属性字符串
    class func attributeString(emoticon: Emoticon, height: CGFloat) -> NSAttributedString {
        var attachment = SXEmoteTextAttachment()
        attachment.image = UIImage(contentsOfFile: emoticon.imagePath!)
        attachment.emoteString = emoticon.chs
        
        // 设置高度
        attachment.bounds = CGRectMake(0, -4, height, height)
        
        // 2. 带图像的属性文本
        return NSAttributedString(attachment: attachment)
    }
}
