//
//  EditCustomerController.swift
//  WebwarePay
//
//  Created by Vedika on 03/12/21.
//

import UIKit
import SwiftyJSON
class EditCustomerController: MyTableViewController {
    var id = ""
    var first_name = ""
    var last_name = ""
    var customer_name = ""
    var customer_biz_txt = ""
    var email = ""
    var country = ""
    var state = ""
    var city = ""
    var line1 = ""
    var line2 = ""
    var postal_code = ""
    var customer_response: CustomerResponse!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(saveTapped))
        //self.tabBarController?.selectedIndex = 1
        self.title = "Edit Customer"
        tableView.tableFooterView = UIView()
        getCustomerDetails()
    }
    func getCustomerDetails() {
        print(email)
        var baseurl = (UserDefaults.standard.string(forKey: "api_base_url"))!
        let postData = ["":""] as [String : Any]
        self.serverApiCall(route: ("\(baseurl)/customer?email=\(email)"), method: "GET", data: postData, responseHandler: handleViewResponse, errorHandler: handleViewError)
    }
    func handleViewResponse(data: Data) {
        do{
            let json = try JSON(data: data)
            print(json)
            if let address = json["customer"][0]["Address"].array {
                let keyExists = address[0] != nil
                if keyExists {
                    var address_details = address[0]["Address"]
                    country = address_details["Country"].string ?? ""
                    state = address_details["State"].string ?? ""
                    line1 = address_details["Line1"].string ?? ""
                    line2 = address_details["Line2"].string ?? ""
                    postal_code = address_details["PostalCode"].string ?? ""
                }
            }
            if let name = json["customer"][0]["Name"].string {
                customer_name = name
            }
            if let customer_email = json["customer"][0]["Email"].string {
                email = customer_email
            }
            if let customer_id = json["customer"][0]["Id"].string {
                id = customer_id
            }
            tableView.reloadData()
        }catch let decodingEror as DecodingError {
            self.present(Common.showRequiredErrorAlert(title: "Error", content: "Error getting customer details"), animated: true)
        }catch{
            self.present(Common.showRequiredErrorAlert(title: "Error", content: "Error getting customer details"), animated: true)
        }
    }
    func handleViewError(error: Error) {
        self.present(Common.showRequiredErrorAlert(title: "Error", content: "Error getting customer details"), animated: true)
    }
    @objc func saveTapped() {
        if let customer_biz_txt_lbl = self.view.viewWithTag(12) as? UITextField {
            customer_biz_txt = "\(customer_biz_txt_lbl.text!)"
        }
        if let customer_email_txt = self.view.viewWithTag(1) as? UITextField {
            email = customer_email_txt.text!
        }
        
        if let customer_fname_txt = self.view.viewWithTag(3) as? UITextField {
            first_name = " \(customer_fname_txt.text!)"
            customer_name = first_name
        }
        if let customer_lname_txt = self.view.viewWithTag(4) as? UITextField {
            last_name = " \(customer_lname_txt.text!)"
            customer_name = ("\(customer_name) \(last_name)")
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
        var valid_email = Common.isValidEmail(email: email)
        if(customer_biz_txt != "" && customer_name != "" && line1 != "" && line2 != "" && email != "" && country != "" && state != "" && city != "") {
            if(id != "") {
                print("in iffffff")
                let postData = [ "customerInformation":[
                          "Address":[
                             "Country":country,
                             "State":state,
                             "City":city,
                             "Line1":line1,
                             "Line2":line2,
                             "PostalCode":postal_code
                          ],
                          "Name": customer_name,
                          "Email": email,
                          "Id": id
                       ]] as [String : Any]
                print(postData)
                var baseurl = (UserDefaults.standard.string(forKey: "api_base_url"))!
                self.serverApiCall(route: ("\(baseurl)/customer"), method: "PUT", data: postData, responseHandler: handleResponse, errorHandler: handleError)
            } else {
                print("in elseeeeeeeee")
                let postData = [ "customerInformation":[
                          "Address":[
                             "Country":country,
                             "State":state,
                             "City":city,
                             "Line1":line1,
                             "Line2":line2,
                             "PostalCode":postal_code
                          ],
                          "Name": customer_biz_txt,
                          "Email": email
                       ]] as [String : Any]
                print(postData)
                var baseurl = (UserDefaults.standard.string(forKey: "api_base_url"))!
                self.serverApiCall(route: ("\(baseurl)/customer"), method: "POST" , data: postData, responseHandler: handleResponse, errorHandler: handleError)
            }
        } else if(valid_email == false) {
            self.present(Common.showRequiredErrorAlert(title: Common.email_error_title, content: Common.email_error_text), animated: true)
        } else {
            print(customer_biz_txt)
            print(customer_name)
            print(line1)
            print(line2)
            print(email)
            print(country)
            print(state)
            print(city)
            print(postal_code)
            self.present(Common.showRequiredErrorAlert(title: Common.required_error_title, content: Common.required_error_text), animated: true)
        }
    }
    func handleResponse(data: Data) {
        do{
            print(data.prettyPrintedJSONString)
            self.customer_response = try JSONDecoder().decode(CustomerResponse.self, from: data)
            if(customer_response.customer != nil) {
                self.present(self.showOkAlertWithHandler(title: "Customer Updated", content: "Customer Updated Successfully"), animated: true)
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
            let storyboard: UIStoryboard = UIStoryboard(name: "Customer", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "customer_view") as! CustomerController
            self.show(vc, sender: self)
        })
        OKAction.setValue(UIColor.black, forKey: "titleTextColor")
        alert.addAction(OKAction)
        return alert
    }
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 12
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customer_info", for: indexPath) as! CustomerInfoCell
            cell.field_label.addTextWithImage(text: "  Customer",image: UIImage(named: "customer_icon")!,imageBehindText: false,keepPreviousText: false)
            cell.field_value.text = customer_name ?? ""
            cell.field_value.tag = 12
            cell.field_value.placeholder = "Required"
            return cell
        } else if(indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customer_info", for: indexPath) as! CustomerInfoCell
            cell.field_label.addTextWithImage(text: "  Email",image: UIImage(named: "email")!,imageBehindText: false,keepPreviousText: false)
            cell.field_value.text = email ?? ""
            cell.field_value.tag = indexPath.row
            cell.field_value.placeholder = "Required"
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
            return cell
        } else if(indexPath.row == 6) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customer_info", for: indexPath) as! CustomerInfoCell
            cell.field_label.text = "Address 1"
            cell.field_value.text = line1 ?? ""
            cell.field_value.tag = indexPath.row
            cell.field_value.placeholder = "Required"
            return cell
        } else if(indexPath.row == 7) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customer_info", for: indexPath) as! CustomerInfoCell
            cell.field_label.text = "Address 2"
            cell.field_value.text = line2 ?? ""
            cell.field_value.tag = indexPath.row
            cell.field_value.placeholder = "Required"
            return cell
        } else if(indexPath.row == 8) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customer_info", for: indexPath) as! CustomerInfoCell
            cell.field_label.text = "City"
            cell.field_value.text = city ?? ""
            cell.field_value.tag = indexPath.row
            cell.field_value.placeholder = "Required"
            return cell
        } else if(indexPath.row == 9) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customer_info", for: indexPath) as! CustomerInfoCell
            cell.field_label.text = "Country"
            cell.field_value.tag = indexPath.row
            cell.field_value.placeholder = "Required"
            cell.field_value.text = country ?? ""
            return cell
        } else if(indexPath.row == 10) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customer_info", for: indexPath) as! CustomerInfoCell
            cell.field_label.text = "State"
            cell.field_value.text = state ?? ""
            cell.field_value.tag = indexPath.row
            cell.field_value.placeholder = "Required"
            return cell
        } else if(indexPath.row == 11) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customer_info", for: indexPath) as! CustomerInfoCell
            cell.field_label.text = "Postal Code"
            cell.field_value.text = postal_code ?? ""
            cell.field_value.tag = indexPath.row
            cell.field_value.placeholder = "Optional"
            return cell
        } else if(indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "empty_cell", for: indexPath) as! CustomerEmptyCell
            cell.sub_title.text = "CONTACT NAME"
            return cell
        } else if(indexPath.row == 5) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "empty_cell", for: indexPath) as! CustomerEmptyCell
            cell.sub_title.text = "BILLING ADDRESS"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "empty_cell", for: indexPath) as! CustomerEmptyCell
            cell.sub_title.text = ""
            return cell
        }
    }

}
