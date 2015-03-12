//
//  SXEmoticonsViewController.swift
//  103 - swiftWeibo
//
//  Created by 董 尚先 on 15/3/11.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

import UIKit

let reuseIdentifier = "Cell"

class SXEmoticonsViewController: UIViewController {

    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // 2. 定义代理 － weak，千万不要忘记 weak
    weak var delegate: EmoticonsViewControllerDelegate?
    
    
    /// 表情符号分组数组，每一个分组包含21个表情
    lazy var emoticonSection: [EmoticonsSection]? = {
        return EmoticonsSection.loadEmoticons()
        }()
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupLayout()
    }
    func setupLayout(){
        
        let row:CGFloat = 3
        let col:CGFloat = 7
        let m:CGFloat = 10
        
        let screenSize = self.collectionView.bounds.size
        let w = (screenSize.width - (col + 1) * m) / col
        
        layout.itemSize = CGSizeMake(w, w)
        layout.minimumInteritemSpacing = m
        layout.minimumLineSpacing = m
        
        /// 每一组之间的边距
        layout.sectionInset = UIEdgeInsetsMake(m, m, m, m)
        
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        
        collectionView.pagingEnabled = true
    }
}

protocol EmoticonsViewControllerDelegate: NSObjectProtocol {
    /// 选中了某一个标枪
    func emoticonsViewControllerDidSelectEmoticon(vc:SXEmoticonsViewController, emoticon: Emoticon)
}

/// 扩展的数据源方法
extension SXEmoticonsViewController:UICollectionViewDataSource,UICollectionViewDelegate{
    
    /// 根据 indexPath 返回表情数据
    func emoticon(indexPath: NSIndexPath) -> Emoticon {
        return emoticonSection![indexPath.section].emoticons[indexPath.item]
    }
    
    /// cell 被选中
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // 通过代理传递撰写微博视图控制器做后续处理
        println(emoticon(indexPath))
        // 3. 通知代理执行方法，注意这里的 ?
        // 使用 ? 不需要判断代理是否实现方法
        delegate?.emoticonsViewControllerDidSelectEmoticon(self, emoticon: emoticon(indexPath))
    }

    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        /// 返回有几种表情
        return emoticonSection?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        /// 返回每个种类中的表情数量
        return emoticonSection![section].emoticons.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EmoticonsCell", forIndexPath: indexPath) as! EmoticonCell
        
        
        /// 属性赋值
        cell.emoticon = emoticonSection![indexPath.section].emoticons[indexPath.item]
        
        return cell
    }
}

/// 表情的 cell
class EmoticonCell: UICollectionViewCell {
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var emojiLabel: UILabel!
    
    var emoticon: Emoticon? {
        /// 赋值完成后调用
        didSet {
            if let path = emoticon?.imagePath {
                iconView.image = UIImage(contentsOfFile: path)
            } else {
                iconView.image = nil
            }
            
            emojiLabel.text = emoticon?.emoji
        }
    }
}

