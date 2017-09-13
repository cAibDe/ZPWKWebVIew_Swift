//
//  ZPScriptMessage.swift
//  ZPWKWebVIew(Swift)
//
//  Created by 张鹏 on 2017/9/12.
//  Copyright © 2017年 c4ibD3. All rights reserved.
//

import UIKit

class ZPScriptMessage: NSObject {
    var method = String()
    var params = [String:AnyObject]()
    var callback = String()
    
    override var description: String {
        return "<\(NSStringFromClass(ZPScriptMessage.self)):{method:\(method),params:\(params),callback:\(callback)}>"
    }
}
