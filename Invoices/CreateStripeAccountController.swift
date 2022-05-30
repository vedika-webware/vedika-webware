//
//  CreateStripeAccountController.swift
//  WebwarePay
//
//  Created by Vedika on 12/01/22.
//

import UIKit
import WebKit

class CreateStripeAccountController: MyUIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var Activity: UIActivityIndicatorView!
    @IBOutlet weak var webview: WKWebView!
    var urlToOpen = ""
    var strip_completed = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Sign Up Stripe"
        //let cancelButton   = UIBarButtonItem(title: "Cancel" ,  style: .plain, target: self, action: #selector(cancelTapped))
        //navigationItem.rightBarButtonItems = [cancelButton]
        navigationItem.rightBarButtonItem = .none
        navigationItem.leftBarButtonItem = .none
        webview.addSubview(self.Activity)
        self.Activity.startAnimating()
        webview.navigationDelegate = self
        let myURL = URL(string: urlToOpen)
        let myRequest = URLRequest(url: myURL!)
        webview.load(myRequest)
    }
    @objc func cancelTapped(_ sender: AnyObject) {
        strip_completed = false
        webview.stopLoading()
        //performSegue(withIdentifier: "back_to_invoice_list", sender: self)
        performSegue(withIdentifier: "back_to_webwarepay", sender: self)
    }
    func webView(_ webView: WKWebView, didFinish  navigation: WKNavigation!)
    {
        print("in finish")
        self.Activity.isHidden = true
        print("loaded url \(self.webview.url?.absoluteString)")
        //if(self.webview.url?.absoluteString == "https://stripe.com/in/privacy") {
        var domain = (UserDefaults.standard.string(forKey: "domain"))!
        print("contains \(self.webview.url?.absoluteString.contains(domain))")
        //if ((self.webview.url?.absoluteString.contains(domain)) == true) {
        if ((self.webview.url?.absoluteString.contains("webware_app_success=1")) == true) {
            strip_completed = true
            //performSegue(withIdentifier: "back_to_invoice_list", sender: self)
            performSegue(withIdentifier: "back_to_webwarepay", sender: self)
            
            UserDefaults.standard.set(1, forKey: "is_stripe_connected")
            
        } else if((self.webview.url?.absoluteString.contains("webware_app_success=0")) == true) {
            strip_completed = false
            //performSegue(withIdentifier: "back_to_invoice_list", sender: self)
            performSegue(withIdentifier: "back_to_webwarepay", sender: self)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "back_to_invoice_list" {
            let destViewController = segue.destination as! InvoiceViewController
            print(strip_completed)
            destViewController.back_from_strip = strip_completed
        }
        if segue.identifier == "back_to_webwarepay" {
            let destViewController = segue.destination as! InvoiceViewController
            print(strip_completed)
            destViewController.back_from_strip = strip_completed
        }
    }
}
