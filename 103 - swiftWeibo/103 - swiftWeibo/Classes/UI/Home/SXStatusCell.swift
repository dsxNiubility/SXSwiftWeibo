//
//  SXStatusCell.swift
//  103 - swiftWeibo
//
//  Created by 董 尚先 on 15/3/6.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

import UIKit

class SXStatusCell: UITableViewCell {

    /// 头像
    @IBOutlet weak var iconImage: UIImageView!
    /// 姓名
    @IBOutlet weak var nameLabel: UILabel!
    /// 会员图标
    @IBOutlet weak var memberIcon: UIImageView!
    /// 认证图标
    @IBOutlet weak var vipIcon: UIImageView!
    /// 时间
    @IBOutlet weak var timeLabel: UILabel!
    /// 来源
    @IBOutlet weak var sourceLabel: UILabel!
    /// 微博正文
    @IBOutlet weak var contentLabel: UILabel!
    
    /// 配图视图
    @IBOutlet weak var pictureView: UICollectionView!
    /// 配图视图宽度
    @IBOutlet weak var pictureViewWidth: NSLayoutConstraint!
    /// 配图视图高度
    @IBOutlet weak var pictureViewHeight: NSLayoutConstraint!
    /// 配图视图布局
    @IBOutlet weak var pictureViewLayout: UICollectionViewFlowLayout!
    
    /// 底部工具视图
    @IBOutlet weak var bottomToolView: UIView!
    /// 转发微博文本
    @IBOutlet weak var forwardLabel: UILabel!
    
    /// 微博数据
    var status: Status? {
        didSet {
            nameLabel.text = status!.user!.name
            timeLabel.text = status!.created_at
            sourceLabel.text = status!.source
            contentLabel.text = status!.text
            
            // 头像
            if let iconUrl = status?.user?.profile_image_url {
                NetworkManager.sharedManager.requestImage(iconUrl) { (result, error) -> () in
                    if let image = result as? UIImage {
                        self.iconImage.image = image
                    }
                }
            }
            
            // 认证图标
            vipIcon.image = status?.user?.verifiedImage
            // 会员图标
            memberIcon.image = status?.user?.mbImage
            
            if memberIcon.image != nil{
                nameLabel.textColor = UIColor.orangeColor()
            }
            
            /// 计算尺寸
            let pSize = calsPictureViewSize()
            pictureViewWidth.constant = pSize.viewSize.width
            pictureViewHeight.constant = pSize.viewSize.height
            pictureViewLayout.itemSize = pSize.itemSize
            
            pictureView.reloadData()
            
            /// 设置转发的微博文字
            if status?.retweeted_status != nil{
                forwardLabel.text = status!.retweeted_status!.user!.name! + ":" + status!.retweeted_status!.text!
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // 设置微博正文换行的宽度
        contentLabel.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.width - 30
        // 如果是原创微博 cell 中不包含 forwardLabel
        forwardLabel?.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.width - 30
    }
    
    ///  返回微博数据对应的行高
    func cellHeight(status: Status) -> CGFloat {
        
        // 设置微博数据
        self.status = status
        
        // 强制更新布局
        layoutIfNeeded()
        
        // 返回工具视图底部的高度
        return CGRectGetMaxY(bottomToolView.frame)
    }
    
    ///  返回可重用标识符
    class func cellIdentifier(status: Status) -> String {
        if status.retweeted_status != nil {
            // 转发微博
            return "ForwardCell"
        } else {
            // 原创微博
            return "HomeCell"
        }
    }
    
    /// 定义一个图片被选择的闭包
    var photoDidSelected:((status:Status,photoIndex:Int) ->())?
    
}

extension SXStatusCell:UICollectionViewDataSource,UICollectionViewDelegate{
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        /// 如果有代码就执行
        if self.photoDidSelected != nil{
            self.photoDidSelected!(status:status!,photoIndex:indexPath.item)
        }
        
//        println("\(indexPath) \(self)")
    }
    
    ///  配图数量
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 配图的数量
        return status?.pictureUrls?.count ?? 0
    }
    
    ///  配图Cell
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PictureCell", forIndexPath: indexPath) as! PictureCell
    
        cell.urlString = status!.pictureUrls![indexPath.row].thumbnail_pic
        
        return cell
    }
    
    /**
    计算行高的方法
    
    :returns: 图片大小和背景view的大小
    */
    func calsPictureViewSize() -> (itemSize:CGSize,viewSize:CGSize){
        
        let s:CGFloat = 90
        var itemSize = CGSizeMake(s, s)
        
        var viewSize = CGSizeZero
        
        let count = status?.pictureUrls?.count ?? 0
        
//        println("配图数量 \(count)")
        if count == 0 {
            return (itemSize,viewSize)
        }
        
        if count == 1 {
            let path = NetworkManager.sharedManager.fullImageCachePath(status!.pictureUrls![0].thumbnail_pic!)
            if let image = UIImage(contentsOfFile: path){
                return (image.size,image.size)
            }else{
                return (itemSize,viewSize)
            }
        }
        
        let m:CGFloat = 10
        if count == 4{
            viewSize = CGSizeMake(s * 2 + m, s * 2 + m)
        }else {
            let row = (count - 1)/3
            viewSize = CGSizeMake(3 * s + 2 * m, (CGFloat(row)+1) * s + CGFloat(row) * m)
        }
        
        return(itemSize,viewSize)
        
    }
}

///  配图cell
class PictureCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    var urlString: String? {
        didSet {
            let path = NetworkManager.sharedManager.fullImageCachePath(urlString!)
            
            let image = UIImage(contentsOfFile: path)
            imageView.image = image
        }
    }
}
