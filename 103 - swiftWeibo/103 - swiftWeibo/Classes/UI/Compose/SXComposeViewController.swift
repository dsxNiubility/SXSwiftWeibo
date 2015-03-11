//
//  SXComposeViewController.swift
//  103 - swiftWeibo
//
//  Created by 董 尚先 on 15/3/5.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

import UIKit

class SXComposeViewController: UIViewController {
    
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

    /// 文本框
    @IBOutlet weak var textView: UITextView!
    
    /// 发送按钮
    @IBOutlet weak var sendButton: UIBarButtonItem!
    
    /// 底部约束
    @IBOutlet weak var toolBarBottomConstraint: NSLayoutConstraint!
    
    /// 取消按钮点击事件
    @IBAction func cancel(sender: UIBarButtonItem) {
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
        
        setupUI()
        
        registerNotification()
        
        self.addChildViewController(emoticonsVC!)
        
    }
    
    /// 设置UI
    func setupUI(){
        textView.alwaysBounceVertical = true
        
        textView.addSubview(placeHolderLabel!)
        
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
        
        var height: CGFloat = 0
        var duration = 0.25
        
        /// 取出键盘中的数值，swift有点麻烦 // $$$$$
        if notification.name == UIKeyboardWillChangeFrameNotification {
            let rect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            height = rect.size.height
            
            duration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        }
        
        toolBarBottomConstraint.constant = height
        
        UIView.animateWithDuration(0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    /// 懒加载表情视图控制器
    lazy var emoticonsVC:SXEmoticonsViewController? = {
        let sb = UIStoryboard(name: "Emoticons", bundle: nil)
        return sb.instantiateInitialViewController() as? SXEmoticonsViewController
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
        if textView.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) + text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 10 {
            return false
        }
        
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        placeHolderLabel?.hidden = !textView.text.isEmpty
        sendButton.enabled = !textView.text.isEmpty
    }
    
    /// 滚动视图被拖拽
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        textView.resignFirstResponder()
    }
}
