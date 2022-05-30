//
//  WebwarePayController.swift
//  Webware
//
//  Created by Vedika on 11/04/22.
//

import UIKit
import SwiftyJSON
class WebwarePayController: MyUIViewController {
    var back_from_strip = false
    var selected_url = ""
    
    @IBOutlet weak var signup_stripe: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Sign Up Stripe"
        // Do any additional setup after loading the view.
        signup_stripe.isEnabled = false
        signup_stripe?.backgroundColor = UIColor.gray
        signup_stripe.layer.cornerRadius = 5
        
    }
    override func viewDidAppear(_ animated: Bool) {
        self.navigationItem.hidesBackButton = true
        let logoutButton   = UIBarButtonItem(title: "Logout" ,  style: .plain, target: self, action: #selector(logoutTapped))
        navigationItem.rightBarButtonItems = [logoutButton]
        self.setNavigationDefaults()
        var stripe_account_exist = (UserDefaults.standard.bool(forKey: "stripe_account_exist"))
        signup_stripe.isEnabled = false
        signup_stripe?.backgroundColor = UIColor.gray
        signup_stripe.layer.cornerRadius = 5
        if(back_from_strip == true) {
            getAccountStatus()
        } else {
            if(stripe_account_exist == false) {
                self.setNavigationToWhite()
                getAccountStatus()
            } else {
                
            }
        }
    }
    @IBAction func sign_up_stripe(_ sender: Any) {
        self.performSegue(withIdentifier: "stripe_connect_new", sender: self)
    }
    @objc func logoutTapped() {
        Common.logout(v: self)
    }
    func getAccountStatus() {
        signup_stripe.isEnabled = false
        signup_stripe?.backgroundColor = UIColor.gray
        var baseurl = (UserDefaults.standard.string(forKey: "api_base_url"))!
        let postData = ["":""] as [String : Any]
        print("\(baseurl)/account")
        self.serverApiCall(route: ("\(baseurl)/account?source=app"), method: "GET", data: postData, responseHandler: handleAccountResponse, errorHandler: handleAccountError, showSpiner: true)
    }
    func handleAccountResponse(data: Data) {
        signup_stripe.isEnabled = true
        signup_stripe?.backgroundColor = UIColor.black
        do{
            let json = try JSON(data: data)
            print(json)
            if let stripe_link = json["errors"].string {
                var stripe_account_exist = (UserDefaults.standard.bool(forKey: "stripe_account_exist"))
                if(stripe_account_exist == true) {
                    //self.setNavigationDefaults()
                    UserDefaults.standard.set(true, forKey: "stripe_account_exist")
                } else {
                    self.setNavigationToWhite()
                    //self.setNavigationToWhite()
                    UserDefaults.standard.set(false, forKey: "stripe_account_exist")
                }
            } else {
                if let stripe_link = json["account"].string {
                    //self.setNavigationToWhite()
                    selected_url = stripe_link
                    //account_exist = false
                    self.navigationItem.title = "Sign Up Stripe"
                    UserDefaults.standard.set(false, forKey: "stripe_account_exist")
                } else if let account_status = json["account"].bool {
                    print("here in get account response")
                    //self.setNavigationDefaults()
                    if(account_status == true) {
                        UserDefaults.standard.set(1, forKey: "is_stripe_connected")
                        UserDefaults.standard.set(true, forKey: "stripe_account_exist")
                        if(back_from_strip == true) {
                            Common.showOkAlert(title: "Connected", content: "You have successfully connect your stripe account.")
                            let dc : UITabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tab_bar") as! MyTabBarController
                            self.present(dc, animated: true, completion: nil)
                        }
                    } else {
                        self.setNavigationToWhite()
                        //account_exist = false
                        UserDefaults.standard.set(false, forKey: "stripe_account_exist")
                    }
                }
            }
        }catch let decodingEror as DecodingError {
        }catch{
        }
    }
    @IBAction func not_now_btn(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
    }
    
    func handleAccountError(error: Error) {
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stripe_connect_new" {
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
            let destViewController = segue.destination as! StripeAccountController
            destViewController.urlToOpen = selected_url
        }
    }
}
