//
//  SendInvoiceController.swift
//  WebwarePay
//
//  Created by Vedika on 18/11/21.
//

import UIKit

class SendInvoiceController: MyUIViewController {
    
    
    @IBOutlet weak var view_sample_email: UIView!
    var isPreview = Bool()
    @IBOutlet weak var customer_name: UILabel!
    
    @IBOutlet weak var email_subject: UILabel!
    
    var customer_name_var = ""
    var customer_email_var = ""
    var invoice_response: InvoiceResponse!
    @IBOutlet weak var email_body: UILabel!
    @IBOutlet weak var from_email: UILabel!
    
    var invoice_id = ""
    var invoice_url = ""
    var total = ""
    var note = ""
    var sender_email_add = ""
    var sender_name = ""
    var poso_number = ""
    var from_add_invoice = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationToWhite()
        
        self.showToast(message: "Invoice saved as draft.", font: UIFont.boldSystemFont(ofSize: 15))
        //print("on load \(invoice_id)")
        //print("in send \(UserDefaults.standard.string(forKey: "total_amount"))")
        //print(UserDefaults.standard.string(forKey: "selected_customer_name"))
        let tap = UITapGestureRecognizer(target: self, action: #selector(sendTapped));
        view_sample_email.addGestureRecognizer(tap)
        //if(isPreview == false) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Finalize", style: .plain, target: self, action: #selector(sendTapped))
        //} else {
            //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(sendTapped))
        //}
        self.tabBarController?.selectedIndex = 0
        self.title = "Send Invoice"
        if(UserDefaults.standard.string(forKey: "selected_customer_name") != nil && UserDefaults.standard.string(forKey: "selected_customer_name") != "") {
            customer_name_var = (UserDefaults.standard.string(forKey: "selected_customer_name")!)
        }
        if(UserDefaults.standard.string(forKey: "selected_customer_name") != nil && UserDefaults.standard.string(forKey: "selected_customer_name") != "") {
            customer_name_var = (UserDefaults.standard.string(forKey: "selected_customer_name")!)
        }
        if(UserDefaults.standard.string(forKey: "selected_customer_fname") != nil && UserDefaults.standard.string(forKey: "selected_customer_fname") != "") {
            customer_name_var = (UserDefaults.standard.string(forKey: "selected_customer_fname")!)
        }
        
        if(UserDefaults.standard.string(forKey: "selected_customer") != nil && UserDefaults.standard.string(forKey: "selected_customer") != "") {
            customer_email_var = (UserDefaults.standard.string(forKey: "selected_customer")!)
        }
        if(UserDefaults.standard.string(forKey: "user_email") != nil && UserDefaults.standard.string(forKey: "user_email") != "") {
            sender_email_add = (UserDefaults.standard.string(forKey: "user_email") ?? "")
        }
        if(UserDefaults.standard.string(forKey: "name") != nil && UserDefaults.standard.string(forKey: "name") != "") {
            sender_name = (UserDefaults.standard.string(forKey: "name") ?? "")
        }
        if(UserDefaults.standard.string(forKey: "poso_number") != nil && UserDefaults.standard.string(forKey: "poso_number") != "") {
            poso_number = (UserDefaults.standard.string(forKey: "poso_number") ?? "")
        }
        self.from_email.text = sender_email_add
        self.customer_name.text = customer_email_var
        self.email_subject.text = "My Invoice \(poso_number) from \(sender_name)"
        print("total \(total)")
        if(UserDefaults.standard.string(forKey: "note") != nil || UserDefaults.standard.string(forKey: "note") != "") {
            var note_defaults = UserDefaults.standard.string(forKey: "note") ?? ""
            if(note_defaults != "") {
                note = "\(note_defaults)"
            }
        }
        
        self.email_body.text = """
            Hi \(customer_name_var),
            
            Here's my invoice \(poso_number) for the total amount of \(total)
            
            Thank You for your business,
            \(sender_name)
            """
    }
    override func viewDidAppear(_ animated: Bool) {
        //if(from_add_invoice == true) {
            /*let buttonIcon = UIImage(named: "back_with_arrow")
            let leftBarButton = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.done, target: self, action: #selector(SendInvoiceController.back(sender:)))
            leftBarButton.imageInsets = UIEdgeInsets.init(top: 0, left: -10, bottom: 0, right: 0)
            leftBarButton.image = buttonIcon
            self.navigationItem.leftBarButtonItem = leftBarButton
        */
        
            let button = UIButton(type: .system)
            button.setImage(UIImage(named: "back_arrow"), for: .normal)
            button.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -10, bottom: 0, right: 0)
            button.setTitle("Cancel", for: .normal)
            button.sizeToFit()
            button.addTarget(self, action: #selector(SendInvoiceController.back(sender:)), for: .touchUpInside)
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        
        //} else {
            //self.navigationItem.hidesBackButton = true
        //}
    }
    @objc func back(sender: UIBarButtonItem) {
        //performSegue(withIdentifier: "back_add_invoice_segue", sender: self)
        Common.clearSelectedValues()
        performSegue(withIdentifier: "back_to_edit_segue", sender: self)
        
    }
    @objc func sendTapped() {
        //print(isPreview)
        //if(isPreview == false) {
            let postData = [
                "invoiceInformation": [
                     "invoiceId" : invoice_id,
                     "finalizeInvoice":"1"
                 ]
             ] as [String : Any]
            print("in send tapped \(postData)")
            let baseurl = (UserDefaults.standard.string(forKey: "api_base_url"))!
            self.serverApiCall(route: ("\(baseurl)/invoice"), method: "PUT" , data: postData, responseHandler: handleResponseFinalise, errorHandler: handleErrorFinalise)
            
        /*} else {
            var customer_id = ""
            var note = ""
            var poso_number = ""
            var description = ""
            var duedate = ""
            print("on send \(invoice_id)")
            if(UserDefaults.standard.string(forKey: "selected_customer_id") != nil) {
                customer_id = UserDefaults.standard.string(forKey: "selected_customer_id")!
            }
            if(UserDefaults.standard.string(forKey: "note") != nil) {
                var note_defaults = UserDefaults.standard.string(forKey: "note") ?? ""
                if(note_defaults != "") {
                    note = "Note: \(note_defaults)"
                }
            }
            if(UserDefaults.standard.string(forKey: "poso_number") != nil) {
                poso_number = UserDefaults.standard.string(forKey: "poso_number")!
            }
            if(UserDefaults.standard.string(forKey: "description") != nil) {
                description = UserDefaults.standard.string(forKey: "description")!
            }
            if(UserDefaults.standard.string(forKey: "invoice_id") != nil) {
                invoice_id = UserDefaults.standard.string(forKey: "invoice_id")!
            }
            if(UserDefaults.standard.string(forKey: "due_date") != nil) {
                let duedate_saved = UserDefaults.standard.string(forKey: "due_date") ?? ""
                // current date and time
                var dfmatter = DateFormatter()
                dfmatter.dateFormat="d MMM y"
                var date = dfmatter.date(from: duedate_saved)
                var dateStamp:TimeInterval = date!.timeIntervalSince1970
                var dateSt:Int = Int(dateStamp)
                duedate = String(dateSt)
            }
            let postData = [
                "invoiceInformation": [
                     "invoiceId" : invoice_id,
                     "sendInvoice":"1"
                     //"finalizeInvoice":"1"
                 ]
             ] as [String : Any]
            print(postData)
            var baseurl = (UserDefaults.standard.string(forKey: "api_base_url"))!
            self.serverApiCall(route: ("\(baseurl)/invoice"), method: "PUT" , data: postData, responseHandler: handleResponse, errorHandler: handleError)
        }*/
    }
    func handleResponseFinalise(data: Data) {
        do{
            //print("finalise inv response \(data.prettyPrintedJSONString)")
            self.invoice_response = try JSONDecoder().decode(InvoiceResponse.self, from: data)
            if(invoice_response.invoice != nil) {
                invoice_url = invoice_response.invoice
                //performSegue(withIdentifier: "email_preview_segue", sender: self)
                Common.clearSavedValues()
                performSegue(withIdentifier: "preview_invoice_segue", sender: self)
                
            } else {
                self.present(Common.showErrorAlert(title: "Error", content: "Error Finalising invoice"), animated: true)
            }
        }catch let decodingEror as DecodingError {
            self.present(Common.showErrorAlert(title: "Error", content: "Error Finalising invoice"), animated: true)
            //print("in decoding error \(decodingEror)")
        }catch{
        }
    }
    func handleErrorFinalise(error: Error) {
        self.present(Common.showErrorAlert(title: "Error", content: "Error Finalising invoice"), animated: true)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "email_preview_segue") {
            let vc = segue.destination as! EmailPreviewController
            vc.invoice_id = invoice_id
            vc.invoice_url = invoice_url
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
        }
        if(segue.identifier == "preview_invoice_segue") {
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
            let vc = segue.destination as! PreViewController
            vc.from_add_edit = true
            vc.invoice_id = invoice_id
        }
        if segue.identifier == "back_to_edit_segue" {
            let destViewController = segue.destination as! EditInvoiceController
            destViewController.invoice_id = invoice_id
            destViewController.is_from_preview = true
            //let backItem = UIBarButtonItem()
            //backItem.title = "Back"
            //navigationItem.backBarButtonItem = backItem
        }
    }
    
}
