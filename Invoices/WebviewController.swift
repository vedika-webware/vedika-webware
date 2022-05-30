//
//  WebviewController.swift
//  WebwarePay
//
//  Created by Vedika on 16/12/21.
//

import UIKit
import WebKit
class WebviewController: MyUIViewController, WKNavigationDelegate {

    @IBOutlet weak var Activity: UIActivityIndicatorView!
    @IBOutlet weak var webview: WKWebView!
    var urlToOpen = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Invoice"
        webview.addSubview(self.Activity)
        self.Activity.startAnimating()
        webview.navigationDelegate = self
        let myURL = URL(string: urlToOpen)
        let myRequest = URLRequest(url: myURL!)
        webview.load(myRequest)
    }
    
    func webView(_ webView: WKWebView, didFinish  navigation: WKNavigation!)
    {
        self.Activity.isHidden = true
    }
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        self.Activity.isHidden = false
    }
}
