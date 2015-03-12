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


}
