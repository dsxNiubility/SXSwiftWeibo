//
//  OAuthViewController.swift
//  02-TDD
//
//  Created by apple on 15/2/28.
//  Copyright (c) 2015年 heima. All rights reserved.
//

import UIKit

class OAuthViewController: UIViewController {

    let WB_API_URL_String = "https://api.weibo.com"
    let WB_Redirect_URL_String = "http://www.baidu.com"
    
    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        loadAuthPage()
    }
    
    /// 加载授权页面
    func loadAuthPage() {
        let urlString = "https://api.weibo.com/oauth2/authorize?client_id=258115387&redirect_uri=http://www.baidu.com"
        let url = NSURL(string: urlString)
        
        webView.loadRequest(NSURLRequest(URL: url!))
    }
}

extension OAuthViewController: UIWebViewDelegate {
    
    func webViewDidStartLoad(webView: UIWebView) {
        println(__FUNCTION__)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        println(__FUNCTION__)
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        println(__FUNCTION__)
    }
    
    /// 页面重定向
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        println(request.URL)
        
        let result = continueWithCode(request.URL!)
        
        if let code = result.code {
            println("可以换 accesstoke \(code)")
 
//            let params = ["client_id": "2720451414",
//            "client_secret": "e061ff9a264a0bedb55226685b34c084",
//            "grant_type": "authorization_code",
//            "redirect_uri": WB_Redirect_URL_String,
//            "code": code]
//            
//            NetworkManager.sharedManager.requestJSON(method: .POST, urlString: "https://api.weibo.com/oauth2/access_token", parameters: params, result: { (json) -> () in
//                println(json)
//            })
        }
        if !result.load {
            println("不加载!")
            SVProgressHUD.showInfoWithStatus("不加载")
            // 如果不加载页面，需要重新刷新授权页面
            // TODO: 有可能会出现多次加载页面，不过现在貌似正常！
//            loadAuthPage()
        }
        
        return result.load
    }
    
    /// 根据 URL 判断是否继续加载页面
    /// 返回：是否加载，如果有 code，同时返回 code，否则返回 nil
    func continueWithCode(url: NSURL) -> (load: Bool, code: String?) {
        
        // 1. 将url转换成字符串
        let urlString = url.absoluteString!
        
        // 2. 如果不是微博的 api 地址，都不加载
        if !urlString.hasPrefix(WB_API_URL_String) {
            // 3. 如果是回调地址，需要判断 code
            if urlString.hasPrefix(WB_Redirect_URL_String) {
                if let query = url.query {
                    let codestr: NSString = "code="
                    
                    if query.hasPrefix(codestr as String) {
                        var q = query as NSString!
                        return (false, q.substringFromIndex(codestr.length))
                    }
                }
            }
            
            return (false, nil)
        }
        
        return (true, nil)
    }
}
