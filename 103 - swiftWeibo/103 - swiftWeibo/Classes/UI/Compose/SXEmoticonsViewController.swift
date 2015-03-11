//
//  SXEmoticonsViewController.swift
//  103 - swiftWeibo
//
//  Created by 董 尚先 on 15/3/11.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

import UIKit

class SXEmoticonsViewController: UIViewController {

    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var collectionView: UICollectionView!
    

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

extension SXEmoticonsViewController:UICollectionViewDataSource{
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 21
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EmoticonsCell", forIndexPath: indexPath) as! UICollectionViewCell
        
        if indexPath.section == 1 {
            cell.backgroundColor = UIColor.orangeColor()
        } else {
            cell.backgroundColor = UIColor.redColor()
        }
        
        return cell
    }
    
}
