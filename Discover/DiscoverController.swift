//
//  DiscoverController.swift
//  WebwareTest2
//
//  Created by Rakesh Kamat on 15/08/19.
//  Copyright © 2019 Webware.io. All rights reserved.
//

import UIKit
import WebKit
class DiscoverController: MyUIViewController,WKUIDelegate,UIWebViewDelegate,WKNavigationDelegate, UITabBarControllerDelegate {

    let myActivityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
    var webView: WKWebView!
    var webwareURL: String!
    var show_logout = true
    @IBAction func logoutAction(_ sender: Any) {
        Common.logout(v: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationDefaults()
        self.tabBarController?.delegate = self
        let logo = UIImage(named: "login-logo")
        let imageView = UIImageView(image:logo)
        //self.navigationItem.titleView = imageView
        if(show_logout == true) {
            let logoutButton   = UIBarButtonItem(title: "Logout" ,  style: .plain, target: self, action: #selector(logoutTapped))
            navigationItem.rightBarButtonItems = [logoutButton]
            self.navigationController?.navigationBar.tintColor = UIColor(red: 0.95, green: 0.37, blue: 0.15, alpha: 1.00)
        }
        initDiscoverHome()
        //SnowplowManager.shared?.trackCustomScreenViewEvent(screenName:currentViewController() ?? "", previousScreenName: backViewController() ?? "")
    }
    @objc func logoutTapped() {
        Common.logout(v: self)
    }
    
    func initDiscoverHome(){
        webView = Common.makeWebView(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        self.view.addSubview(webView)
        let myURL = URL(string: Common.discoverUrl)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        SnowplowManager.shared!.track_pageview(title: "Discover Link", webpageurl: myURL!.absoluteString)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        Common.startActivityIndicator(indicator: myActivityIndicator, view: webView)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Common.removeActivityIndicator(indicator: self.myActivityIndicator)
    }
}
