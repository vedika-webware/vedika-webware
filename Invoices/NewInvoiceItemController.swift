//
//  NewInvoiceItemController.swift
//  WebwarePay
//
//  Created by Vedika on 07/12/21.
//

import UIKit

class NewInvoiceItemController: MyTableViewController, UITextViewDelegate {
    
    var tax_selected = String()
    struct selected_item_info {
        var name : String
        var description : String
        var quantity : Int
        var price : Int
    }
    //var selected_item = [[]] as Any
    var product_name = ""
    var product_description = ""
    var product_price = 0.0
    var item_response: ItemResponse!
    var product_quantity_entered = 0;
    var fromEditInvoice = false
    var fromCloneItem = false
    var product_price_id = ""
    var invoice_id = ""
    var invoice_item_response: InvoiceItemResponse!
    
    var item_name = ""
    var item_desc = ""
    var item_price :Double? = 0
    var item_quantity :Int? = 0
    var selected_item = [[ Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add Product"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(saveTapped))
        tableView.tableFooterView = UIView()
        self.setNavigationToWhite()
        //self.tabBarController?.selectedIndex = 2
        //if(UserDefaults.standard.array(forKey: "selected_item") != nil) {
            //selected_item = UserDefaults.standard.array(forKey: "selected_item") as! [AddItemViewController.selected_item_info]
        //}
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
            product_description = item_desc
        }
        if let item_price_txt = self.view.viewWithTag(5) as? UITextField {
            if let price_entered = Double(item_price_txt.text!) {
                item_price = Double(item_price_txt.text!) ?? 0
                item_price = item_price! * 100
            } else {
                item_price = 0
            }
        }
        if let item_quantity_txt = self.view.viewWithTag(4) as? UITextField {
            item_quantity = Int(item_quantity_txt.text ?? "0")
            product_quantity_entered = item_quantity ?? 0
        }
        print("item name \(item_name)")
        print("item_price \(item_price)")
        print("item_desc \(item_desc)")
        print("item_quantity \(item_quantity)")
        if(item_name != "" && item_price != nil && item_price != 0 && item_desc != nil && item_quantity != 0) {
            navigationItem.rightBarButtonItem?.isEnabled = false
            let postData = [ "priceInformation":[
                      "product_data": [
                        "name" : item_name,
                        "description": item_desc
                      ],
                    "unit_amount": Common.roundTwoDecimal(val: item_price!),
                      "currency" : UserDefaults.standard.string(forKey: "short_currency") ?? ""
                    ]] as [String : Any]
            print(postData)
            var baseurl = (UserDefaults.standard.string(forKey: "api_base_url"))!
            self.serverApiCall(route: ("\(baseurl)/product"), method: "POST", data: postData, responseHandler: handleResponse, errorHandler: handleError)
            
            
            //var selected_item = [[ Any]]()
            if(UserDefaults.standard.array(forKey: "selected_item") != nil) {
                selected_item = (UserDefaults.standard.array(forKey: "selected_item") as? [[ Any]])!;
            }
            //selected_item.append([item_name,item_desc, item_price, item_quantity])
            //UserDefaults.standard.set(selected_item, forKey: "selected_item")
            
        } else {
            self.present(Common.showRequiredErrorAlert(title: Common.required_error_title, content: Common.required_error_text), animated: true)
        }
    }
    func handleResponse(data: Data) {
        do{
            print(data.prettyPrintedJSONString)
            self.item_response = try JSONDecoder().decode(ItemResponse.self, from: data)
            if(item_response.product != nil) {
                //SnowplowManager.shared?.track_item_details(itemId: self.item_response.product, quantity: product_quantity_entered)
                navigationItem.rightBarButtonItem?.isEnabled = true
                product_price_id = self.item_response.product
                //addInvoiceItem(quantity: product_quantity_entered)
                var current_currency = UserDefaults.standard.string(forKey: "currency")!
                let pricestring = String(Double(Common.roundTwoDecimal(val: item_price!) / 100))
                var product_price_converted = Double(Common.roundTwoDecimal(val: item_price!) / 100)
                selected_item.append([item_name,
                                      item_desc,
                                      product_price_converted,
                                      item_quantity,
                                      "",
                                      current_currency,
                                      product_price_id])

                addInvoiceItemNew()
                SnowplowManager.shared?.track_item_actions(id: product_price_id, action: "add", name: item_name, description: item_desc, price: String(product_price_converted))
            } else {
                self.present(Common.showErrorAlert(title: Common.add_error_title, content: Common.add_error_text), animated: true)
            }
            
        }catch let decodingEror as DecodingError {
            self.present(Common.showErrorAlert(title: Common.add_error_title, content: Common.add_error_text), animated: true)
            //print("in decoding error \(decodingEror)")
            navigationItem.rightBarButtonItem?.isEnabled = true
        }catch{
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    func handleError(error: Error) {
        navigationItem.rightBarButtonItem?.isEnabled = true
        self.present(Common.showErrorAlert(title: Common.add_error_title, content: Common.add_error_text), animated: true)
    }
    func addInvoiceItemNew() {
        //var current_currency = UserDefaults.standard.string(forKey: "currency")!
        //selected_item.append([item_name,item_desc, item_price, item_quantity, "", current_currency, self.product_price_id])
        UserDefaults.standard.set(selected_item, forKey: "selected_item")
        UserDefaults.standard.set(selected_item, forKey: "updated_qty_array")
        if(fromEditInvoice == true) {
            self.present(self.showOkAlertWithHandlerOnEdit(title: "Product Added", content: "Product added Successfully"), animated: true)
        } else {
            self.present(self.showOkAlertWithHandler(title: "Product Added", content: "Product added Successfully"), animated: true)
        }
    }
    
    func addInvoiceItem(quantity : Int) {
        var customer_id = UserDefaults.standard.string(forKey: "selected_customer_id") ?? nil
        var baseurl = (UserDefaults.standard.string(forKey: "api_base_url"))!
        if(fromEditInvoice == false) {
            navigationItem.rightBarButtonItem?.isEnabled = false
            let postData = [ "invoiceitemInformation":[
                      "currency": UserDefaults.standard.string(forKey: "short_currency") ?? "",
                      "customer": customer_id!,
                      "description" : product_description,
                      "price" : product_price_id,
                      "quantity" : quantity
                    ]] as [String : Any]
            //print(postData)
            self.serverApiCall(route: ("\(baseurl)/invoiceitem"), method: "POST", data: postData, responseHandler: handleResponseAddItem, errorHandler: handleErrorAddItem)
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
            let postData = [ "invoiceitemInformation":[
                      "currency": UserDefaults.standard.string(forKey: "short_currency") ?? "",
                      "customer": customer_id!,
                      "description" : product_name,
                      "price" : product_price_id,
                      "quantity" : quantity,
                      "invoiceId": invoice_id
                    ]] as [String : Any]
            self.serverApiCall(route: ("\(baseurl)/invoiceitem"), method: "POST", data: postData, responseHandler: handleResponseAddItem, errorHandler: handleErrorAddItem)
        }
        
    }
    
    func handleResponseAddItem(data: Data) {
        do{
            navigationItem.rightBarButtonItem?.isEnabled = true
            self.invoice_item_response = try JSONDecoder().decode(InvoiceItemResponse.self, from: data)
            SnowplowManager.shared?.track_item_details(itemId: self.invoice_item_response.invoiceitem, quantity: product_quantity_entered)
            if(fromEditInvoice == true) {
                //self.performSegue(withIdentifier: "back_to_edit_segue", sender: self)
                self.present(self.showOkAlertWithHandlerOnEdit(title: "Item Added", content: "Item added Successfully"), animated: true)
            } else {
                selected_item.append([item_name,item_desc, item_price, item_quantity, self.invoice_item_response.invoiceitem])
                UserDefaults.standard.set(selected_item, forKey: "selected_item")
                UserDefaults.standard.set(selected_item, forKey: "updated_qty_array")
                //self.performSegue(withIdentifier: "back_to_add_invoice_screen", sender: self)
                self.present(self.showOkAlertWithHandler(title: "Item Added", content: "Item added Successfully"), animated: true)
            }
        }catch let decodingEror as DecodingError {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }catch{
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
        
    }
    func handleErrorAddItem(error: Error) {
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    func showOkAlertWithHandler(title: String, content: String) -> UIAlertController{
        let alert = UIAlertController(title: title, message: content, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: { [self]  action in
            let storyboard: UIStoryboard = UIStoryboard(name: "Invoice", bundle: nil)
            var vc = storyboard.instantiateViewController(withIdentifier: "add_invoice_screen") as! AddInvoiceController
            self.show(vc, sender: self)
        })
        OKAction.setValue(UIColor.black, forKey: "titleTextColor")
        alert.addAction(OKAction)
        return alert
    }
    func showOkAlertWithHandlerOnEdit(title: String, content: String) -> UIAlertController{
        let alert = UIAlertController(title: title, message: content, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: { [self]  action in
            let storyboard: UIStoryboard = UIStoryboard(name: "Invoice", bundle: nil)
            var vc = storyboard.instantiateViewController(withIdentifier: "edit_invoice_screen") as! EditInvoiceController
            vc.invoice_id = invoice_id
            self.show(vc, sender: self)
        })
        OKAction.setValue(UIColor.black, forKey: "titleTextColor")
        alert.addAction(OKAction)
        return alert
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(tax_selected == "") {
            return 6
        } else {
            self.showToast(message: "\(tax_selected) Tax Added", font: UIFont.boldSystemFont(ofSize: 12))
            return 10
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 1) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "item_info", for: indexPath) as! NewItemInfoCell
                cell.field_label.text = "Name"
                cell.fiels_value.tag = indexPath.row
                cell.fiels_value.placeholder = "Required"
                cell.fiels_value.text = product_name
                cell.container_view.roundCorners(corners: [.topLeft, .topRight], radius: 8.0)
                cell.fiels_value.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)
                cell.container_view.addBorder(toSide: UIView.ViewSide.Bottom, withColor: UIColor.lightGray, andThickness: 0.2)
            return cell
           
        } else if(indexPath.row == 2) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "new_desc_info", for: indexPath) as! NewItemDescCell
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
                let cell = tableView.dequeueReusableCell(withIdentifier: "item_info", for: indexPath) as! NewItemInfoCell
                cell.field_label.text = "Description"
                cell.fiels_value.tag = indexPath.row
                cell.fiels_value.placeholder = "Required"
                cell.container_view.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 8.0)
                cell.fiels_value.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)
                return cell
                */
        } else if(indexPath.row == 4) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "item_info", for: indexPath) as! NewItemInfoCell
                cell.field_label.text = "Quantity"
                cell.fiels_value.tag = indexPath.row
                cell.fiels_value.placeholder = "Required"
                //cell.fiels_value.delegate = self
                //cell.fiels_value.addTarget(self, action: #selector(valueChanged), for: .editingChanged)
            cell.fiels_value.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)
                cell.container_view.roundCorners(corners: [.topLeft, .topRight], radius: 8.0)
            cell.container_view.addBorder(toSide: UIView.ViewSide.Bottom, withColor: UIColor.lightGray, andThickness: 0.2)
                return cell
            
        } else if(indexPath.row == 5) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "item_info", for: indexPath) as! NewItemInfoCell
                cell.field_label.text = "Price"
                cell.fiels_value.tag = indexPath.row
                cell.fiels_value.placeholder = "Required"
                cell.fiels_value.text = String(product_price)
                //cell.fiels_value.delegate = self
                //cell.fiels_value.addTarget(self, action: #selector(valueChanged), for: .editingChanged)
                cell.container_view.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 8.0)
                cell.fiels_value.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)
                return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "empty_cell", for: indexPath) as! NewItemEmptyCell
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
        if(textField.tag == 5) {
            if let amountString = textField.text?.currencyInputFormatting() {
                textField.text = amountString
            }
        } else if (textField.tag == 4) {
            var entered_text = textField.text!
            if entered_text.isInt {
                if(entered_text.count > 2) {
                    textField.text = String(entered_text.prefix(2))
                }
            } else {
                textField.text = ""
            }
        } else if(textField.tag == 1) {
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
        if(indexPath.row == 6) {
            performSegue(withIdentifier: "add_tax_segue", sender: self)
        }
    }
}
class NewItemInfoCell: UITableViewCell {
    @IBOutlet weak var field_label: UILabel!
    @IBOutlet weak var container_view: UIView!
    @IBOutlet weak var fiels_value: UITextField!
}
class NewItemDescCell: UITableViewCell {
    @IBOutlet weak var field_label: UILabel!
    @IBOutlet weak var container_view: UIView!
    @IBOutlet weak var description_value: UITextView!
}
class NewItemEmptyCell: UITableViewCell {
    
}
