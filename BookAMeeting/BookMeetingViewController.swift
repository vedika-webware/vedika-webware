//
//  BookMeetingViewController.swift
//  WebwarePay
//
//  Created by Vedika on 04/03/22.
//

import UIKit
import WebKit

class BookMeetingViewController: MyUIViewController, WKUIDelegate, WKNavigationDelegate,UIWebViewDelegate {
    var webView: WKWebView!
    var meeting: Meeting!
    var show_logout = true
    let myActivityIndicator = UIActivityIndicatorView(style: .gray)
    @objc func logoutTapped() {
        Common.logout(v: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationDefaults()
        let logo = UIImage(named: "login-logo")
        let imageView = UIImageView(image:logo)
        //self.navigationItem.titleView = imageView
        if(show_logout == true) {
            let logoutButton   = UIBarButtonItem(title: "Logout" ,  style: .plain, target: self, action: #selector(logoutTapped))
            navigationItem.rightBarButtonItems = [logoutButton]
        }
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.preferences = preferences
        let frame = CGRect(x: 0, y: 10,width: self.view.bounds.width, height: (self.view.bounds.height-40))
        webView = WKWebView(frame: frame, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.backgroundColor = UIColor.black
        self.view.addSubview(webView)
        let myURL = URL(string: meeting.book_a_meeting_link)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        //SnowplowManager.shared?.trackCustomScreenViewEvent(screenName:currentViewController() ?? "", previousScreenName: backViewController() ?? "")
        SnowplowManager.shared!.track_pageview(title: "Book A Meeting Link", webpageurl: myURL!.absoluteString)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "back_to_meetings_details" {
            let vc = segue.destination as! MeetingDetailsController
            vc.meeting = self.meeting
            vc.show_logout = show_logout
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        Common.startActivityIndicator(indicator: myActivityIndicator, view: webView)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Common.removeActivityIndicator(indicator: self.myActivityIndicator)
    }

}
