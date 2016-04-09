//
//  SXComposeTextView.swift
//  103 - swiftWeibo
//
//  Created by 董 尚先 on 15/3/13.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

import UIKit

class SXComposeTextView: UITextView {
    /// 占位文本
    lazy var placeHolderLabel:UILabel? = {
        let l = UILabel()
        l.text = "分享新鲜事..."
        l.font = UIFont.systemFontOfSize(18)
        l.textColor = UIColor.lightGrayColor()
        l.frame = CGRectMake(5, 8, 0, 0)
        l.sizeToFit()
        return l
        }()
    
    override func awakeFromNib() {
        // 添加占位文本
        addSubview(placeHolderLabel!)
        
        // 文本框默认不支持滚动，设置此属性后，能够滚动！
        alwaysBounceVertical = true
    }
    
    func setTextEmoticon(emoticon :Emoticon) {
        var attributeString = SXEmoteTextAttachment.attributeString(emoticon, height: font.lineHeight)
        
        /// 替换 textView中的属性文本
        var strM = NSMutableAttributedString(attributedString: attributedText)
        strM.replaceCharactersInRange(selectedRange, withAttributedString: attributeString)
        
        /// 需要设置整个字符串的文本属性， 设置fontName 是 textView.font
        let range = NSMakeRange(0, strM.length)
        strM.addAttribute(NSFontAttributeName, value: font, range: range)
        
        /// 先记录光标的位置再赋值，最后要恢复光标位置
        var location = selectedRange.location
        attributedText = strM
        selectedRange = NSMakeRange(location + 1, 0)
        
    }
    
    /// 返回文本框中完成文字 - 将表情图片转换成表情符号
    func fullText() -> String {
        var result = String()
        let textRange = NSMakeRange(0, attributedText.length)
        
        attributedText.enumerateAttributesInRange(textRange, options: NSAttributedStringEnumerationOptions(), usingBlock: { (dict, range, _) -> Void in
            
            if let attachment = dict["NSAttachment"] as? SXEmoteTextAttachment {
                // 图片
                result += attachment.emoteString!
            } else {
                result += (self.attributedText.string as NSString).substringWithRange(range)
            }
        })
        print("微博文本：\(result)")
        
        return result
    }
}
