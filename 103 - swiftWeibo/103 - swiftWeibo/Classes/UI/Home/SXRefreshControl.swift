//
//  SXRefreshControl.swift
//  103 - swiftWeibo
//
//  Created by 董 尚先 on 15/3/9.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

import UIKit

class SXRefreshControl: UIRefreshControl {
    
    lazy var refreshV : RefreshView = {
        let v = NSBundle.mainBundle().loadNibNamed("RefreshView", owner: nil, options: nil).last as! RefreshView
        return v
    }()
    
    override func willMoveToWindow(newWindow: UIWindow?) {
        refreshV.frame = self.bounds
    }
    
    /// 添加到父控件添加观察者
    override func awakeFromNib() {
        
        self.addSubview(refreshV)
        
        self.addObserver(self, forKeyPath: "frame", options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    /// 销毁观察者
    deinit{
        println("SXRefreshControl   888")
        self.removeObserver(self, forKeyPath: "frame")
    }
    
    /// 正在加载动画效果
    var isLoading = false
    /// 旋转提示图标记
    var isRotateTip = false
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        if self.frame.origin.y > 0{
            return
        }       // $$$$$
        
        /// 如果正在刷新，并且也正在动画，直接返回性能压力减小
        if refreshing && !isLoading{
            
            refreshV.showLoading()
            isLoading = true
            
            return
        }
        
        if self.frame.origin.y < -50 && !isRotateTip {
            isRotateTip = true
            refreshV.rotateTipIcon(isRotateTip)
        }else if self.frame.origin.y > -50 && isRotateTip {
            isRotateTip = false
            refreshV.rotateTipIcon(isRotateTip)
        }
        
    }
    
    /// 结束刷新
    override func endRefreshing() {
        super.endRefreshing()
        
        /// 停止动画
        refreshV.stopLoading()
        
        /// 修正标记
        isLoading = false
    }
}

class RefreshView: UIView {
    ///  提示视图
    @IBOutlet weak var tipView: UIView!
    ///  提示图标
    @IBOutlet weak var tipIcon: UIImageView!
    ///  加载视图
    @IBOutlet weak var loadingView: UIView!
    ///  加载图标
    @IBOutlet weak var loadingIcon: UIImageView!
    
    func showLoading(){
        tipView.hidden = true
        loadingView.hidden = false
        
        /// 添加动画
        loadingAnimation()
    }
    
    /// 加载动画
    func loadingAnimation(){
        let animate = CABasicAnimation(keyPath: "transform.rotation")
        
        animate.toValue = 2 * M_PI
        
        animate.repeatCount = MAXFLOAT
        
        animate.duration = 0.5
        
        /// 将动画添加到图层
        loadingIcon.layer.addAnimation(animate, forKey: nil)
        
    }
    
    /// 停止加载动画
    func stopLoading(){
        loadingIcon.layer.removeAllAnimations()
        
        tipView.hidden = false
        loadingView.hidden = true
    }
    
    ///  旋转提示图标   // $$$$$
    func rotateTipIcon(clockWise: Bool) {
        
        // 旋转都是就近原则，如果转半圈，会找近路
        var angel = CGFloat(M_PI + 0.01)
        if clockWise {
            angel = CGFloat(M_PI - 0.01)
        }
        
        weak var weakSelf = self
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            // 旋转提示图标 180
            weakSelf!.tipIcon.transform = CGAffineTransformRotate(self.tipIcon.transform, angel)
        })
    }
    
    /// MARK: - 上拉刷新部分代码
   weak var parentView :UITableView?
    
    /// 给parentView添加观察者
    func addPullupOberserver(parentView:UITableView,pullupLoadData:()->()){
        
        
        
        self.parentView = parentView
        
        self.parentView = parentView
        
        self.PullupLoadData = pullupLoadData
        
        self.parentView!.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.New, context: nil)
        
        
    }
    
    deinit{
        println("RefreshView   888")
//        parentView!.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    /// 上啦加载数据标记
    var isPullupLoading = false
    /// 上啦刷新的闭包
    var PullupLoadData:(()->())?
    
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        /// 界面首次加载时，这里不显示上啦
        if self.frame.origin.y == 0{
            return
        }
        
        if (parentView!.bounds.size.height + parentView!.contentOffset.y) > CGRectGetMaxY(self.frame){
            // $$$$$
            /// 保证上啦只有一次是有效的
            if !isPullupLoading{
                isPullupLoading = true
                
                showLoading()
                
                /// 如果有闭包就执行闭包
                if PullupLoadData != nil{
                    PullupLoadData!()
                }
            }
        }
    }


}


