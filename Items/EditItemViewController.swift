//
//  AddItemViewController.swift
//  WebwarePay
//
//  Created by Vedika on 08/11/21.
//

import UIKit

class EditItemViewController: MyTableViewController, UITextViewDelegate {

    var tax_selected = String()
    struct selected_item_info {
        var name : String
        var description : String
        var quantity : Int
        var price : Int
    }
    var selected_item = [[]] as Any
    var fromEditItem = false
    var fromCloneItem = false
    var product_name = ""
    var product_description = ""
    var product_price = 0.0
    var product_id = ""
    var item_response: ItemResponse!
    
    var item_name = ""
    var item_desc = ""
    var item_price :Double? = 0
    var item_quantity :Int? = 0
    var product_price_converted = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add Product"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(saveTapped))
        tableView.tableFooterView = UIView()
        self.setNavigationToWhite()
        print("on load \(product_price)")
    }
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    @objc func saveTapped() {
        if let item_name_txt = self.view.viewWithTag(1) as? UITextField {
            item_name = item_name_txt.text!
        }
        //if let item_desc_txt = self.view.viewWithTag(2) as? UITextField {
        if let item_desc_txt = self.view.viewWithTag(2) as? UITextView {
            item_desc = item_desc_txt.text!
        }
        if let item_price_txt = self.view.viewWithTag(4) as? UITextField {
            if let price_entered = Double(item_price_txt.text!) {
                item_price = Double(item_price_txt.text!) ?? 0
                item_price = item_price! * 100
                product_price_converted = Double(Common.roundTwoDecimal(val: item_price!) / 100)
            } else {
                item_price = 0
            }
        }
        if(fromEditItem == true) {
            if(item_name != "" && item_desc != "") {
                    let postData = [ "productInformation":[
                              "id": product_id,
                              "name": item_name,
                              "description": item_desc
                           ]] as [String : Any]
                    print(postData)
                    let baseurl = (UserDefaults.standard.string(forKey: "api_base_url"))!
                    self.serverApiCall(route: ("\(baseurl)/product"), method: "PUT", data: postData, responseHandler: handleResponse, errorHandler: handleError)
            } else {
                self.present(Common.showRequiredErrorAlert(title: Common.required_error_title, content: Common.required_error_text), animated: true)
            }
        } else {
            if(item_name != "" && item_desc != "" && item_price != 0) {
                    if(item_price != 0) {
                        navigationItem.rightBarButtonItem?.isEnabled = false
                        let postData = [ "priceInformation":[
                                  "product_data": [
                                    "name" : item_name,
                                    "description": item_desc,
                                  ],
                                  "unit_amount": Common.roundTwoDecimal(val: item_price!),
                                  "currency" : UserDefaults.standard.string(forKey: "short_currency") ?? ""
                                ]] as [String : Any]
                        print("in post \(postData)")
                        var baseurl = (UserDefaults.standard.string(forKey: "api_base_url"))!
                        self.serverApiCall(route: ("\(baseurl)/product"), method: "POST", data: postData, responseHandler: handleResponse, errorHandler: handleError)
                    } else {
                        print("in else 1")
                        self.present(Common.showRequiredErrorAlert(title: Common.required_error_title, content: Common.required_error_text), animated: true)
                    }
            } else {
                print("in else 2")
                self.present(Common.showRequiredErrorAlert(title: Common.required_error_title, content: Common.required_error_text), animated: true)
            }
        }
        
        
    }
    func handleResponse(data: Data) {
        do{
            print(data.prettyPrintedJSONString)
            self.item_response = try JSONDecoder().decode(ItemResponse.self, from: data)
            if(item_response.product != nil) {
                navigationItem.rightBarButtonItem?.isEnabled = true
                if(fromEditItem == true) {
                    SnowplowManager.shared?.track_item_actions(id: product_id, action: "edit", name: item_name, description: item_desc, price: String(product_price_converted))
                    self.present(self.showOkAlertWithHandler(title: "Product Updated", content: "Product updated Successfully"), animated: true)
                } else {
                    SnowplowManager.shared?.track_item_actions(id: item_response.product, action: "add", name: item_name, description: item_desc, price: String(product_price_converted) )
                    self.present(self.showOkAlertWithHandler(title: "Product Added", content: "Product added Successfully"), animated: true)
                }
            } else {
                navigationItem.rightBarButtonItem?.isEnabled = true
                self.present(Common.showErrorAlert(title: Common.add_error_title, content: Common.add_error_text), animated: true)
            }
            
        }catch let decodingEror as DecodingError {
            navigationItem.rightBarButtonItem?.isEnabled = true
            self.present(Common.showErrorAlert(title: Common.add_error_title, content: Common.add_error_text), animated: true)
            //print("in decoding error \(decodingEror)")
        }catch{
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    func handleError(error: Error) {
        print(error)
        navigationItem.rightBarButtonItem?.isEnabled = true
        self.present(Common.showErrorAlert(title: Common.add_error_title, content: Common.add_error_text), animated: true)
    }
    func showOkAlertWithHandler(title: String, content: String) -> UIAlertController{
        let alert = UIAlertController(title: title, message: content, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: { [self]  action in
            var vc = self.storyboard!.instantiateViewController(withIdentifier: "item_list_view") as! ItemController
            self.show(vc, sender: self)
        })
        OKAction.setValue(UIColor.black, forKey: "titleTextColor")
        alert.addAction(OKAction)
        return alert
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(fromEditItem == true) {
            return 3
        } else {
            return 5
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 1) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "item_info", for: indexPath) as! ItemInfoCell
                cell.field_label.text = "Name"
                cell.fiels_value.text = product_name
                cell.fiels_value.tag = indexPath.row
                cell.fiels_value.placeholder = "Required"
                cell.container_view.roundCorners(corners: [.topLeft, .topRight], radius: 8.0)
                cell.container_view.addBorder(toSide: UIView.ViewSide.Bottom, withColor: UIColor.lightGray, andThickness: 0.2)
                cell.fiels_value.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)
                return cell
            
        } else if(indexPath.row == 2) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "desc_info", for: indexPath) as! ItemDescriptionCell
                cell.field_label.text = "Description"
                
                cell.description_value.tag = indexPath.row
                if(product_description == "") {
                    cell.description_value.text = "Required"
                    cell.description_value.textColor = UIColor(red: 0.74, green: 0.74, blue: 0.74, alpha: 1.00)
                } else {
                    cell.description_value.text = product_description
                    cell.description_value.textColor = UIColor.black
                }
                
                cell.container_view.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 8.0)
                cell.description_value.delegate = self
                return cell
                /*
                let cell = tableView.dequeueReusableCell(withIdentifier: "item_info", for: indexPath) as! ItemInfoCell
                cell.field_label.text = "Description"
                cell.fiels_value.text = product_description
                cell.fiels_value.tag = indexPath.row
                cell.fiels_value.placeholder = "Required"
            
                cell.fiels_value.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)
                cell.container_view.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 8.0)
                
                return cell
                */
        } else if(indexPath.row == 4) {
            if(fromEditItem == false) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "item_info", for: indexPath) as! ItemInfoCell
                cell.field_label.text = "Price"
                print(product_price)
                if(product_price != 0) {
                    cell.fiels_value.text = String(product_price)
                }
                cell.fiels_value.tag = indexPath.row
                cell.fiels_value.placeholder = "Required"
                cell.fiels_value.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)
                cell.container_view.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 8.0)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "empty_cell", for: indexPath) as! ItemEmptyCell
                return cell
            }
            
        } /*else if(indexPath.row == 6) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "item_info", for: indexPath) as! ItemInfoCell
            cell.field_label.text = "Tax"
            cell.field_value.text = tax_selected != "" ? tax_selected : "Select A Tax >"
            return cell
        } else if(indexPath.row == 7) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "item_info", for: indexPath) as! ItemInfoCell
            cell.field_label.text = "Income Amount"
            cell.field_value.text = "Sales >"
            return cell
        } else if(indexPath.row == 9) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "item_info", for: indexPath) as! ItemInfoCell
            cell.field_label.text = "1 * 200"
            cell.field_value.text = "200"
            return cell
        } else if(indexPath.row == 10) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "item_info", for: indexPath) as! ItemInfoCell
            cell.field_label.text = "GST 13.00%"
            cell.field_value.text = "26"
            return cell
        } else if(indexPath.row == 11) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "item_info", for: indexPath) as! ItemInfoCell
            cell.field_label.text = "Amount"
            cell.field_value.text = "226.00"
            return cell
        } */
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "empty_cell", for: indexPath) as! ItemEmptyCell
            return cell
        }
        
    }
    private func textLimit(existingText: String?,
                           newText: String,
                           limit: Int) -> Bool {
        let text = existingText ?? ""
        let isAtLimit = text.count + newText.count <= limit
        return isAtLimit
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("in textViewDidBeginEditing \(textView.text)")
        if textView.text == "Required" {
            print("inside if")
            textView.text = nil
            textView.textColor = UIColor.black
        }
        
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        print("in textViewDidEndEditing")
        if textView.text.isEmpty {
            textView.text = "Required"
            textView.textColor = UIColor(red: 0.74, green: 0.74, blue: 0.74, alpha: 1.00)
        }
    }
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        
        
        return self.textLimit(existingText: textView.text,
                              newText: text,
                              limit: 100)
    }
    @objc func myTextFieldDidChange(_ textField: UITextField) {
        //print("tag of selected \(textField.tag)")
        if(textField.tag == 4) {
            if let amountString = textField.text?.currencyInputFormatting() {
                textField.text = amountString
            }
        } else if(textField.tag == 1 ) {
            var limit = 25
            if(textField.text!.count > limit ) {
                var str = textField.text
                var offset = limit
                if(textField.text!.count < limit) {
                    offset = textField.text!.count - 1
                }
                let index = str!.index(str!.startIndex, offsetBy: offset)
                let mySubstring = String(str![..<index])
                textField.text = mySubstring
            }
        } else if(textField.tag == 2) {
            var limit = 100
            if(textField.text!.count > limit ) {
                var str = textField.text
                var offset = limit
                if(textField.text!.count < limit) {
                    offset = textField.text!.count - 1
                }
                let index = str!.index(str!.startIndex, offsetBy: offset)
                let mySubstring = String(str![..<index])
                textField.text = mySubstring
            }
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 || indexPath.row == 3 {
            return 30
        } else if(indexPath.row == 2) {
            return 100
        } else {
            return UITableView.automaticDimension
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

}
class ItemInfoCell: UITableViewCell {
    @IBOutlet weak var field_label: UILabel!
    @IBOutlet weak var fiels_value: UITextField!
    
    @IBOutlet weak var container_view: UIView!
    /*override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: Common.table_content_inset)
    }*/
}
class ItemDescriptionCell: UITableViewCell, UITextViewDelegate {
    @IBOutlet weak var field_label: UILabel!
    @IBOutlet weak var description_value: UITextView!
    @IBOutlet weak var container_view: UIView!
    /*override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: Common.table_content_inset)
    }*/
}
class ItemEmptyCell: UITableViewCell {
    
}
