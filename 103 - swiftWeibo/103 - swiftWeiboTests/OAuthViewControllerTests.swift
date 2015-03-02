//
//  OAuthViewControllerTests.swift
//  02-TDD
//
//  Created by apple on 15/2/28.
//  Copyright (c) 2015年 heima. All rights reserved.
//

import UIKit
import XCTest

/**
    所有要测试的函数都是以 test 开头的

    setUp()
        test1()
        test2()
        test3()
    tearDown()

    在跑测试的时候，可以一次跑所有，也可以一次只跑一个

    在实际开发中
    先写测试－运行是红色的－红灯
    再写代码－运行是绿色的－绿灯
    重构－红灯，绿灯

    单元测试有被叫做红灯绿灯开发！

    断言： XCTAssert 
    提前预判符合某一种条件！

    - 在单元测试中，如果不符合断言条件，就会报错！
    - 在正规的代码中，同样可以使用断言
    - 在测试的时候，如果不符合条件，运行时会直接崩溃！
    - 在发布的时候，如果不符合条件，但是代码本身能够执行，会继续执行，断言不会对程序的运行造成任何的影响！
    - 发布模式，assert 会被忽略

    - assert 几乎是所有 C/C++ 程序员的最爱！
    - 会不会用断言，直接体现开发的经验！
    - OC 中为什么断言用的那么少呢？因为 oc 是消息机制，可以给 nil 发送消息，不会报错！
    - 提示：今后开发中，可以大胆的使用断言！
    - 相当于代码的保护锁！只是在调试模式下有效
*/
class OAuthViewControllerTests: XCTestCase {

    // 在运行测试之前，运行一次，可以做全局的初始化
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    // 在运行结束之前，运行一次，可以做销毁动作
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /// 测试随机的 code
    func testRandomCode() {
        for i in 0...20 {
            let democode = "7b54cde6155f23bc189fad24c150c6a7\(i)"
            
            let url = NSURL(string: "http://www.itheima.com/?code=\(democode)")!
            let result = oauthVC!.continueWithCode(url)
            XCTAssertFalse(result.load, "不应该加载")
            XCTAssert(result.code == democode, "code 不正确")
        }
    }
    
    // MARK: - 测试处理 URL
    // 测试函数名 test+函数名
    // 测试用例：就是测试使用的例子
    func testContiuneWithCode() {
        /**
        1. 如果地址的主机是 api.weibo.com，需要加载，否则不加载
        2. code 的条件，返回的地址是预先设定的
            回调地址 http://www.itheima.com 同样不需要加载
                同时 query 是以 code= 开头    需要返回 code
                其他的 quert 不需要加载，没有code
        */
        
        // 登录界面的 URL
        // 应该加载，没有 code
        var url = NSURL(string: "https://api.weibo.com/oauth2/authorize?client_id=2720451414&redirect_uri=http://www.itheima.com")!
        var result = oauthVC!.continueWithCode(url)
        
        XCTAssertTrue(result.load, "应该加载")
        XCTAssertNil(result.code, "不应该有code")
        
        // 点击注册按钮
        // 不加载，没有code
        url = NSURL(string: "http://weibo.cn/dpool/ttt/h5/reg.php?wm=4406&appsrc=4o1TqS&backURL=https%3A%2F%2Fapi.weibo.com%2F2%2Foauth2%2Fauthorize%3Fclient_id%3D2720451414%26response_type%3Dcode%26display%3Dmobile%26redirect_uri%3Dhttp%253A%252F%252Fwww.itheima.com%26from%3D%26with_cookie%3D")!
        result = oauthVC!.continueWithCode(url)
        XCTAssertFalse(result.load, "不应该加载")
        XCTAssertNil(result.code, "不应该有code")
        
        // 登录成功
        url = NSURL(string: "https://api.weibo.com/oauth2/authorize")!
        result = oauthVC!.continueWithCode(url)
        XCTAssertTrue(result.load, "应该加载")
        XCTAssertNil(result.code, "不应该有code")

        // 授权回调 － 测试用例
        let democode = "7b54cde6155f23bc189fad24c150c6a7"
        
        url = NSURL(string: "http://www.itheima.com/?code=\(democode)")!
        result = oauthVC!.continueWithCode(url)
        XCTAssertFalse(result.load, "不应该加载")
        XCTAssert(result.code == democode, "code 不正确")
        
        // 取消授权
        url = NSURL(string: "http://www.itheima.com/?error_uri=%2Foauth2%2Fauthorize&error=access_denied&error_description=user%20denied%20your%20request.&error_code=21330")!
        result = oauthVC!.continueWithCode(url)
        XCTAssertFalse(result.load, "不应该加载")
        XCTAssertNil(result.code, "不应该有code")

        // 切换账号
        url = NSURL(string: "http://login.sina.com.cn/sso/logout.php?entry=openapi&r=https%3A%2F%2Fapi.weibo.com%2Foauth2%2Fauthorize%3Fclient_id%3D2720451414%26redirect_uri%3Dhttp%3A%2F%2Fwww.itheima.com")!
        result = oauthVC!.continueWithCode(url)
        XCTAssertFalse(result.load, "不应该加载")
        XCTAssertNil(result.code, "不应该有code")
    }
    
    // MARK: - 测试界面
    /**
        1. 从 storyboard加载viewControlller
        2. 根视图是 UIWebView
        3. webView的代理是视图控制器
    */
    // 根视图是 UIWebView
    func testRootView() {
        let view = oauthVC!.view
        
        // 断言：视图是一个 UIWebView，如果不是 UIWebView 就会报错！
        XCTAssert(view.isKindOfClass(UIWebView.self), "根视图类型不是 webView")
    }
    
    /// 测试根视图控制器的代理
    func testRootViewDelegate() {
        let webView = oauthVC!.view as! UIWebView
        
        // === 是 swift 中判断两个对象是否恒等的方法，对象类型相同，指针地址一致
        XCTAssert(webView.delegate === oauthVC!, "没有设置代理")
    }
    
    /// 测试使用的视图控制器
    lazy var oauthVC: OAuthViewController? = {
     
        let bundle = NSBundle(forClass: OAuthViewControllerTests.self)
        println(bundle)
        let sb = UIStoryboard(name: "OAuth", bundle: bundle)
        // 拿到视图控制器
        return sb.instantiateInitialViewController() as? OAuthViewController
    }()

}
