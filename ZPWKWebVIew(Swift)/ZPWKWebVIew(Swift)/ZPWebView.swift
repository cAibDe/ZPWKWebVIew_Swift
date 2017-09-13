//
//  ZPWebView.swift
//  ZPWKWebVIew(Swift)
//
//  Created by 张鹏 on 2017/9/12.
//  Copyright © 2017年 c4ibD3. All rights reserved.
//

import UIKit
import WebKit

class ZPWebView: WKWebView {

    var webViewRequestUrl = String()
    //可变字典
    var webViewRequestParams = [String:String]()
    
    var baseUrl = URL.init(string: "")

    var didReceiveMessage:((_ message:Any) -> Void)?
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        configuration.userContentController.add(self as WKScriptMessageHandler, name: "webViewApp")
//        baseUrl = URL.init(string: "")!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func loadNetWorkHtmlWithURL(urlStr: String) {
        loadNetWorkTHMLWithURL(url: urlStr, params:nil)
    }
    func loadNetWorkTHMLWithURL(url:String ,params:Dictionary<String,String>?) {
        if (params == nil) {
            load(URLRequest(url: URL.init(string: url)!))
        }else{
            let urlStr:URL = generateURL(url: url, params: params)
            load(URLRequest(url: urlStr))
        }
    }
    func generateURL(url:String, params:Dictionary<String, String>?) -> URL {
        webViewRequestUrl = url
        webViewRequestParams = params!
        var param = params!
        var pairs : [String] = []
        for key in param.keys {
            let value = "\(String(describing: param[key]))"
            let charactersToEscape = "!*'\"();:@&=+$,/?%#[]% "
            let allowedCharacters = CharacterSet.init(charactersIn: charactersToEscape).inverted
            let escaped_value = value.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
            pairs.append("\(key) = \(String(describing: escaped_value))")
        }
        let query = pairs.joined(separator: "&")
        let newurl = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        var address:String = ""
        if (newurl?.contains("?"))!{
            address = "\(String(describing: newurl))&\(query)"
        }else{
            address = "\(String(describing: newurl))?\(query)"
        }
        //绝对地址
        if (newurl?.lowercased().hasPrefix("http"))! {
            return URL.init(string: address)!
        }else{
            return URL.init(string: address, relativeTo: baseUrl)!
        }
    }
    func loadLocalHTMLWithFileName(name:String) {
        let path = Bundle.main.bundlePath
        let baseURL = URL.init(fileURLWithPath: path)
        
        let htmlPath = Bundle.main.path(forResource: name, ofType: "html")
        let htmlCOnt = try? String(contentsOfFile: htmlPath!, encoding: String.Encoding.utf8)
        loadHTMLString(htmlCOnt!, baseURL: baseURL)
    }
    func reloadWebView()  {
        loadNetWorkTHMLWithURL(url: webViewRequestUrl, params: webViewRequestParams)
    }
    func callJS(jsMethod:String) {
        callJS(jsMethod: jsMethod, handler: nil)
    }
    func callJS(jsMethod:String, handler:((_ response:Any) -> Void)?) {
        print("call JS:\(jsMethod)")
        evaluateJavaScript(jsMethod) { (response, error) in
            if  let blockCode = handler {
                if response != nil {
                   blockCode(response as Any)
                }
            }
        }
    }
}
extension ZPWebView:WKScriptMessageHandler{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("message -----------------\(message.body)")
        
        if message.body is [String : AnyObject] {
            let body = message.body
            let msg = ZPWebView()
            msg.setValuesForKeys(body as! [String : Any])
            
            if let recriveBlock = didReceiveMessage {
                recriveBlock(msg)
            }
        }

    }
}
