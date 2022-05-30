//
//  Common.swift
//  WebwareTest2
//
//  Created by Rakesh Kamat on 13/06/19.
//  Copyright © 2019 Webware.io. All rights reserved.
//

import UIKit
import WebKit

class Common: NSObject {
    static let required_placeholder = "Required"
    static let appversion = 4
    static let minor_version = 4.0
    static let up_max_file_size = 10.0
    static let max_file_size_string = "10"
    static let log_env = "Development-"
    static let appOrangeColor = UIColor.init(red: 239, green: 96, blue: 51, alpha: 1)
    static let fontsmall = UIFont.systemFont(ofSize: 10.0)
    static let fontmedium = UIFont(name: "Roboto-Regular", size: 15.0)
    static let fontbold = UIFont.boldSystemFont(ofSize: 16.0)
    static let separatorColor = UIColor(red: 0.78, green: 0.78, blue: 0.78, alpha: 1.00)
    static let separatorTickeness = CGFloat(1.0)
    static let separatorInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 15)
    static let separatorInsetItem = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 15)
    static let separatorInsetMore = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 15)
    static let dateFormatSelected = "MMM d, y"
    static let discoverUrl = "https://www.webware.io/pages/discover";
    static let navigation_back_color = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00) //UIColor(red: 0.96, green: 0.95, blue: 0.95, alpha: 1.0)
    static let navigation_back_color_15 = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 0.6)
    static let navigation_white_color  = UIColor.white
    static let alert_tint_color = UIColor.black
    static let table_content_inset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    static let table_cell_inset = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15)
    static let add_inv_cell_inset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    static let add_inv_note_cell_inset = UIEdgeInsets(top: 5, left: 15, bottom: 15, right: 15)
    static let white_spacing = 32
    //static let snowPlowEndPoint = "io-webware-prod1.mini.snplow.net"
    //static let snowPlowSchemaUrl = "iglu:io-webware-prod1.mini.snplow.net/global_context/jsonschema/1-0-0"
    static let snowPlowEndPoint = "io-webware-prod1.collector.snplow.net"
    static let snowPlowSchemaUrl = "iglu:io-io-webware-prod1.collector.snplow.net/global_context/jsonschema/1-0-0"
    /* Webware AWS account SNS parameters */
    static let SNSPlatformApplicationArn = "arn:aws:sns:ap-southeast-1:212301307178:app/APNS/WebwareConciergeLive"
    //static let SNSPlatformApplicationArn = "arn:aws:sns:ap-southeast-1:212301307178:app/APNS_SANDBOX/WebwareConcierge"
    static let identityPoolId = "ap-southeast-1:94a333b5-9fc5-427e-8ebb-bef0146dcd58"
   
    /* Test AWS account SNS parameters */
    /*static let SNSPlatformApplicationArn = "arn:aws:sns:ap-southeast-1:793594271137:app/APNS_SANDBOX/webds_dev"
    static let identityPoolId = "ap-southeast-1:72ec1647-0b76-4f06-b702-6a3957ec7205"*/
    static let placeholderColor:UIColor = UIColor(red: 193, green: 190, blue: 187, alpha: 1)
    static let product_name_maxlength  = 30
    static let product_desc_maxlength  = 80
    
    
    static func startActivityIndicator(indicator: UIActivityIndicatorView, view: UIView){
        indicator.center = view.center // Position Activity Indicator in the center
        indicator.hidesWhenStopped = false
        indicator.startAnimating()// Start Activity Indicator
        view.addSubview(indicator)
    }
   
    static func removeActivityIndicator(indicator: UIActivityIndicatorView){
        DispatchQueue.main.async{
            indicator.stopAnimating()
            indicator.removeFromSuperview()
        }
    }
    
    enum ApiError: Error {
        case invalidOperation
    }
    
    static func setupPlaceholder(view: UITextView,placeholder: String ){
        view.text = placeholder
        view.font = UIFont(name: "Roboto-Regular", size: 17.0)
        //view.textColor = UIColor.init(rgb: 0x4D4A49)
        view.textColor = placeholderColor
        view.returnKeyType = .done
    }
    
    static func showOkAlert(title: String, content: String) -> UIAlertController{
        let alert = UIAlertController(title: title, message: content, preferredStyle: .alert)
        //alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        OKAction.setValue(UIColor.black, forKey: "titleTextColor")
        alert.addAction(OKAction)
        return alert
    }
    
    static func showErrorAlert(title: String, content: String) -> UIAlertController{
        let alert = UIAlertController(title: title, message: content, preferredStyle: .alert)
        //alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        OKAction.setValue(UIColor.black, forKey: "titleTextColor")
        alert.addAction(OKAction)
        return alert
    }
    
    static func showRequiredErrorAlert(title: String, content: String) -> UIAlertController{
        let alert = UIAlertController(title: title, message: content, preferredStyle: .alert)
        //alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        OKAction.setValue(UIColor.black, forKey: "titleTextColor")
        alert.addAction(OKAction)
        return alert
    }
    
    static func logout(v: UIViewController){
        //Intercom.logout()
        UserDefaults.standard.removeObject(forKey: "accessToken")
        UserDefaults.standard.removeObject(forKey: "unread_message")
        UserDefaults.standard.removeObject(forKey: "user_url")
        UserDefaults.standard.removeObject(forKey: "user_email")
        //UserDefaults.standard.removeObject(forKey: "demo_view_skip")
        UserDefaults.standard.removeObject(forKey: "site_id")
        UserDefaults.standard.removeObject(forKey: "user_id")
        UserDefaults.standard.removeObject(forKey: "has_invoice_enabled")
        UserDefaults.standard.removeObject(forKey: "jsession_id")
        self.clearSavedValues()
        self.clearAppSettings()
        //UserDefaults.standard.removeObject(forKey: "endpointArnForSNS")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "login") as! LoginController
        v.present(vc, animated: true, completion: nil)
            
        
        
        /*
        UserDefaults.standard.removeObject(forKey: "accessToken")
        UserDefaults.standard.removeObject(forKey: "unread_message")
        UserDefaults.standard.removeObject(forKey: "user_url")
        UserDefaults.standard.removeObject(forKey: "user_email")
        //UserDefaults.standard.removeObject(forKey: "demo_view_skip")
        UserDefaults.standard.removeObject(forKey: "site_id")
        UserDefaults.standard.removeObject(forKey: "user_id")
        //UserDefaults.standard.removeObject(forKey: "endpointArnForSNS")
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //let vc = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        //v.present(vc, animated: true, completion: nil)
        */
    }
    static func cropFileName(fileName: String,restrictLength: Int) -> String {
        if(fileName.count > restrictLength){
            var newName = fileName.prefix(restrictLength)
            newName.append(contentsOf: "...")
            return String(newName)
        }
        return fileName
    }
    static func makeWebView(x:CGFloat,y:CGFloat,width:CGFloat,height:CGFloat)->WKWebView{
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.preferences = preferences
        let frame = CGRect(x: x,y: y,width: width,height: height)
        return WKWebView(frame: frame, configuration: webConfiguration)
    }
    static func isValidEmailFormat(email: String) -> Bool{
        var valid = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = email as NSString
            let results = regex.matches(in: nsString as String, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0{
                valid = false
            }
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            valid = false
        }
        return valid
    }
    static func disableBtn(allbtnView: [UIButton]) {
        for btnView in allbtnView {
            btnView.isUserInteractionEnabled = false
            btnView.setTitleColor(.gray, for: .normal)
        }
    }
    static func enableBtn(allbtnView: [UIButton]) {
        for btnView in allbtnView {
            btnView.isUserInteractionEnabled = true
            btnView.setTitleColor(UIColor.init(red: 241, green: 95, blue: 38, alpha: 1), for: .normal)
        }
    }
    
    static func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    static func isAllDigits(str: String)->Bool {
        if let mInt = Int(str) {
            return true
        }else {
            return false
        }
    }
    
    static func isFloat(str: String)->Bool {
        if let mFloat = Float(str) {
            return true
        }else {
            return false
        }
    }
    static func roundTwoDecimal(val : Double) -> Double {
        var return_val = Double(round(100 * val) / 100)
        return return_val
    }
    static func clearSavedValues() {
        var save_draft_values = UserDefaults.standard.bool(forKey: "save_draft_values") ?? false
        if(save_draft_values == true) {
            saveDraftValues()
        }
        UserDefaults.standard.removeObject(forKey: "selected_item")
        UserDefaults.standard.removeObject(forKey: "updated_qty_array")
        UserDefaults.standard.removeObject(forKey: "selected_customer")
        UserDefaults.standard.removeObject(forKey: "selected_customer_name")
        UserDefaults.standard.removeObject(forKey: "selected_customer_fname")
        UserDefaults.standard.removeObject(forKey: "selected_customer_id")
        UserDefaults.standard.removeObject(forKey: "total_amount")
        UserDefaults.standard.removeObject(forKey: "due_date")
        UserDefaults.standard.removeObject(forKey: "description")
        UserDefaults.standard.removeObject(forKey: "poso_number")
        UserDefaults.standard.removeObject(forKey: "note")
        UserDefaults.standard.removeObject(forKey: "invoice_id")
        UserDefaults.standard.removeObject(forKey: "selected_tax_percent")
        UserDefaults.standard.removeObject(forKey: "selected_tax_id")
        UserDefaults.standard.removeObject(forKey: "selected_tax_name")
        UserDefaults.standard.removeObject(forKey: "isUpdateChecked")
        
    }
    static func saveDraftValues() {
        //let selected_item = UserDefaults.standard.array(forKey: "selected_item") ?? ""
        if(UserDefaults.standard.array(forKey: "selected_item") != nil) {
            UserDefaults.standard.set(UserDefaults.standard.array(forKey: "selected_item"), forKey: "draft_selected_item")
        }
        let selected_customer = UserDefaults.standard.string(forKey: "selected_customer") ?? ""
        if(selected_customer != "" && selected_customer != nil) {
            UserDefaults.standard.set(selected_customer, forKey: "draft_selected_customer")
        }
        let selected_customer_name = UserDefaults.standard.string(forKey: "selected_customer_name") ?? ""
        if(selected_customer_name != "" && selected_customer_name != nil) {
            UserDefaults.standard.set(selected_customer_name, forKey: "draft_selected_customer_name")
        }
        let selected_customer_fname = UserDefaults.standard.string(forKey: "selected_customer_fname") ?? ""
        if(selected_customer_fname != "" && selected_customer_fname != nil) {
            UserDefaults.standard.set(selected_customer_fname, forKey: "draft_selected_customer_fname")
        }
        let selected_customer_id = UserDefaults.standard.string(forKey: "selected_customer_id") ?? ""
        if(selected_customer_id != "" && selected_customer_id != nil) {
            UserDefaults.standard.set(selected_customer_id, forKey: "draft_selected_customer_id")
        }
        let total_amount = UserDefaults.standard.string(forKey: "total_amount") ?? ""
        if(total_amount != "" && total_amount != nil) {
            UserDefaults.standard.set(total_amount, forKey: "draft_total_amount")
        }
        let due_date = UserDefaults.standard.string(forKey: "due_date") ?? ""
        if(due_date != "" && due_date != nil) {
            UserDefaults.standard.set(due_date, forKey: "draft_due_date")
        }
        let description = UserDefaults.standard.string(forKey: "description") ?? ""
        if(description != "" && description != nil) {
            UserDefaults.standard.set(description, forKey: "draft_description")
        }
        let poso_number = UserDefaults.standard.string(forKey: "poso_number") ?? ""
        if(poso_number != "" && poso_number != nil) {
            UserDefaults.standard.set(poso_number, forKey: "draft_poso_number")
        }
        let note = UserDefaults.standard.string(forKey: "note") ?? ""
        if(note != "" && note != nil) {
            UserDefaults.standard.set(note, forKey: "draft_note")
        }
        let selected_tax_percent = UserDefaults.standard.string(forKey: "selected_tax_percent") ?? ""
        if(selected_tax_percent != "" && selected_tax_percent != nil) {
            UserDefaults.standard.set(selected_tax_percent, forKey: "draft_selected_tax_percent")
        }
        let selected_tax_id = UserDefaults.standard.string(forKey: "selected_tax_id") ?? ""
        if(selected_tax_id != "" && selected_tax_id != nil) {
            UserDefaults.standard.set(selected_tax_id, forKey: "draft_selected_tax_id")
        }
        let selected_tax_name = UserDefaults.standard.string(forKey: "selected_tax_name") ?? ""
        if(selected_tax_name != "" && selected_tax_name != nil) {
            UserDefaults.standard.set(selected_tax_name, forKey: "draft_selected_tax_name")
        }
    }
    static func clearDraftValues() {
        UserDefaults.standard.removeObject(forKey: "draft_selected_item")
        UserDefaults.standard.removeObject(forKey: "draft_selected_customer")
        UserDefaults.standard.removeObject(forKey: "draft_selected_customer_name")
        UserDefaults.standard.removeObject(forKey: "draft_selected_customer_fname")
        UserDefaults.standard.removeObject(forKey: "draft_selected_customer_id")
        UserDefaults.standard.removeObject(forKey: "draft_total_amount")
        UserDefaults.standard.removeObject(forKey: "draft_description")
        UserDefaults.standard.removeObject(forKey: "draft_poso_number")
        UserDefaults.standard.removeObject(forKey: "draft_due_date")
        UserDefaults.standard.removeObject(forKey: "draft_note")
        UserDefaults.standard.removeObject(forKey: "draft_selected_tax_percent")
        UserDefaults.standard.removeObject(forKey: "draft_selected_tax_id")
        UserDefaults.standard.removeObject(forKey: "draft_selected_tax_name")
    }
    static func checkIfDraftSaved()->Bool {
        var is_draft_value_exist = false
        let selected_customer = UserDefaults.standard.string(forKey: "draft_selected_customer") ?? ""
        let selected_customer_name = UserDefaults.standard.string(forKey: "draft_selected_customer_name") ?? ""
        let selected_customer_fname = UserDefaults.standard.string(forKey: "draft_selected_customer_fname") ?? ""
        let selected_customer_id = UserDefaults.standard.string(forKey: "draft_selected_customer_id") ?? ""
        let total_amount = UserDefaults.standard.string(forKey: "draft_total_amount") ?? ""
        let due_date = UserDefaults.standard.string(forKey: "draft_due_date") ?? ""
        let description = UserDefaults.standard.string(forKey: "draft_description") ?? ""
        let poso_number = UserDefaults.standard.string(forKey: "draft_poso_number") ?? ""
        let note = UserDefaults.standard.string(forKey: "draft_note") ?? ""
        let selected_tax_percent = UserDefaults.standard.string(forKey: "draft_selected_tax_percent") ?? ""
        let selected_tax_id = UserDefaults.standard.string(forKey: "draft_selected_tax_id") ?? ""
        let selected_tax_name = UserDefaults.standard.string(forKey: "draft_selected_tax_name") ?? ""
        
        if(UserDefaults.standard.array(forKey: "draft_selected_item") != nil) {
            is_draft_value_exist = true
        } else if(selected_customer != "" && selected_customer != nil) {
            is_draft_value_exist = true
        } else if(selected_customer_name != "" && selected_customer_name != nil) {
            is_draft_value_exist = true
        } else if(selected_customer_fname != "" && selected_customer_fname != nil) {
            is_draft_value_exist = true
        } else if(selected_customer_id != "" && selected_customer_id != nil) {
            is_draft_value_exist = true
        } else if(total_amount != "" && total_amount != nil) {
            is_draft_value_exist = true
        } else if(due_date != "" && due_date != nil) {
            is_draft_value_exist = true
        } else if(description != "" && description != nil) {
            is_draft_value_exist = true
        } else if(poso_number != "" && poso_number != nil) {
            is_draft_value_exist = true
        } else if(note != "" && note != nil) {
            is_draft_value_exist = true
        } else if(selected_tax_percent != "" && selected_tax_percent != nil) {
            is_draft_value_exist = true
        } else if(selected_tax_id != "" && selected_tax_id != nil) {
            is_draft_value_exist = true
        } else if(selected_tax_name != "" && selected_tax_name != nil) {
            is_draft_value_exist = true
        }
        return is_draft_value_exist
    }
    static func loadDraftValues() {
        if(UserDefaults.standard.array(forKey: "draft_selected_item") != nil) {
            UserDefaults.standard.set(UserDefaults.standard.array(forKey: "draft_selected_item"), forKey: "selected_item")
        }
        let selected_customer = UserDefaults.standard.string(forKey: "draft_selected_customer") ?? ""
        if(selected_customer != "" && selected_customer != nil) {
            UserDefaults.standard.set(UserDefaults.standard.string(forKey: "draft_selected_customer"), forKey: "selected_customer")
        }
        let selected_customer_name = UserDefaults.standard.string(forKey: "draft_selected_customer_name") ?? ""
        if(selected_customer_name != "" && selected_customer_name != nil) {
            UserDefaults.standard.set(UserDefaults.standard.string(forKey: "draft_selected_customer_name"), forKey: "selected_customer_name")
        }
        let selected_customer_fname = UserDefaults.standard.string(forKey: "draft_selected_customer_fname") ?? ""
        if(selected_customer_fname != "" && selected_customer_fname != nil) {
            UserDefaults.standard.set(UserDefaults.standard.string(forKey: "draft_selected_customer_fname"), forKey: "selected_customer_fname")
        }
        let selected_customer_id = UserDefaults.standard.string(forKey: "draft_selected_customer_id") ?? ""
        if(selected_customer_id != "" && selected_customer_id != nil) {
            UserDefaults.standard.set(selected_customer_id, forKey: "selected_customer_id")
        }
        let total_amount = UserDefaults.standard.string(forKey: "draft_total_amount") ?? ""
        if(total_amount != "" && total_amount != nil) {
            UserDefaults.standard.set(total_amount, forKey: "total_amount")
        }
        let due_date = UserDefaults.standard.string(forKey: "draft_due_date") ?? ""
        if(due_date != "" && due_date != nil) {
            UserDefaults.standard.set(due_date, forKey: "due_date")
        }
        let description = UserDefaults.standard.string(forKey: "draft_description") ?? ""
        if(description != "" && description != nil) {
            UserDefaults.standard.set(description, forKey: "description")
        }
        let poso_number = UserDefaults.standard.string(forKey: "draft_poso_number") ?? ""
        if(poso_number != "" && poso_number != nil) {
            UserDefaults.standard.set(poso_number, forKey: "poso_number")
        }
        let note = UserDefaults.standard.string(forKey: "draft_note") ?? ""
        if(note != "" && note != nil) {
            UserDefaults.standard.set(note, forKey: "note")
        }
        let selected_tax_percent = UserDefaults.standard.string(forKey: "draft_selected_tax_percent") ?? ""
        if(selected_tax_percent != "" && selected_tax_percent != nil) {
            UserDefaults.standard.set(selected_tax_percent, forKey: "selected_tax_percent")
        }
        let selected_tax_id = UserDefaults.standard.string(forKey: "draft_selected_tax_id") ?? ""
        if(selected_tax_id != "" && selected_tax_id != nil) {
            UserDefaults.standard.set(selected_tax_id, forKey: "selected_tax_id")
        }
        let selected_tax_name = UserDefaults.standard.string(forKey: "draft_selected_tax_name") ?? ""
        if(selected_tax_name != "" && selected_tax_name != nil) {
            UserDefaults.standard.set(selected_tax_name, forKey: "selected_tax_name")
        }
    }
    static func clearAppSettings() {
        UserDefaults.standard.removeObject(forKey: "stripe_account_exist")
    }
    static func clearSelectedValues() {
        UserDefaults.standard.removeObject(forKey: "selected_item")
        /*
        UserDefaults.standard.removeObject(forKey: "selected_customer_name")
        UserDefaults.standard.removeObject(forKey: "selected_customer")
        UserDefaults.standard.removeObject(forKey: "user_email")
        UserDefaults.standard.removeObject(forKey: "name")
        UserDefaults.standard.removeObject(forKey: "poso_number")
        UserDefaults.standard.removeObject(forKey: "note")
        */
    }
    
    static let invalid_request_Title:String = "Invalid Request";
    static let invalid_request_Text:String = "Requested operation could not be completed. Please try again later";
    static let network_error_Title:String = "Connection Error";
    static let network_error_Text:String = "Something went wrong. Please check your network connectivity.";
    
    static let server_error_Title:String = "Server Error";
    static let server_error_Text:String = "Something went wrong on server. Please try after some time.";
    
    static let file_error_title:String = "Upload Interrupted";
    static let file_error_text:String = "Your request could not be processed completely. If you were uploading files, all files may not have uploaded.";
    
    static let file_error_title_size:String = "Invalid file size";
    static let file_error_text_size:String = "File: selectedfile is exceeding the file size limit of 10 MB.";
    static let add_error_title:String = "Error Adding Resource";
    static let add_error_text:String = "Requested resource could not be added. Please try again.";
    
    static let required_error_title:String = "Missing Required Fields";
    static let required_error_text:String = "Please fill required fields and try again.";
    
    static let duedate_error_title:String = "Due date invalid";
    static let duedate_error_text:String = "Please fill valid due date in future.";
    
    static let quantity_error_title:String = "Quantity invalid";
    static let quantity_error_text:String = "Please fill valid quantity for all invoice products.";
    
    static let email_error_title:String = "Invalid email";
    static let email_error_text:String = "Email format is invalid.";
}

