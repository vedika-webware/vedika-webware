//
//  LoginController.swift
//  WebwarePay
//
//  Created by Vedika on 08/02/22.
//

import UIKit
import Intercom

class LoginController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var btnTest: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var forgotBtn: UIButton!
    var versionResponse: VersionResponse!
    
    @IBAction func forgotPassword(_ sender: Any) {
        performSegue(withIdentifier: "forgot_password_segue", sender: self)
    }
    
    @IBAction func btnTestClick(_ sender: Any) {
        //print("test click")
    }
    @IBAction func signupBtn(_ sender: Any) {
        //print("signupclick")
        performSegue(withIdentifier: "back_to_signup", sender: self)
    }
    
    @IBAction func forgor_password(_ sender: Any) {
        performSegue(withIdentifier: "reset_password_segue", sender: self)
    }
    
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var userURL: UITextField!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var loginButton: UIButton!

    //let endpoint = "https://www.webware.io/api/appservice.cfc?_cf_nodebug=true&method=applogin&jsoncallback=monkey&domain="
    let endpoint = "appservice.cfc?_cf_nodebug=true&method=applogin&jsoncallback=monkey&domain="
    var endpointURL: URL?
    let myActivityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
    var user_id: Int?
    var errorFree: Bool?

    var enteredEmail: String = ""
    var enteredDomain: String = ""
    var offsetY:CGFloat = 0
    var keyboardHeight:CGFloat = 0
    var apiResponse: ApiResponse!
    var wb_response_data:Login_Status!
    @IBAction func actionLogin(_ sender: UIButton) {
        errorFree = true
        enteredEmail = userEmail.text!  //save for display in case of invalid format error
       
        errorMessage.isHidden = true
        if validateInput() {
            print("in valid input true!! \(errorFree)")
            if(errorFree!){
                print("in error free!! \(errorFree!)")
                authenticateUser()
            }
        }
    }

    @IBAction func tappedAction(_ sender: UITextField) {
        self.hideInputError(field: self.userEmail, message: userEmail.placeholder!)
        if(self.enteredEmail != ""){
            self.userEmail.text = self.enteredEmail
        }
    }
    
    @IBAction func domainTappedAction(_ sender: UITextField) {
        self.hideInputError(field: self.userURL, message: userURL.placeholder!)
    }
    
    @IBAction func passwordTappedAction(_ sender: UITextField) {
        self.hideInputError(field: self.userPassword, message: userPassword.placeholder!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        do{
            
        } catch {
            
        }
    }
    
    override func viewDidLoad() {
        do{
            
            super.viewDidLoad()
            userPassword.delegate = self
            userURL.delegate = self
            userEmail.delegate = self
            errorMessage.isHidden = true
            self.userURL.addBottomBorder()
            self.userEmail.addBottomBorder()
            self.userPassword.addBottomBorder()
            isUpdateAvailable()
        } catch {
            
        }
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
    override func viewDidAppear(_ animated: Bool) {
        //self.viewDidAppear(<#Bool#>)
        // Override point for customization after application launch.
        let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? nil
        //print("in appdelegate \(accessToken!)")
        if accessToken != nil{
            print("in if")
            performSegue(withIdentifier: "logged_in_segue", sender: Self.self)
            print("after root in if")
        } else {
            print("in else")
        }
    }
    /*
    @IBAction func crashButtonTapped(_ sender: AnyObject) {
       print("in crash")
       Crashlytics.crashlytics().log("This is custom crash")
   }
    */
    @objc func onclicksignup() {
        performSegue(withIdentifier: "back_to_signup", sender: self)
    }
    @objc func keyboardWillShow(notification: Notification) {
        if(self.keyboardHeight != 0){
            self.stackView.frame.origin.y -= 130//self.keyboardHeight
        }else{
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                self.keyboardHeight = keyboardSize.height
                self.stackView.frame.origin.y -= 130//keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            self.stackView.frame.origin.y += 130//keyboardSize.height
            self.loginButton.frame.origin.y += 130
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //override func textField
    func userAuthenticated(token: String,user_id: Int, userData: UserData, serverResponse : Login_Status){
        do{
            print("in user auth \(serverResponse.HASINVOICESENABLED)")
            UserDefaults.standard.set(token, forKey: "accessToken")
            UserDefaults.standard.set((self.userEmail.text!).trimmingCharacters(in: .whitespacesAndNewlines), forKey: "user_email")
            
            UserDefaults.standard.set(userData.site_id!, forKey: "site_id")
            UserDefaults.standard.set(userData.company?.name!, forKey: "site_name")
            UserDefaults.standard.set(userData.user_id!, forKey: "user_id")
            UserDefaults.standard.set(serverResponse.NAME, forKey: "name")
            UserDefaults.standard.set(serverResponse.GROUP, forKey: "group")
            UserDefaults.standard.set(userData.signup_date, forKey: "createdAt")
            UserDefaults.standard.set(serverResponse.FAMILYNAME, forKey: "familyName")
            UserDefaults.standard.set(serverResponse.ISSUBSCRIBED, forKey: "isSubscribed")
            UserDefaults.standard.set(serverResponse.GENDER, forKey: "gender")
            UserDefaults.standard.set(serverResponse.ORGANIZATIONID, forKey: "organizationId")
            UserDefaults.standard.set(serverResponse.PARENTORGANIZATIONID, forKey: "parentOrganizationId")
            UserDefaults.standard.set(serverResponse.HASINVOICESENABLED, forKey: "has_invoice_enabled")
            UserDefaults.standard.set(serverResponse.IS_STRIPE_CONNECTED, forKey: "is_stripe_connected")
            UserDefaults.standard.set(serverResponse.JSESSIONID, forKey: "jsession_id")
            var userurl = self.userURL.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            if(!(userurl.isEmpty)){
                userurl = userurl.replacingOccurrences(of: "https://", with: "", options: String.CompareOptions.regularExpression, range: nil)
                userurl = userurl.replacingOccurrences(of: "http://", with: "", options: String.CompareOptions.regularExpression, range: nil)
                userurl = userurl.replacingOccurrences(of: "/", with: "", options: String.CompareOptions.regularExpression, range: nil)
                userurl = userurl.replacingOccurrences(of: "www.", with: "", options: String.CompareOptions.regularExpression, range: nil)
            }
            UserDefaults.standard.set(userurl, forKey: "user_url")
            UserDefaults.standard.set("https://\(userurl)/admin", forKey: "api_base_url")
            var baseurl = (UserDefaults.standard.string(forKey: "api_base_url"))!
            print(baseurl)
            UserDefaults.standard.set(userData.currency!, forKey: "short_currency")
            if(userData.currency! == "INR") {
                UserDefaults.standard.set("₹", forKey: "currency")
            } else {
                UserDefaults.standard.set("$", forKey: "currency")
            }
            UserDefaults.standard.set(self.userURL.text, forKey: "domain")
            
            //save endpoint to dataware
            let endpointArnForSNS = UserDefaults.standard.string(forKey: "endpointArnForSNS") ?? nil
            //print("endpointArnForSNS \(endpointArnForSNS)")
            if(endpointArnForSNS != nil){
                self.saveARNToDataware(arn: endpointArnForSNS!)
            }
            
            let dc : UITabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tab_bar") as! MyTabBarController
            
            self.present(dc, animated: true, completion: nil)
            
        
        } catch {
            
        }
    }
    func validateInput() -> Bool{
        var valid: Bool = true
        var actualUrl = userURL.text
        if(!(actualUrl!.isEmpty)){
            actualUrl = actualUrl!.replacingOccurrences(of: "https://", with: "", options: String.CompareOptions.regularExpression, range: nil)
            actualUrl = actualUrl!.replacingOccurrences(of: "http://", with: "", options: String.CompareOptions.regularExpression, range: nil)
            actualUrl = actualUrl!.replacingOccurrences(of: "/", with: "", options: String.CompareOptions.regularExpression, range: nil)
            actualUrl = actualUrl!.replacingOccurrences(of: "www.", with: "", options: String.CompareOptions.regularExpression, range: nil)
            //actualUrl = actualUrl!.replacingOccurrences(of: "www.", with: "", options: String.CompareOptions.regularExpression, range: nil)
        }
        if (actualUrl?.isEmpty)! || (userEmail.text?.isEmpty)! || (userPassword.text?.isEmpty)!{
            errorFree = false
            if(actualUrl?.isEmpty)!{
                self.showInputError(field: self.userURL, message: "Required field URL")
            }
            if(userEmail.text?.isEmpty)!{
                self.showInputError(field: self.userEmail, message: "Required field E-mail")
            }
            if(userPassword.text?.isEmpty)!{
                self.showInputError(field: self.userPassword, message: "Required field Password")
            }
            valid = false
        }
        if !((userEmail.text?.isEmpty)!){
            if !isValidEmailFormat(email: userEmail.text!){
                errorFree = false
                self.showInputError(field: self.userEmail, message: "Invalid email format")
                valid = false
            }
        }
        if((actualUrl) != nil) {
            var validurl = verifyUrl(string: "https://\(actualUrl!)")
            if(!validurl) {
                errorFree = false
                self.showInputError(field: self.userURL, message: "Invalid URL")
                valid = false
            }
        }
        if(valid){
            self.endpointURL = URL(string:"\(endpoint)\((actualUrl)!.trimmingCharacters(in: .whitespacesAndNewlines))&email=\((userEmail.text!).trimmingCharacters(in: .whitespacesAndNewlines))&password=\((userPassword.text!).trimmingCharacters(in: .whitespacesAndNewlines))") ?? nil
            
            if(self.endpointURL == nil){
                self.displayMessage(userMessage: "Invalid URL")
                valid = false
            } else {
                valid = true
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
        field.attributedPlaceholder = NSAttributedString(string: message,
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        field.layer.borderWidth = 0
    }
    
    func authenticateUser(){
        print(self.endpointURL?.absoluteString ?? "")
        var userurl = self.userURL.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        userurl = userurl.replacingOccurrences(of: "https://", with: "", options: String.CompareOptions.regularExpression, range: nil)
        userurl = userurl.replacingOccurrences(of: "http://", with: "", options: String.CompareOptions.regularExpression, range: nil)
        userurl = userurl.replacingOccurrences(of: "/", with: "", options: String.CompareOptions.regularExpression, range: nil)
        userurl = userurl.replacingOccurrences(of: "www.", with: "", options: String.CompareOptions.regularExpression, range: nil)
        self.externalApiCall(route: "https://\(userurl)/api/\(self.endpointURL!.absoluteString)" ?? "", method: "GET", data: "", responseHandler: handleLogin, errorHandler: errorLogin)
    }
    func handleLogin(data: Data) {
        do{
            //print(data.prettyPrintedJSONString)
        DispatchQueue.main.async {
            let errorMsg = "Could not successfully perform this request. Please try again later"
            if let returnData = String(data: data, encoding: .utf8) {
                let range = returnData.index(returnData.startIndex, offsetBy: 7)..<returnData.index(returnData.endIndex, offsetBy: -1)
                let realData = String(returnData[range])
                
                print("data is \(returnData)")
                let xdata = Data(realData.utf8)
                let jsonDecoder = JSONDecoder()
                let status = try? jsonDecoder.decode(Login_Status.self, from: xdata)
                print(status?.NAME)
                print(status?.TOKEN)
                if(status?.STATUS == 200 && self.errorFree!){
                    self.wb_response_data = status!
                    Intercom.registerUser(withUserId: String(status!.ID))
                    let userAttributes = ICMUserAttributes()
                    userAttributes.name = status!.DATA.name
                    userAttributes.email = status!.DATA.email
                    Intercom.updateUser(userAttributes)
                    self.userAuthenticated(token: (status?.TOKEN)!,user_id: (status?.ID)!,userData: status!.DATA, serverResponse: status!)
                    SnowplowManager.shared?.track_login(email: self.enteredEmail, domain: self.userURL.text!, status: 1, message: status!.MESSAGE)
                } else {
                    self.errorFree = false
                    DispatchQueue.main.async { [unowned self] in
                        if(status != nil){
                            self.displayMessage(userMessage: (status?.MESSAGE)!)
                            SnowplowManager.shared?.track_login(email: self.enteredEmail, domain: self.userURL.text!, status: 0, message: status!.MESSAGE)
                        }else{
                            //self.displayMessage(userMessage: "An unexpected error has occurred!")
                            self.displayMessage(userMessage: "Unauthorized!")
                            SnowplowManager.shared?.track_login(email: self.enteredEmail, domain: self.userURL.text!, status: 0, message: "Unauthorized!")
                        }
                    }
                    return
                }
            } else {
                SnowplowManager.shared?.track_login(email: self.enteredEmail, domain: self.userURL.text!, status: 0, message: "Unauthorized!")
                self.errorFree = false
                //DispatchQueue.main.async { [unowned self] in
                    self.displayMessage(userMessage: errorMsg)
                //}
                //return
            }
        }
        } catch {
            
        }
    }
    func errorLogin(error: Error) {
        self.errorFree = false
        DispatchQueue.main.async { [unowned self] in
            self.displayMessage(userMessage: "Network Error")
        }
        //return
    }
    /*Display alert message to the user*/
    func displayMessage(userMessage:String) -> Void {
        //let borderColor = UIColor.red
        //errorMessage.layer.borderColor = borderColor.cgColor
        //errorMessage.layer.borderWidth = 1.0
        //errorMessage.layer.cornerRadius = 5
        errorMessage.text = userMessage
        errorMessage.center.x = self.view.center.x
        errorMessage.frame.origin.y = stackView.frame.origin.y - 80
        errorMessage.isHidden = false
        //errorMessage.layer.masksToBounds = true
        errorMessage.sizeToFit();
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
    
    /*
    Start and Stop activity indicator functions
    */
    func startActivityIndicator(){
        myActivityIndicator.center = view.center // Position Activity Indicator in the center
        myActivityIndicator.hidesWhenStopped = false
        myActivityIndicator.startAnimating()// Start Activity Indicator
        view.addSubview(myActivityIndicator)
    }
    
    func removeActivityIndicator(){
        DispatchQueue.main.async
        {
            self.myActivityIndicator.stopAnimating()
            self.myActivityIndicator.removeFromSuperview()
        }
    }
    
    func saveARNToDataware(arn: String) {
        let postData = "email=\(self.enteredEmail)&app_type=1&notification_arn=\(arn)&version=\(Common.appversion)"
        print(postData)
        self.serverDatawareApiCall(route: "todo/create_customer", method: "POST", data: postData, responseHandler: handleArn, errorHandler: errorArn)
    }
    func handleArn(data: Data) {
        do{
            print("arn response \(data.prettyPrintedJSONString)")
        }catch let decodingEror as DecodingError {
            
        }catch{
            
        }
    }
    func errorArn(error: Error) {
           
    }
}
