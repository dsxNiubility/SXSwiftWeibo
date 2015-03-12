//
//  SXComposeViewController.swift
//  103 - swiftWeibo
//
//  Created by 董 尚先 on 15/3/5.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

import UIKit

class SXComposeViewController: UIViewController {
    


    /// 文本框
    @IBOutlet weak var textView: SXComposeTextView!
    
    /// 发送按钮
    @IBOutlet weak var sendButton: UIBarButtonItem!
    
    /// 底部约束
    @IBOutlet weak var toolBarBottomConstraint: NSLayoutConstraint!
    
    /// 取消按钮点击事件
    @IBAction func cancel(sender: UIBarButtonItem) {
        
        /// 为了更好的用户体验先缩键盘再缩文本框
        self.textView.resignFirstResponder()
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /// 发微博
    @IBAction func sendStatus(sender: UIBarButtonItem) {
        let urlString = "https://api.weibo.com/2/statuses/update.json"
        
        if let token = AccessToken.loadAccessToken()?.access_token{
            let params = ["access_token":token,"status":textView.text!]
            
            let net = NetworkManager.sharedManager
            
            net.requestJSON(.POST, urlString, params){ (result, error) -> () in
                SVProgressHUD.showInfoWithStatus("微博发送成功")
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerNotification()
        
        self.addChildViewController(emoticonsVC!)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    
    /// 注册键盘的通知
    func registerNotification(){
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardFrameChanged:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardFrameChanged:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardFrameChanged(notification:NSNotification) {
        
        
        /// 取出键盘中的数值，swift有点麻烦 // $$$$$
        if notification.name == UIKeyboardWillChangeFrameNotification {
            let rect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            let height = rect.size.height
            
            let duration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
            toolBarBottomConstraint.constant = height
            
            UIView.animateWithDuration(duration) {
                self.view.layoutIfNeeded()
            }
        }else {
            /// 这就是键盘隐藏的通知执行
            toolBarBottomConstraint.constant = 0
        }
        
    }
    
    /// 懒加载表情视图控制器
    lazy var emoticonsVC:SXEmoticonsViewController? = {
        let sb = UIStoryboard(name: "Emoticons", bundle: nil)
        let vc = sb.instantiateInitialViewController() as? SXEmoticonsViewController
        
        // 1. 设置代理
        vc?.delegate = self
        
        return vc
    }()
    
    
    /// 选择表情按钮
    @IBAction func selectEmote() {
        
        /// 先取消响应者再打开
        textView.resignFirstResponder()
        
        if textView.inputView == nil{
            textView.inputView = emoticonsVC?.view
        }else{
            textView.inputView = nil
        }
        
        textView.becomeFirstResponder()
    
    }
}

// 2. 遵守协议(通过 extension)并且实现方法！
extension SXComposeViewController: EmoticonsViewControllerDelegate {
    
    func emoticonsViewControllerDidSelectEmoticon(vc: SXEmoticonsViewController, emoticon: Emoticon) {
        println("\(emoticon.chs)")
        
        /// 设置输入框的文字
        var str: String?
        if emoticon.chs != nil {
//            /// 图文混排的入口
//            var str = emoticon.chs
//            
//            /// 设置图像
//            var attachement = NSTextAttachment()
//            attachement.image = UIImage(contentsOfFile: emoticon.imagePath!)
//            
//            /// 设置行高避免不一样大
//            let height = textView.font.lineHeight
//            attachement.bounds = CGRectMake(0, 0, height, height)
//            var attributeString = NSAttributedString(attachment: attachement)
            
            /// 从分类的方法中取
            var attributeString = SXEmoteTextAttachment.attributeString(emoticon, height: textView.font.lineHeight)
            
            /// 替换 textView中的属性文本
            var strM = NSMutableAttributedString(attributedString: textView.attributedText)
            strM.replaceCharactersInRange(textView.selectedRange, withAttributedString: attributeString)
            
            /// 需要设置整个字符串的文本属性， 设置fontName 是 textView.font
            let range = NSMakeRange(0, strM.length)
            strM.addAttribute(NSFontAttributeName, value: textView.font, range: range)
            
            /// 先记录光标的位置再赋值，最后要恢复光标位置
            var location = textView.selectedRange.location
            textView.attributedText = strM
            textView.selectedRange = NSMakeRange(location + 1, 0)
            
        }else if emoticon.emoji != nil {
            /// 默认是把表情拼接到最后， 用这行代码是在光标位置插入文本
            textView.replaceRange(textView.selectedTextRange!, withText: emoticon.emoji!)
            
            
        }
    }
}


extension SXComposeViewController:UITextViewDelegate{
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        /// 让删除键有效
        if text.isEmpty{
            return true
        }
        
        if text == "\n"{
            println("回车键")
        }
        
        /// 超过了140个之后输入不了
        if textView.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) + text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 140 {
            return false
        }
        
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        self.textView.placeHolderLabel!.hidden = !self.textView.text.isEmpty
        sendButton.enabled = !textView.text.isEmpty
    }
    
    /// 滚动视图被拖拽
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        textView.resignFirstResponder()
    }
}
