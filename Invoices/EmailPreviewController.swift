//
//  EmailPreviewController.swift
//  WebwarePay
//
//  Created by Vedika on 22/11/21.
//

import UIKit
import WebKit
class EmailPreviewController: MyUIViewController, WKNavigationDelegate {

    @IBOutlet weak var Activity: UIActivityIndicatorView!
    @IBOutlet weak var invoice_preview: WKWebView!
    @IBOutlet weak var preview_message: UILabel!
    var invoice_id = ""
    var invoice_response: InvoiceResponse!
    var invoice_url = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        sleep(1)
        invoice_preview.addSubview(self.Activity)
        self.Activity.startAnimating()
        invoice_preview.navigationDelegate = self
        
        let myURL = URL(string: invoice_url)
        let myRequest = URLRequest(url: myURL!)
        invoice_preview.load(myRequest)
        //let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(finalTapped))
        //self.navigationItem.leftBarButtonItem = backButton
        //self.tabBarController?.selectedIndex = 0
        self.title = "Email Preview"
        self.navigationItem.hidesBackButton = true
    }
    func webView(_ webView: WKWebView, didFinish  navigation: WKNavigation!)
    {
        self.Activity.isHidden = true
    }
    @objc func finalTapped(sender: AnyObject) {
        let postData = [
            "invoiceInformation": [
                 "invoiceId" : invoice_id,
                 "sendInvoice":"1"
             ]
         ] as [String : Any]
        var baseurl = (UserDefaults.standard.string(forKey: "api_base_url"))!
        self.serverApiCall(route: ("\(baseurl)/invoice"), method: "PUT" , data: postData, responseHandler: handleResponse, errorHandler: handleError)
    }
    func handleResponse(data: Data) {
        print("send inv response \(data.prettyPrintedJSONString)")
        do{
            self.invoice_response = try JSONDecoder().decode(InvoiceResponse.self, from: data)
            if(invoice_response.invoice != nil) {
                self.present(self.showOkAlertWithHandler(title: "Invoive Sent", content: "Your invoice is finalised and send to customer."), animated: true)
            } else {
                self.present(Common.showErrorAlert(title: Common.add_error_title, content: Common.add_error_text), animated: true)
            }
            
        }catch let decodingEror as DecodingError {
            self.present(Common.showErrorAlert(title: Common.add_error_title, content: Common.add_error_text), animated: true)
            //print("in decoding error \(decodingEror)")
        }catch{
        }
    }
    func handleError(error: Error) {
        print(error)
        self.present(Common.showErrorAlert(title: Common.add_error_title, content: Common.add_error_text), animated: true)
    }
    func showOkAlertWithHandler(title: String, content: String) -> UIAlertController{
        let alert = UIAlertController(title: title, message: content, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: { [self]  action in
            let storyboard: UIStoryboard = UIStoryboard(name: "Invoice", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "invoice_list_view") as! InvoiceViewController
            self.show(vc, sender: self)
        })
        OKAction.setValue(UIColor.black, forKey: "titleTextColor")
        alert.addAction(OKAction)
        return alert
    }
    
    @objc func backToInitial(sender: AnyObject) {
         //self.navigationController?.popToRootViewControllerAnimated(true)
        performSegue(withIdentifier: "back_to_send_segue", sender: self.self)
    }
    
    @objc func backTapped() {
        performSegue(withIdentifier: "back_to_send_segue", sender: self.self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "back_to_send_segue" {
            let landingcontroller = segue.destination as! SendInvoiceController
            landingcontroller.isPreview = true
        }
    }

}
