//
//  AddCustomerViewController.swift
//  WebwarePay
//
//  Created by Vedika on 03/11/21.
//

import UIKit

class AddCustomerViewController: MyTableViewController {
    var first_name = ""
    var last_name = ""
    var last_name_to_check = ""
    var customer_name = ""
    var customer_biz_txt = ""
    var email = ""
    var country = ""
    var state = ""
    var city = ""
    var line1 = ""
    var line2 = ""
    var postal_code = ""
    var customer_business_name = ""
    var customer_response: CustomerResponse!
    var customer_response_web: CustomerResponseWeb!
    var from_add_invoice = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(saveTapped))
        //self.tabBarController?.selectedIndex = 1
        self.title = "New Customer"
        self.setNavigationToWhite()
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        tableView.separatorColor = Common.separatorColor
        tableView.tableFooterView = UIView()
    }
    @objc func saveTapped() {
        
        //if let customer_biz_txt_lbl = self.view.viewWithTag(12) as? UITextField {
            //customer_biz_txt = "\(customer_biz_txt_lbl.text!)"
        //}
        if let customer_fname_txt = self.view.viewWithTag(3) as? UITextField {
            first_name = "\(customer_fname_txt.text!)"
            customer_name = first_name
        }
        if let customer_lname_txt = self.view.viewWithTag(4) as? UITextField {
            last_name = " \(customer_lname_txt.text!)"
            last_name_to_check = "\(customer_lname_txt.text!)"
            customer_name = ("\(customer_name) \(last_name)")
        }
        if let customer_email_txt = self.view.viewWithTag(1) as? UITextField {
            email = customer_email_txt.text!
        }
        if let customer_line1_txt = self.view.viewWithTag(6) as? UITextField {
            line1 = customer_line1_txt.text!
        }
        if let customer_line2_txt = self.view.viewWithTag(7) as? UITextField {
            line2 = customer_line2_txt.text!
        }
        if let customer_city_txt = self.view.viewWithTag(8) as? UITextField {
            city = customer_city_txt.text!
        }
        if let customer_country_txt = self.view.viewWithTag(9) as? UITextField {
            country = customer_country_txt.text!
        }
        if let customer_state_txt = self.view.viewWithTag(10) as? UITextField {
            state = customer_state_txt.text!
        }
        if let customer_postalcode_txt = self.view.viewWithTag(11) as? UITextField {
            postal_code = customer_postalcode_txt.text!
        }
        print(first_name)
        print(last_name)
        
        if(first_name != "" && last_name_to_check != "" && email != "") {
            var valid_email = Common.isValidEmail(email: email)
            if(valid_email == true) {
                var baseurl = (UserDefaults.standard.string(forKey: "api_base_url"))!
                //save customer on web
                navigationItem.rightBarButtonItem?.isEnabled = false
                let postDataToWeb = [
                    "userInformation":[
                        "firstname" : first_name,
                        "lastname" : last_name_to_check,
                        "email" : email,
                        "id":0,
                        "isflashcall":0,
                        "groupType": 6,
                        "isRegistrationConfirmed": 1,
                        "SiteID": UserDefaults.standard.string(forKey: "site_id")!,
                        "billingline1":line1,
                        "billingline2":line2,
                        "billingcity":city,
                        "billingregion":state,
                        "billingCountry":country,
                        "billingpostalCode":postal_code,
                        "section_id":0,
                        "page_id":0
                    ]
                 ] as [String : Any]
                //print(postDataToWeb)
                //SnowplowManager.shared?.track_customer_actions(id: "test id", action: "add", phone: "", email: email, name: first_name, firstName: first_name, lastName: last_name, line1: line1, line2: line2, city: city, state: state, country: country, postCode: postal_code)
                self.serverApiCall(route: ("\(baseurl)/customer"), method: "POST" , data: postDataToWeb, responseHandler: handleResponseWeb, errorHandler: handleErrorWeb)
            } else {
                self.present(Common.showRequiredErrorAlert(title: Common.email_error_title, content: Common.email_error_text), animated: true)
            }
        } else {
            self.present(Common.showRequiredErrorAlert(title: Common.required_error_title, content: Common.required_error_text), animated: true)
        }
        
    }
    func handleResponseWeb(data: Data) {
        do{
            
            //self.sections = try JSONDecoder().decode([section].self, from: data)
            self.customer_response_web = try JSONDecoder().decode(CustomerResponseWeb.self, from: data)
            if(customer_response_web.customer != nil) {
                navigationItem.rightBarButtonItem?.isEnabled = true
                UserDefaults.standard.set(email, forKey: "selected_customer")
                UserDefaults.standard.set(customer_response_web.customer, forKey: "selected_customer_id")
                UserDefaults.standard.set(customer_name , forKey: "selected_customer_name")
                self.present(self.showOkAlertWithHandler(title: "Customer Added", content: "Customer Added Successfully"), animated: true)
                SnowplowManager.shared?.track_customer_actions(id: customer_response_web.customer, action: "add", phone: "", email: email, name: first_name, firstName: first_name, lastName: last_name, line1: line1, line2: line2, city: city, state: state, country: country, postCode: postal_code)
            } else {
                navigationItem.rightBarButtonItem?.isEnabled = true
                self.present(Common.showErrorAlert(title: "\(Common.add_error_title)", content: Common.add_error_text), animated: true)
            }
            
        }catch let decodingEror as DecodingError {
            navigationItem.rightBarButtonItem?.isEnabled = true
            self.present(Common.showErrorAlert(title: "\(Common.add_error_title)", content: Common.add_error_text), animated: true)
        }catch{
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    func handleErrorWeb(error: Error) {
        print(error)
        navigationItem.rightBarButtonItem?.isEnabled = true
        self.present(Common.showErrorAlert(title: "\(Common.add_error_title)", content: Common.add_error_text), animated: true)
    }
    func showOkAlertWithHandler(title: String, content: String) -> UIAlertController{
        let alert = UIAlertController(title: title, message: content, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: { [self]  action in
            if(from_add_invoice == false) {
                let storyboard: UIStoryboard = UIStoryboard(name: "Customer", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "customer_view") as! CustomerController
                self.show(vc, sender: self)
            } else {
                let storyboard: UIStoryboard = UIStoryboard(name: "Invoice", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "add_invoice_screen") as! AddInvoiceController
                vc.customer_added = true
                var customer_name_set = ""
                if let customer_fname_txt = self.view.viewWithTag(3) as? UITextField {
                    first_name = "\(customer_fname_txt.text!)"
                    customer_name_set = first_name
                }
                if let customer_lname_txt = self.view.viewWithTag(4) as? UITextField {
                    last_name = " \(customer_lname_txt.text!)"
                    customer_name_set = ("\(customer_name_set) \(last_name)")
                }
                print(customer_name_set)
                UserDefaults.standard.set(customer_name_set, forKey: "selected_customer_name")
                if let customer_email_txt = self.view.viewWithTag(1) as? UITextField {
                    var customer_email = customer_email_txt.text!
                    UserDefaults.standard.set(customer_email, forKey: "selected_customer")
                }
                self.show(vc, sender: self)
            }
        })
        OKAction.setValue(UIColor.black, forKey: "titleTextColor")
        alert.addAction(OKAction)
        return alert
    }
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 12
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "empty_cell", for: indexPath) as! CustomerEmptyCell
            cell.sub_title.text = ""
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0);
            return cell
        } /*else if(indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customer_info", for: indexPath) as! CustomerInfoCell
            cell.field_label.addTextWithImage(text: "  Customer",image: UIImage(named: "customer_icon")!,imageBehindText: false,keepPreviousText: false)
            cell.field_value.tag = 12
            //cell.field_value.placeholder = "Required"
            cell.field_value.isHidden = true
            return cell
        } */else if(indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customer_info", for: indexPath) as! CustomerInfoCell
            //cell.field_label.text = "Email"
            cell.field_label.addTextWithImage(text: "  Email",image: UIImage(named: "email")!,imageBehindText: false,keepPreviousText: false)
            cell.field_value.tag = indexPath.row
            cell.field_value.placeholder = "Required"
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0);
            return cell
        } else if(indexPath.row == 3) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customer_info", for: indexPath) as! CustomerInfoCell
            cell.field_label.text = "First Name"
            cell.field_value.tag = indexPath.row
            cell.field_value.placeholder = "Required"
            return cell
        } else if(indexPath.row == 4) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customer_info", for: indexPath) as! CustomerInfoCell
            cell.field_label.text = "Last Name"
            cell.field_value.tag = indexPath.row
            cell.field_value.placeholder = "Required"
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0);
            return cell
        } else if(indexPath.row == 6) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customer_info", for: indexPath) as! CustomerInfoCell
            cell.field_label.text = "Address 1"
            cell.field_value.tag = indexPath.row
            cell.field_value.placeholder = "Optional"
            return cell
        } else if(indexPath.row == 7) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customer_info", for: indexPath) as! CustomerInfoCell
            cell.field_label.text = "Address 2"
            cell.field_value.tag = indexPath.row
            cell.field_value.placeholder = "Optional"
            return cell
        } else if(indexPath.row == 8) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customer_info", for: indexPath) as! CustomerInfoCell
            cell.field_label.text = "City"
            cell.field_value.tag = indexPath.row
            cell.field_value.placeholder = "Optional"
            return cell
        } else if(indexPath.row == 9) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customer_info", for: indexPath) as! CustomerInfoCell
            cell.field_label.text = "Country"
            cell.field_value.tag = indexPath.row
            cell.field_value.placeholder = "Optional"
            return cell
        } else if(indexPath.row == 10) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customer_info", for: indexPath) as! CustomerInfoCell
            cell.field_label.text = "State/Province"
            cell.field_value.tag = indexPath.row
            cell.field_value.placeholder = "Optional"
            cell.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0);
            return cell
        } else if(indexPath.row == 11) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customer_info", for: indexPath) as! CustomerInfoCell
            cell.field_label.text = "Zip/Postal Code"
            cell.field_value.tag = indexPath.row
            cell.field_value.placeholder = "Optional"
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0);
            return cell
        } else if(indexPath.row == 5) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "empty_cell", for: indexPath) as! CustomerEmptyCell
            cell.sub_title.text = "BILLING ADDRESS"
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0);
            return cell
        } else if(indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "empty_cell", for: indexPath) as! CustomerEmptyCell
            cell.sub_title.text = "CONTACT NAME"
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0);
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "empty_cell", for: indexPath) as! CustomerEmptyCell
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0);
            cell.sub_title.text = ""
            return cell
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0  {
            return 30 // the height you want
        } else {
            return UITableView.automaticDimension
        }
    }

}
class CustomerInfoCell: UITableViewCell {
    @IBOutlet weak var field_label: UILabel!
    @IBOutlet weak var field_value: UITextField!
}
class CustomerEmptyCell: UITableViewCell {
    @IBOutlet weak var sub_title: UILabel!
}
