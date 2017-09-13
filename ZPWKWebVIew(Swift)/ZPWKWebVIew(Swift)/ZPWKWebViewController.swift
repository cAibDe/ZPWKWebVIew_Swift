//
//  ZPWKWebViewController.swift
//  ZPWKWebVIew(Swift)
//
//  Created by 张鹏 on 2017/9/12.
//  Copyright © 2017年 c4ibD3. All rights reserved.
//

import UIKit
import WebKit

class ZPWKWebViewController: UIViewController {
    //是否曾经成功加载过
    var isWebViewOnceFinishLoad:Bool! = false
    //是否是重新加载
    var isWebViewReloadOperation:Bool! = false
    
    var backDict = [String:AnyObject]()
    
    open var webView = ZPWebView()
    
    var url:String = ""
    
    var isUseWebTitle:Bool! = false

    var scrollEnable:Bool! = false
    
    var showHUDWhenLoading:Bool! = false
    
    var shouldShowProgress:Bool! = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        shouldShowProgress = true
        showHUDWhenLoading = true
        scrollEnable = true
        isUseWebTitle = true
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "加载中..."
        view.backgroundColor = UIColor.white
        setUpWebView()
        
        if isUseWebTitle {
            webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        }
        if shouldShowProgress {
            webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        }
        if url.characters.count > 0 {
            webView.loadNetWorkHtmlWithURL(urlStr: url)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        webView.frame = view.frame
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hiddenSGProgress()
    }
    deinit {
        print("deinit -------- \(ZPWKWebViewController.self)")
        if shouldShowProgress {
            webView.removeObserver(self, forKeyPath: "estimatedProgress")
        }
        if isUseWebTitle {
            webView.removeObserver(self, forKeyPath: "title")
        }
    }
    func shouldShowRefreshHeader() -> Bool {
        return true
    }
//    func isUseWebTitle() -> Bool {
//        return true
//    }
    func setUpWebView() {
        print(#function)
        let config = WKWebViewConfiguration()
        webView = ZPWebView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height), configuration: config)
        webView.scrollView.isScrollEnabled = scrollEnable
        webView.navigationDelegate = self
        webView.uiDelegate = self
        view.addSubview(webView)
        webView.didReceiveMessage = {  msg in

            print(msg)
        }

    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "estimatedProgress") {
            if ((object as! ZPWebView) == webView) {
                navigationController?.setSGProgressPercentage(Float(webView.estimatedProgress * 100), andTintColor: UIColor.red)
            }else{
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            }
        }else if keyPath == "title" {
            if (object as! ZPWebView) == webView {
                isUseWebTitle = true
                if isUseWebTitle {
                    title = webView.title
                }
            }else{
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            }
        }else{
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension ZPWKWebViewController:WKUIDelegate{
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        let sureAction = UIAlertAction(title: "确定", style: .default) { (action:UIAlertAction) in
            completionHandler()
        }
        alert.addAction(sureAction)
        present(alert, animated: true, completion: nil)
    }
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let sureAction = UIAlertAction(title: "确定", style: .default) { (action:UIAlertAction) in
            completionHandler(true)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .default) { (action:UIAlertAction) in
            completionHandler(false)
        }
        alert.addAction(sureAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}
extension ZPWKWebViewController:WKNavigationDelegate{
    //页面加载的时候调用
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if !isWebViewReloadOperation && showHUDWhenLoading {
            SVProgressHUD.show(withStatus: "加载中....")
        }
        print(#function + "\(String(describing: webView.url))")
    }
    //当内容开始返回的时候调用
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print(#function)
    }
    //页面加载完之后调用
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print(#function)
        isWebViewOnceFinishLoad = true
        isWebViewReloadOperation = false
        SVProgressHUD.dismiss()
    }
    //加载失败的时候调用
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(#function)
        navigationController?.hiddenSGProgress()
        SVProgressHUD.show(withStatus: "加载失败")
    }
    /**
     *  接收到服务器跳转请求之后调用
     *
     *  @param webView      实现该代理的webview
     *  @param navigation   当前navigation
     */
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print(#function)
    }
    /**
     *  在收到响应后，决定是否跳转
     *
     *  @param webView            实现该代理的webview
     *  @param navigationResponse 当前navigation
     *  @param decisionHandler    是否跳转block
     */
    private func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        print(#function)
        decisionHandler(WKNavigationResponsePolicy.allow)
        
    }
    /**
     *  在发送请求之前，决定是否跳转
     *
     *  @param webView          实现该代理的webview
     *  @param navigationAction 当前navigation
     *  @param decisionHandler  是否调转block
     */
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("URL:\(String(describing: navigationAction.request.url?.absoluteURL))")
        decisionHandler(WKNavigationActionPolicy.allow)
    }
}
