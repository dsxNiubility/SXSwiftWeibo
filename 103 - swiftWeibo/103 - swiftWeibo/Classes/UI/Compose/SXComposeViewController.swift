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
            let params = ["access_token":token,"status":textView.fullText()]
            
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
//        println("\(emoticon.chs)")
        // 判断是否是删除按钮
        if emoticon.isDeleteButton {
            // 删除文字
            textView.deleteBackward()
            
            return
        }
        
        var str: String?
        if emoticon.chs != nil {
            str = emoticon.chs!
        } else if emoticon.emoji != nil {
            str = emoticon.emoji
        }
        if str == nil {
            return
        }
        
        // $$$$$ str
        // 手动调用代理方法 - 是否能够插入文本
        if textView(textView, shouldChangeTextInRange: textView.selectedRange, replacementText: str!) {
            /// 设置输入框的文字
            if emoticon.chs != nil {
                /// 从分类的方法中取
                textView.setTextEmoticon(emoticon)
                // 手动调用 didChage 方法
                textViewDidChange(textView)
                
            }else if emoticon.emoji != nil {
                /// 默认是把表情拼接到最后， 用这行代码是在光标位置插入文本
                textView.replaceRange(textView.selectedTextRange!, withText: emoticon.emoji!)
            }
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
        
        let len1 = (self.textView.fullText() as NSString).length
        let len2 = (text as NSString).length

        /// 超过了140个之后输入不了
        if len1 + len2 > 140 {
            return false
        }
        
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        let fullText = self.textView.fullText()
        
        self.textView.placeHolderLabel!.hidden = !fullText.isEmpty
        sendButton.enabled = !fullText.isEmpty
    }
    
    /// 滚动视图被拖拽
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        textView.resignFirstResponder()
    }
}
