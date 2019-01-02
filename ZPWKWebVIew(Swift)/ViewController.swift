//
//  ViewController.swift
//  ZPWKWebVIew(Swift)
//
//  Created by 张鹏 on 2017/9/12.
//  Copyright © 2017年 c4ibD3. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let pushBtn = UIButton(type: .custom)
        pushBtn.frame = CGRect(x: 100, y: 100, width: 100, height: 30)
        
        pushBtn.setTitle("WebView", for: .normal)
        pushBtn.setTitleColor(UIColor.red, for: .normal)
        pushBtn.addTarget(self, action: #selector(btnAction(button:)), for: .touchUpInside)
        view.addSubview(pushBtn)
        
    }
     @objc func btnAction(button:UIButton) {
        let zpVC = ZPWKWebViewController()
        zpVC.url = "http://blog.csdn.net/callmeanlin008/article/details/53170661"
        navigationController?.pushViewController(zpVC, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

