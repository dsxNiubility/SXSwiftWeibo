//
//  AccessTokenTests.swift
//  103 - swiftWeibo
//
//  Created by 董 尚先 on 15/3/4.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

import UIKit
import XCTest

class AccessTokenTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIsExpired() {
        var dict = ["access_token": "2.00p_CPCE06bBTR613268deb0yyv5oD",
            "expires_in": 1,
            "remind_in": 157679999,
            "uid": 3697667837]
        
        var token = AccessToken(dict: dict)
        print(token.isExpired)
        
        dict = ["access_token": "2.00p_CPCE06bBTR613268deb0yyv5oD",
            "expires_in": 0,
            "remind_in": 157679999,
            "uid": 3697667837]
        
        token = AccessToken(dict: dict)
        print(token.isExpired)
        
        dict = ["access_token": "2.00p_CPCE06bBTR613268deb0yyv5oD",
            "expires_in": -1,
            "remind_in": 157679999,
            "uid": 3697667837]
        
        token = AccessToken(dict: dict)
        print(token.isExpired)
    }

    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
