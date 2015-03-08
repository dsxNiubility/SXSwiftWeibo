//
//  SXHomeViewController.swift
//  103 - swiftWeibo
//
//  Created by 董 尚先 on 15/3/5.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

import UIKit

class SXHomeViewController: UITableViewController {

    var height:CGFloat?
    var indexNo:NSInteger?
    
    var statusData: StatusesData?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
    }
    
    func loadData(){
        println("加载数据")
        SVProgressHUD.show()
        StatusesData.loadStatus { (data, error) -> () in
            if error != nil{
                println(error)
                SVProgressHUD.showInfoWithStatus("网络繁忙请重试")
            }
            SVProgressHUD.dismiss()
            if data != nil{
                self.statusData = data
                self.tableView.reloadData()
            }
        }
    }
}

extension SXHomeViewController:UITableViewDataSource,UITableViewDelegate{
    
    ///  根据indexPath 返回微博数据&可重用标识符
    func cellInfo(indexPath: NSIndexPath) -> (status: Status, cellId: String) {
        let status = self.statusData!.statuses![indexPath.row]
        let cellId = SXStatusCell.cellIdentifier(status)
        
//        println("耗时操作 indexPath \(indexPath.row)  " + __FUNCTION__)
        
        return (status, cellId)
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.statusData?.statuses?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // 提取cell信息
        let info = cellInfo(indexPath)
        
        let cell = tableView.dequeueReusableCellWithIdentifier(info.cellId, forIndexPath: indexPath) as! SXStatusCell
        
        //            dispatch_async(dispatch_get_main_queue(), { () -> Void in
        //
        //            })
        
        if cell.photoDidSelected == nil{
            cell.photoDidSelected = { (status:Status!,index:Int)-> Void in
                println("\(status.text) \(index)")  // $$$$$
                
                let vc = SXPhotoBrowserlViewController.photoBrowserViewController()
                
                vc.urls = info.status.largeUrls
                vc.selectedIndex = index
                
                self.presentViewController(vc, animated: true, completion: nil)
            }
        }
        
        
        cell.status = info.status
        
        return cell
    }
    
    // 行高的处理
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if self.indexNo == indexPath.row{
            return self.height!
        }
        
        // 提取cell信息
        let info = cellInfo(indexPath)
        let cell = tableView.dequeueReusableCellWithIdentifier(info.cellId) as! SXStatusCell
        
        self.indexNo = indexPath.row
        self.height =  cell.cellHeight(info.status)
        return self.height!
    }
    
    // 预估行高，可以提高性能
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 300
    }
    
}
