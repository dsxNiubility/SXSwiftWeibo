//
//  SXHomeViewController.swift
//  103 - swiftWeibo
//
//  Created by 董 尚先 on 15/3/5.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

import UIKit

class SXHomeViewController: UITableViewController {

    
    var statusData: StatusesData?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
    }
    
    func loadData(){
        println("加载数据")
        StatusesData.loadStatus { (data, error) -> () in
            SVProgressHUD.show()
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
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.statusData?.statuses?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("HomeCell", forIndexPath: indexPath) as! UITableViewCell
        
        let status = self.statusData!.statuses![indexPath.row]
        
        cell.textLabel!.text = status.text
        
        return cell
    }
    

}
