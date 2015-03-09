//
//  SXPhotoBrowserlViewController.swift
//  103 - swiftWeibo
//
//  Created by 董 尚先 on 15/3/8.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

import UIKit

class SXPhotoBrowserlViewController: UIViewController {
    
    var urls:[String]?
    
    var selectedIndex:Int = 0
  
    @IBOutlet weak var photoView: UICollectionView!
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    
    /// 类方法创建控制器
    class func photoBrowserViewController() ->SXPhotoBrowserlViewController {
        let sb = UIStoryboard(name: "PhotoBrowser", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! SXPhotoBrowserlViewController
        
        return vc
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

//       println("测试数据 \(urls) \(selectedIndex)")
        
        SVProgressHUD.show()
    }

    /// 将要排布
    override func viewWillLayoutSubviews() {
        
        layout.itemSize = view.bounds.size
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        photoView.pagingEnabled = true
    }
    
    /// 直接到第几页
    override func viewDidLayoutSubviews() {
        let indexPath = NSIndexPath(forItem: selectedIndex, inSection: 0)
        photoView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: false)
    }
    
    // 关闭
    @IBAction func close() {
        self.dismissViewControllerAnimated(true, completion: nil)
        SVProgressHUD.dismiss()
    }
    
    // 保存
    @IBAction func save() {
        
        if let indexPath = photoView.indexPathsForVisibleItems().last as? NSIndexPath {
            let cell = photoView.cellForItemAtIndexPath(indexPath) as! PhotoCell
            
            if let image = cell.imageView?.image{
                UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
            }
        }
        
    }
    
    /// 代理方法保存后的回调
    func image(image:UIImage, didFinishSavingWithError:NSError?,contextInfo:AnyObject?){
        if didFinishSavingWithError != nil {
            SVProgressHUD.showInfoWithStatus("保存出错")
        } else {
            SVProgressHUD.showInfoWithStatus("保存成功")
        }
    }
}

/// collection的数据源方法
extension SXPhotoBrowserlViewController:UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urls?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell
//        cell.backgroundColor = UIColor(red: random(), green: random(), blue: random(), alpha: 1)
        cell.imageView?.image = nil
        cell.urlString = urls![indexPath.item]
        
        println(cell.urlString)
        println(indexPath.item)
        
        return cell
    }
    
    func random() -> CGFloat{
       return CGFloat(arc4random_uniform(256))/255
    }
}


/// 图片查看器cell
class PhotoCell:UICollectionViewCell,UIScrollViewDelegate {
    
    var scrollView: UIScrollView?
    
    var imageView:UIImageView?
    
    /// 形变方法返回需要形变的对象
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView!
    }
    
    /// 形变结束后
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView!, atScale scale: CGFloat) {
        
        if isShortImage{
            let y = (frame.size.height - imageView!.frame.size.height) * 0.5
            scrollView.contentInset = UIEdgeInsetsMake(y, 0, 0, 0)
        }
    }
    
    
    
    /// 图像的url
    var urlString:String?{
        didSet{
            let net = NetworkManager.sharedManager
            
//            self.imageView!.image = nil
            net.requestImage(urlString!) { (result, error) -> () in
                if result != nil{
                    
                    var image = result as! UIImage
//                    self.imageView!.image = image
//                    self.calcImageSize(image.size)
                    self.setupImageView(image)
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    
    /// 通过图像大小处理图片（弃用）
    func calcImageSize(size:CGSize){
        
        var w = size.width
        var h = size.height
        
        imageView!.frame = bounds
        if(h/w > 2){
            imageView?.contentMode = UIViewContentMode.ScaleAspectFill
            scrollView!.contentSize = size
        }else{
            imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        }
    }
    
    var isShortImage = false
    
    /// 根据图像设置图像视图
    func setupImageView(image:UIImage){
        scrollView?.contentInset = UIEdgeInsetsZero
        scrollView?.contentSize = CGSizeZero
        scrollView?.contentOffset = CGPointZero
        
        var imageSize = image.size
        var screenSize = self.bounds.size
        
        let h = screenSize.width / imageSize.width * imageSize.height
        
        let rect = CGRectMake(0, 0, screenSize.width, h)
        
        imageView!.frame =  rect
        imageView!.image = image
        scrollView!.frame = self.bounds
        
        
        if  h > screenSize.height {
            /// 这就是长图了
            scrollView?.contentSize = rect.size
            
            isShortImage = false
            
        }else{
            /// 这就是普通图
            let y = (screenSize.height - h) * 0.5
            scrollView?.contentInset = UIEdgeInsetsMake(y, 0, 0, 0)
            
            isShortImage = true
        }
    }

    
    override func awakeFromNib() {
        scrollView = UIScrollView()
        self.addSubview(scrollView!)
        scrollView!.delegate = self
        scrollView!.maximumZoomScale = 2.0
        scrollView!.minimumZoomScale = 1.0
        
        imageView = UIImageView()
        scrollView!.addSubview(imageView!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView!.frame = self.bounds
    }
}
