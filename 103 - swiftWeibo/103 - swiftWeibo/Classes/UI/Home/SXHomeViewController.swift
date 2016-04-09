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
    
    /// 行高缓存
    lazy var rowHeightCache: NSCache? = {
        return NSCache()
        }()
    
    /// 上拉视图懒加载
    lazy var pullupView:RefreshView = {
        /// 转，不显示箭头
        return RefreshView.refreshView(true)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPullupView()
        
        loadData()
        

    }
    
    /// 设置上拉数据加载视图
    func setupPullupView(){
        tableView.tableFooterView = pullupView
        
        weak var weakSelf = self
        pullupView.addPullupOberserver(tableView){
            print("上啦加载数据啦！！！！")
            
            /// 获取到maxId
            if let maxId = weakSelf?.statusData?.statuses?.last?.id{
                
                weakSelf?.loadData(maxId - 1)
            }
            
        }
    }
    
    deinit {
        print("home视图控制器被释放!!!!!!")
        
        // 主动释放加载刷新视图对tableView的观察
        tableView.removeObserver(pullupView, forKeyPath: "contentOffset")
    }
    
    @IBAction func loadData(){
       loadData(0)
        
    }
    
    func loadData(maxId:Int){
        print("加载数据")
        
        refreshControl?.beginRefreshing()
        
        weak var weakSelf = self
        
        StatusesData.loadStatus(maxId) { (data, error) -> () in
            
            weakSelf!.refreshControl?.endRefreshing()
            
            if error != nil{
                print(error)
                SVProgressHUD.showInfoWithStatus("网络繁忙请重试")
            }
            if data != nil{
                
                if maxId == 0 {
                
                    weakSelf?.statusData = data
                    weakSelf?.tableView.reloadData()
                }else {
                    print("加载到了新的数据 进行数据拼接")
                    
                    let list = weakSelf!.statusData!.statuses! + data!.statuses!
                    weakSelf?.statusData?.statuses = list
                    
                    weakSelf?.tableView.reloadData()
                    
                    /// 复位刷新视图属性
                    weakSelf?.pullupView.isPullupLoading = false
                    weakSelf?.pullupView.stopLoading()
                }
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
//                println("\(status.text) \(index)")  // $$$$$
                weak var weakSelf = self
                
                let vc = SXPhotoBrowserlViewController.photoBrowserViewController()
                
                vc.urls = status.largeUrls
                vc.selectedIndex = index
                
                weakSelf!.presentViewController(vc, animated: true, completion: nil)
            }
        }
        
        
        cell.status = info.status
        
        return cell
    }
    
    // 行高的处理
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        // 提取cell信息
        let info = cellInfo(indexPath)
        // 判断是否已经缓存了行高
        if let h = rowHeightCache?.objectForKey("\(info.status.id)") as? NSNumber {
//            println("从缓存返回 \(h)")
            return CGFloat(h.floatValue)
        } else {
//            println("计算行高 \(__FUNCTION__) \(indexPath)")
            let cell = tableView.dequeueReusableCellWithIdentifier(info.cellId) as! SXStatusCell
            let height = cell.cellHeight(info.status)
            
            // 将行高添加到缓存 - swift 中向 NSCache/NSArray/NSDictrionary 中添加数值不需要包装
            rowHeightCache!.setObject(height, forKey: "\(info.status.id)")
            
            return cell.cellHeight(info.status)
        }
    }
    
    // 预估行高，可以提高性能
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 300
    }
    
}
