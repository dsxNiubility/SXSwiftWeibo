//
//  SimpleNetworkTests.swift
//  SimpleNetworkTests
//
//  Created by 董 尚先 on 15/3/2.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

import UIKit
import XCTest

class SimpleNetworkTests: XCTestCase {
    
    /// 测试网络地址
    let urlString = "http://www.baidu.com"
    let net = SimpleNetwork()
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    // MARK:- 期望
    func testRequestJSON() {
        // 1. 定义一个"期望" -> 描述异步的需求，只是一个标记而已
        let expectation = expectationWithDescription(urlString)
        
        net.requestJSON(.GET, urlString, nil) { (result, error) -> () in
            println(result)
            
            // 2. 标记"期望达成"
            expectation.fulfill()
        }
        // 3. 等待期望达成
        // 参数时间：等待异步操作必须在10s钟之内完成
        waitForExpectationsWithTimeout(10.0, handler: { (error) -> Void in
            XCTAssertNil(error)
        })
    }
    
    
    /// 测试错误的网络请求
    func testErrorNetRequest(){
        net.requestJSON(.GET, "", nil) { (result, error) -> () in
            println(error)
            XCTAssertNotNil(error, "必须要返回错误")
        }
    }
    
    /// 测试post内容
    func testPostRequest(){
        
        var r = net.request(.POST, urlString, nil)
        XCTAssertNil(r, "请求应该为空")
        
        r = net.request(.POST, urlString, ["name":"zhangsan"])
        // 测试请求头
        XCTAssert(r!.HTTPMethod == "POST", "访问方法不正确")
        // 测试请求体
        XCTAssert(r!.HTTPBody == "name=zhangsan".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true), "请求体不正确")
        
    }
    
    /// 测试请求的内容
    func testGetRequest(){
        
        var r = net.request(.GET, "", nil)
        XCTAssertNil(r, "请求应该为空")
        r = net.request(.POST, "", nil)
        XCTAssertNil(r, "请求应该为空")
        
        r = net.request(.GET, urlString , nil)
        XCTAssertNotNil(r, "请求应该被建立")
        
        r = net.request(.GET, urlString, ["name":"zhangsan"])
        XCTAssert(r!.URL!.absoluteString == urlString + "?name=zhangsan", "返回的URL不对")
    
    }
    
    
    /**
    测试拼接字符串
    */
    func testQueryString(){
        
        let net = SimpleNetwork()
        
        XCTAssertNil(net.queryString(nil), "查询参数不能为空")
        println(net.queryString(["name":"zhangsan"])!)
        XCTAssert(net.queryString(["name":"zhangsan"])! == "name=zhangsan", "单个参数拼串不正确")
        println(net.queryString(["name":"zhangsan","title":"BOSS","school":"stanford"])!)
        XCTAssert(net.queryString(["name":"zhangsan","title":"BOSS","school":"stanford"])! == "title=BOSS&school=stanford&name=zhangsan", "多个参数拼串不正确")
        // 测试百分号转义
        println(net.queryString(["name": "zhangsan", "book": "ios 8.0"])!)
        XCTAssert(net.queryString(["name": "zhangsan", "book": "ios 8.0"])! == "book=ios%208.0&name=zhangsan")
        
    }
    
}
