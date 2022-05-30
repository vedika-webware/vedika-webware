//
//  PasswordResetController.swift
//  WebwarePay
//
//  Created by Vedika on 22/03/22.
//

import UIKit

class PasswordResetController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var labelError: UILabel!
    @IBOutlet weak var domain: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var resetButton: UIButton!
    var versionResponse: VersionResponse!
    var errorFree: Bool?
    @IBAction func backAction(_ sender: Any) {
        performSegue(withIdentifier: "login_back_segue", sender: self)
    }
    
    var inputError = ""
    //let endpoint = "https://www.webware.io/api/appservice.cfc?_cf_nodebug=true&method=forgotPassword&jsoncallback=monkey&domain="
    let endpoint = "appservice.cfc?_cf_nodebug=true&method=forgotPassword&jsoncallback=monkey&domain="
    var endpointURL: URL?
    //let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    @IBAction func resetAction(_ sender: Any) {
        if(self.validateFields() && self.validateInput()){
            self.resetPassword()
        }else{
            //self.present(Common.showOkAlert(title: "Error", content: self.inputError), animated: true)
        }
    }
    @IBAction func domainTapped(_ sender: Any) {
        hideInputError(field: domain, message: domain.placeholder!)
    }
    
    @IBAction func emailTapped(_ sender: Any) {
        hideInputError(field: email, message: email.placeholder!)
    }
    @IBAction func login_click(_ sender: Any) {
        performSegue(withIdentifier: "login_back_segue", sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        domain.delegate = self
        email.delegate = self
        labelError.isHidden = true
        resetButton.layer.cornerRadius = 8
        isUpdateAvailable()
        //let yourAttributes: [NSAttributedString.Key: Any] = [
            //.font: UIFont.systemFont(ofSize: 17.0) as Any,
            //.foregroundColor: UIColor(red: 0.94, green: 0.38, blue: 0.20, alpha: 1.00),
            //.underlineStyle: NSUnderlineStyle.single.rawValue]
        
        //let attributeString = NSMutableAttributedString(string: "here",
                                                        //attributes: yourAttributes)
        //loginBtn.setAttributedTitle(attributeString, for: .normal)
        //Common.makeRoundedBtn(allbtnView: [resetButton])
    }
    func isUpdateAvailable() {
        self.serverDatawareApiCall(route: "todo/version/\(Common.minor_version)", method: "GET", data: "", responseHandler: handleUpdate, errorHandler: errorUpdate)
    }
    func handleUpdate(data: Data) {
        DispatchQueue.global().async {
            do {
                print("upgrade response \(data.prettyPrintedJSONString)")
                self.versionResponse = try JSONDecoder().decode(VersionResponse.self, from: data)
                var update = false
                if(self.versionResponse.response.new_version_available == true) {
                    update = true
                }
                DispatchQueue.main.async {
                    if update{
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let chatVC = storyboard.instantiateViewController(withIdentifier: "upgrade_controller") as! UIViewController
                        self.present(chatVC, animated: true)
                    } else {
                        
                    }
                }
            } catch {
                print(error)
            }
        }
    }
    func errorUpdate(error: Error) {
           
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        self.domain.addBottomBorder()
        self.email.addBottomBorder()
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func validateFields() -> Bool{
        var valid = true
        var actualUrl = domain.text
        if(!(actualUrl!.isEmpty)){
            actualUrl = actualUrl!.replacingOccurrences(of: "https://", with: "", options: String.CompareOptions.regularExpression, range: nil)
            actualUrl = actualUrl!.replacingOccurrences(of: "http://", with: "", options: String.CompareOptions.regularExpression, range: nil)
            actualUrl = actualUrl!.replacingOccurrences(of: "/", with: "", options: String.CompareOptions.regularExpression, range: nil)
            actualUrl = actualUrl!.replacingOccurrences(of: "www.", with: "", options: String.CompareOptions.regularExpression, range: nil)
            //actualUrl = actualUrl!.replacingOccurrences(of: "www.", with: "", options: String.CompareOptions.regularExpression, range: nil)
        }
        //if (domain.text?.isEmpty)! || (email.text?.isEmpty)!{
        if(domain.text?.isEmpty)!{
            inputError = "Required field URL"
            showInputError(field: domain, message: inputError)
            valid = false
        }
        if((actualUrl) != nil) {
            var validurl = verifyUrl(string: "https://\(actualUrl!)")
            if(!validurl) {
                errorFree = false
                self.showInputError(field: domain, message: "Invalid URL")
                valid = false
            }
        }
        if(email.text?.isEmpty)!{
            inputError = "Required field E-mail"
            showInputError(field: email, message: inputError)
            valid = false
        }
        if !((email.text?.isEmpty)!){
            if !Common.isValidEmailFormat(email: email.text!){
                inputError = "Invalid email format"
                showInputError(field: email, message: inputError)
                valid = false
            }
        }
        
        return valid
    }
    func verifyUrl (string: String?) -> Bool {
        guard let urlString = string,
            let url = URL(string: urlString)
            else { return false }

        if !UIApplication.shared.canOpenURL(url) { return false }

        let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
        return predicate.evaluate(with: string)
    }
    func resetPassword(){
        self.endpointURL = URL(string:"\(endpoint)\((domain.text!).trimmingCharacters(in: .whitespacesAndNewlines))&email=\((email.text!).trimmingCharacters(in: .whitespacesAndNewlines))")
        var domain = (domain.text!).trimmingCharacters(in: .whitespacesAndNewlines)
        
        domain = domain.replacingOccurrences(of: "https://", with: "", options: String.CompareOptions.regularExpression, range: nil)
        domain = domain.replacingOccurrences(of: "http://", with: "", options: String.CompareOptions.regularExpression, range: nil)
        domain = domain.replacingOccurrences(of: "/", with: "", options: String.CompareOptions.regularExpression, range: nil)
        domain = domain.replacingOccurrences(of: "www.", with: "", options: String.CompareOptions.regularExpression, range: nil)
        
        
        let email = (email.text!).trimmingCharacters(in: .whitespacesAndNewlines)
        self.endpointURL = URL(string:"\(endpoint)\(domain)&email=\(email)")
        let reset_api = "https://\(domain)/api/\(endpoint)\(domain)&email=\(email)"
        //print(reset_api)
        self.externalApiCall(route: reset_api, method: "GET", data: "", responseHandler: handleResetPassword, errorHandler: errorResetPassword)
        /*
        let errorMsg = "Could not successfully perform this request. Please try again later"
        Common.startActivityIndicator(indicator: self.myActivityIndicator,view: self.view)
        self.endpointURL = URL(string:"\(endpoint)\((domain.text!).trimmingCharacters(in: .whitespacesAndNewlines))&email=\((email.text!).trimmingCharacters(in: .whitespacesAndNewlines))")
        print("endpoint is \(self.endpointURL)")
        let request = URLRequest(url:self.endpointURL!)
        print("request url is \(request.url!)")
        let task = URLSession.shared.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) in
            Common.removeActivityIndicator(indicator: self.myActivityIndicator)
            if error != nil {
                DispatchQueue.main.async { [unowned self] in
                    self.present(Common.showOkAlert(title: "Error", content: errorMsg), animated: true)
                }
                print(error!)
            } else {
                if let returnData = String(data: data!, encoding: .utf8) {
                    let range = returnData.index(returnData.startIndex, offsetBy: 7)..<returnData.index(returnData.endIndex, offsetBy: -1)
                    var realData = String(returnData[range])
                    struct Status: Codable {
                        var MESSAGE: String
                        var STATUS: Int
                    }
                    
                    let xdata = Data(realData.utf8)
                    //print("data is \(returnData)")
                    let jsonDecoder = JSONDecoder()
                    let status = try? jsonDecoder.decode(Status.self, from: xdata)
                    print("status is \(status)")
                    if(status?.STATUS == 200){
                        DispatchQueue.main.async {
                            self.showAlertAndGoBack(title: "Success", message: status!.MESSAGE)
                            //self.present(Common.showOkAlert(title: "Success", content: (status?.MESSAGE)!), animated: true)
                        }
                    }else{
                        DispatchQueue.main.async { [unowned self] in
                            if(status != nil){
                                self.present(Common.showOkAlert(title: "Error", content: (status?.MESSAGE)!), animated: true)
                            }else{
                                self.present(Common.showOkAlert(title: "Error", content: "An unexpected1 error has occurred!"), animated: true)
                            }
                        }
                        return
                    }
                } else {
                    DispatchQueue.main.async { [unowned self] in
                        self.present(Common.showOkAlert(title: "Error", content: errorMsg), animated: true)
                    }
                    return
                }
            }
        }
        task.resume()
        */
    }
    func handleResetPassword(data: Data) {
        let errorMsg = "Could not successfully perform this request. Please try again later"
        if let returnData = String(data: data, encoding: .utf8) {
            let range = returnData.index(returnData.startIndex, offsetBy: 7)..<returnData.index(returnData.endIndex, offsetBy: -1)
            let realData = String(returnData[range])
            
            
            let xdata = Data(realData.utf8)
            let jsonDecoder = JSONDecoder()
            let status = try? jsonDecoder.decode(Status.self, from: xdata)
            if(status?.STATUS == 200){
                DispatchQueue.main.async {
                    self.showAlertAndGoBack(title: "Success", message: status!.MESSAGE)
                    //self.present(Common.showOkAlert(title: "Success", content: (status?.MESSAGE)!), animated: true)
                }
            }else{
                DispatchQueue.main.async { [unowned self] in
                    if(status != nil){
                        //self.present(Common.showOkAlert(title: "Error", content: (status?.MESSAGE)!), animated: true)
                        self.labelError.isHidden = false
                        self.labelError.text = status?.MESSAGE
                    }else{
                        self.present(Common.showOkAlert(title: Common.invalid_request_Title, content: Common.invalid_request_Text), animated: true)
                    }
                }
                return
            }
        } else {
            DispatchQueue.main.async { [unowned self] in
                //self.present(Common.showOkAlert(title: "Error", content: errorMsg), animated: true)
                self.labelError.text = errorMsg
            }
            return
        }
    }
    func errorResetPassword(error: Error) {
        let errorMsg = "Could not successfully perform this request. Please try again later"
        self.labelError.isHidden = false
        self.labelError.text = errorMsg
    }
    func showAlertAndGoBack(title: String,message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = Common.alert_tint_color
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            //self.performSegue(withIdentifier: "back_from_reset", sender: self)
            self.performSegue(withIdentifier: "login_back_segue", sender: self)
            
        }
        alert.addAction(OKAction)
        self.present(alert,animated: true)
    }
    func addDoneToolBarToKeyboard(textView:UITextView)
    {
        textView.returnKeyType = .default
        let doneToolbar : UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        let flexibelSpaceItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let hideKeyboardItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.dismissKeyboard))
        doneToolbar.items = [flexibelSpaceItem, hideKeyboardItem]
        doneToolbar.sizeToFit()
        textView.inputAccessoryView = doneToolbar
    }
    
    @objc func dismissKeyboard()
    {
        self.view.endEditing(true)
    }
    func showInputError(field: UITextField, message: String){
        field.text = ""
        field.backgroundColor = UIColor.white.withAlphaComponent(1.0)
        field.attributedPlaceholder = NSAttributedString(string: message,
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        field.layer.borderWidth = 0
        let borderColor = UIColor.red
        field.layer.borderColor = borderColor.cgColor
        field.layer.cornerRadius = 5
    }
    
    func hideInputError(field: UITextField, message: String){
        field.backgroundColor = UIColor.white
        //field.placeholder = message
        field.attributedPlaceholder = NSAttributedString(string: message,
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        field.layer.borderWidth = 0
        
    }

    func validateInput() -> Bool{
        var valid: Bool = true
        var actualUrl = domain.text
        if(!(actualUrl!.isEmpty)){
            actualUrl = actualUrl!.replacingOccurrences(of: "https://", with: "", options: String.CompareOptions.regularExpression, range: nil)
            actualUrl = actualUrl!.replacingOccurrences(of: "http://", with: "", options: String.CompareOptions.regularExpression, range: nil)
            actualUrl = actualUrl!.replacingOccurrences(of: "/", with: "", options: String.CompareOptions.regularExpression, range: nil)
            actualUrl = actualUrl!.replacingOccurrences(of: "www.", with: "", options: String.CompareOptions.regularExpression, range: nil)
            //actualUrl = actualUrl!.replacingOccurrences(of: "www.", with: "", options: String.CompareOptions.regularExpression, range: nil)
        }
        if (actualUrl?.isEmpty)! || (email.text?.isEmpty)!{
            errorFree = false
            
            if(email.text?.isEmpty)!{
                self.showInputError(field: self.email, message: "Required field E-mail")
            }
            valid = false
        }
        if !((email.text?.isEmpty)!){
            if !isValidEmailFormat(email: email.text!){
                errorFree = false
                self.showInputError(field: self.email, message: "Invalid email format")
                valid = false
            }
        }
        
        if(valid){
            self.endpointURL = URL(string:"\(endpoint)\(actualUrl!)&email=\(email.text!)")
            print(self.endpointURL)
            if(self.endpointURL == nil){
                //self.displayMessage(userMessage: "Invalid URL")
                self.labelError.isHidden = false
                self.labelError.text = "Invalid URL"
                valid = false
            } else {
                self.labelError.isHidden = true
                valid = true
            }
        }
        return valid
    }
    func isValidEmailFormat(email: String) -> Bool{
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
            //print("invalid regex: \(error.localizedDescription)")
            valid = false
        }
        return valid
    }
}
