//
//  InvoiceItemController.swift
//  WebwarePay
//
//  Created by Vedika on 07/12/21.
//

import UIKit
import SwiftyJSON
class InvoiceItemController: MyTableViewController {
    @IBOutlet weak var search_bar: UISearchBar!
    var itemList = [[String]]()
    var searching = false
    // this is our array of arrays
    var searchedItem = [[String]]()
    var itemNameList = [String]()
    var itemIds = [String]()
    var searchIds = [String]()
    var selected: String?
    var fromAddInvoice = true
    var fromEditInvoice = false
    var product_name = ""
    var product_description = ""
    var product_price = 0.0
    var product_price_id = ""
    var invoice_id = ""
    var currency_symbol = ""
    var item_quantity = 0
    var is_data_loaded = false
    var item_response: InvoiceItemResponse!
    var selected_item = [[ Any]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Select Product"
        //self.tableView.delegate = self
        //self.tableView.dataSource = self
        self.search_bar.delegate = self
        search_bar.backgroundImage = UIImage()
        search_bar.setDetaults()
        search_bar.searchTextField.placeholder = "Search by product name or description"
        //addDoneToolBarToKeyboardSearch(textView: search_bar.searchTextField)
        navigationItem.rightBarButtonItem = getAddButton()
        self.tableView.separatorStyle = .none
        self.tableView.tintColor = UIColor.black
        self.tableView.backgroundColor = UIColor.white
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadData), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refreshControl
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        tableView.separatorColor = Common.separatorColor
        tableView.separatorInset = Common.separatorInsetItem
        self.setNavigationDefaults()
        //self.listOfItem()
    }
    override func viewDidAppear(_ animated: Bool) {
        self.setNavigationDefaults()
        self.listOfItem()
        //tableView.reloadData()
    }
    @objc func reloadData(_ sender: AnyObject) {
        self.listOfItem()
    }
    @objc func addTapped() {
        performSegue(withIdentifier: "add_new_invoice_item", sender: Self.self)
    }
    func listOfItem() {
        let baseurl = (UserDefaults.standard.string(forKey: "api_base_url"))!
        let postData = ["":""] as [String : Any]
        self.serverApiCall(route: ("\(baseurl)/product?productList=1"), method: "GET", data: postData, responseHandler: handleResponse, errorHandler: handleError)
    }
    func handleResponse(data: Data) {
        do{
            is_data_loaded = true
            itemList = [[String]]()
            let json = try JSON(data: data)
            //print(json)
            if let products = json["product"].array {
                for product in products {
                    var productObj = [String]()
                    var name = ""
                    var product_price = ""
                    var product_id = ""
                    var price_id = ""
                    var description = ""
                    var item_description = ""
                    var currencyPrefix = ""
                    for field in product {
                        if(field.0 == "Name") {
                            if var x = field.1.rawValue as? Int{
                                name = String(x)
                            } else if var x = field.1.rawValue as? String{
                                name = field.1.rawValue as! String
                            }
                            //name = name.crop_string(length: Common.product_name_maxlength)
                            itemNameList.append(name.capitalizingFirstLetter() ?? "")
                        }
                        if(field.0 == "UnitAmount") {
                            //let price : Int = field.1.rawValue as! Int
                            //var pricestring = String(price/100)
                            //product_price = pricestring
                            let price : Double = field.1.rawValue as! Double
                            let pricestring = String(Double(Common.roundTwoDecimal(val: price) / 100))
                            product_price = pricestring
                        }
                        if(field.0 == "Id") {
                            product_id = field.1.string ?? ""
                        }
                        if(field.0 == "PriceID") {
                            price_id = field.1.string ?? ""
                        }
                        if(field.0 == "Description") {
                            description = field.1.string?.capitalizingFirstLetter() ?? ""
                            //description = description.crop_string(length: Common.product_desc_maxlength)
                        }
                        if(field.0 == "DESCRIPTION" && description == "") {
                            description = field.1.string?.capitalizingFirstLetter() ?? ""
                            //description = description.crop_string(length: Common.product_desc_maxlength)
                        }
                        if(field.0 == "CurrencyPrefix") {
                            currencyPrefix = String(htmlEncodedString: field.1.string ?? "") ?? ""
                        }
                    }
                    productObj.append(name.capitalizingFirstLetter())
                    productObj.append(product_id)
                    productObj.append(product_price)
                    productObj.append(price_id)
                    productObj.append(description)
                    productObj.append(currencyPrefix)
                    productObj.append(item_description)
                    
                    if(productObj != nil) {
                        itemList.append(productObj)
                        itemIds.append(product_id)
                    }
                }
            }
            SnowplowManager.shared?.track_item_list(search: "", itemIds: itemIds)
            //tableView.refreshControl?.removeFromSuperview()
            tableView.refreshControl?.endRefreshing()
            tableView.reloadData()
            let indexPath = IndexPath(item: 0, section: 0)
            tableView.scrollToRow(at: indexPath, at: .none, animated: false)
        }catch let decodingEror as DecodingError {
            print("in decoding error \(decodingEror)")
            tableView.refreshControl?.endRefreshing()
        }catch{
            tableView.refreshControl?.endRefreshing()
        }
        
    }
    func handleError(error: Error) {
        tableView.refreshControl?.endRefreshing()
    }
    
}
class AddInvoiceItemCell: UITableViewCell {
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    var cloneBlock: (() -> Void)? = nil
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: Common.table_content_inset)
    }
    @IBAction func clone_btn(_ sender: Any) {
        cloneBlock?()
    }
    
    /*
    private lazy var maskLayer = CAShapeLayer()

        var corners: UIRectCorner = [] {
            didSet {
                setNeedsLayout()
                updatePath(with: corners)
            }
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            contentView.frame = contentView.frame.inset(by: Common.table_content_inset)
            updatePath(with: corners)
        }

        private func updatePath(with corners: UIRectCorner) {
            let path = UIBezierPath(
                roundedRect: bounds,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: 15, height:  15)
            )
            maskLayer.path = path.cgPath
            layer.mask = maskLayer
        }
    */
}

extension InvoiceItemController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(itemList.count <= 0 && is_data_loaded == true) {
            return 1
        } else if(is_data_loaded == true) {
            if searching {
                if(searchedItem.count <= 0) {
                    return 1
                } else {
                    return searchedItem.count + 2
                }
            } else {
                return itemList.count + 2
            }
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = UITableViewCell()
        if(itemList.count <= 0 && is_data_loaded == true) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "no_item", for: indexPath) as! NoInvoiceItemListCell
            cell.contentView.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10.0)
            cell.separatorInset = UIEdgeInsets(top: 0.0, left: cell.bounds.size.width, bottom: 0.0, right: 0.0);
            cell.contentView.dropShadow()
            return cell
        } /*else if(indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "empty_cell", for: indexPath) as! InvoiceItemListEmptyCell
            cell.separatorInset = UIEdgeInsets(top: 0.0, left: cell.bounds.size.width, bottom: 0.0, right: 0.0);
            return cell
        }*/else {
            if(searching == true && searchedItem.count <= 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "no_search_item_result", for: indexPath) as! NoSearchInvoiceItemCell
                return cell
            } else {
                if(indexPath.row == 0) {
                    //if(itemList.count == 1 || searchedItem.count == 1) {
                        
                    //} else {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "rounded_cell", for: indexPath) as! InvoiceRoundedItemCell
                        cell.separatorInset = UIEdgeInsets(top: 0.0, left: cell.bounds.size.width, bottom: 0.0, right: 0.0);
                        cell.contentView.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
                        return cell
                    //}
                } else if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "rounded_cell", for: indexPath) as! InvoiceRoundedItemCell
                    cell.contentView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 10.0)
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "item", for: indexPath) as! AddInvoiceItemCell
                    if indexPath.row == itemList.count ||  indexPath.row == searchedItem.count {
                        cell.separatorInset = UIEdgeInsets(top: 0.0, left: cell.bounds.size.width, bottom: 0.0, right: 0.0);
                    } else {
                        cell.separatorInset = Common.separatorInsetItem
                    }
                    if searching {
                        var row_current = indexPath.row - 1
                        if(searchedItem.indices.contains(row_current)) {
                            var desc = "-"
                            if(searchedItem[row_current][4] != "") {
                                desc = searchedItem[row_current][4]
                            }
                            cell.label1.text = searchedItem[row_current][0]
                            cell.label2.text = desc
                            //cell.label2.sizeToFit()

                            cell.label3.text = "\(searchedItem[row_current][5])\(searchedItem[row_current][2])"
                            cell.cloneBlock = { [self] in
                                product_name = searchedItem[row_current][0]
                                product_description = desc
                                product_price = Double(searchedItem[row_current][2])!
                                self.performSegue(withIdentifier: "clone_segue", sender: Self.self)
                            }
                        }
                    } else {
                        //print("in else")
                        var row_current = indexPath.row - 1
                        if(itemList.indices.contains(row_current)) {
                            var desc = "-"
                            if(itemList[row_current][4] != "") {
                                desc = itemList[row_current][4]
                            }
                            cell.label1.text = itemList[row_current][0]
                            cell.label2.text = desc
                            //cell.label2.sizeToFit()
                            cell.label3.text = "\(itemList[row_current][5])\(itemList[row_current][2])"
                            cell.cloneBlock = { [self] in
                                product_name = itemList[row_current][0]
                                product_description = desc
                                product_price = Double(itemList[row_current][2])!
                                self.performSegue(withIdentifier: "clone_segue", sender: Self.self)
                            }
                        }
                    }
                    return cell
                }
                /*
                if indexPath.row == 0 {
                    if(itemList.count == 1 || searchedItem.count == 1) {
                        cell.contentView.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10.0)
                    } else {
                        cell.contentView.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
                    }
                } else if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
                    cell.contentView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 10.0)
                } else {
                    cell.contentView.roundCorners(corners: [], radius: 10.0)
                }
                */
                let cell = tableView.dequeueReusableCell(withIdentifier: "item", for: indexPath) as! AddInvoiceItemCell
                return cell
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row != 0) {
            if(indexPath.row < itemList.count + 1 ||  indexPath.row < searchedItem.count) {
                if((fromAddInvoice == true || fromEditInvoice == true) && itemList.count > 0) {
                    var selected_row = indexPath.row - 1
                    //let indexPathSelected = IndexPath(item: selected_row, section: 0)
                    //let currentCell = tableView.cellForRow(at: indexPathSelected) as! AddInvoiceItemCell
                    
                    if(searching == true) {
                        product_name = searchedItem[selected_row][0]
                        product_description = searchedItem[selected_row][4]
                        product_price = Double(searchedItem[selected_row][2])!
                        product_price_id = searchedItem[selected_row][3]
                        currency_symbol = searchedItem[selected_row][5]
                    } else {
                        product_name = itemList[selected_row][0]
                        product_description = itemList[selected_row][4]
                        product_price = Double(itemList[selected_row][2])!
                        product_price_id = itemList[selected_row][3]
                        currency_symbol = itemList[selected_row][5]
                    }
                    print(product_price)
                    let alert = UIAlertController(title: "Enter Details", message: "Please enter required quantity for \(product_name)", preferredStyle: .alert)
                    alert.view.tintColor = Common.alert_tint_color
                    //2. Add the text field. You can configure it however you need.
                    /*alert.addTextField { (textField) in
                        textField.placeholder = "Description"
                    }
                    */
                    alert.addTextField { (textField) in
                        textField.placeholder = "Quantity"
                        textField.keyboardType = .numberPad
                        //textField.delegate = self
                        //textField.addTarget(self, action: #selector(self.valueChangedToNumber), for: .editingChanged)
                        textField.addTarget(self, action: #selector(self.myTextFieldDidChange), for: .editingChanged)
                    }
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak alert] (_) in
                        
                    }))
                    // 3. Grab the value from the text field, and print it when the user clicks OK.
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                        //let textFieldDescription = alert?.textFields![0]
                        //let item_description = textFieldDescription!.text!
                        //self.product_description = item_description
                        //if(alert?.textFields![1].text == "" || alert?.textFields![0].text == "") {
                        if(alert?.textFields![0].text == "") {
                            self.present(Common.showRequiredErrorAlert(title: Common.required_error_title, content: Common.required_error_text), animated: true)
                        } else {
                            let textField = alert?.textFields![0]
                            let item_quantity = Int(textField!.text!)!
                            
                            
                            if(UserDefaults.standard.array(forKey: "selected_item") != nil) {
                                self.selected_item = (UserDefaults.standard.array(forKey: "selected_item") as? [[ Any]])!;
                            }
                            //self.addInvoiceItem(quantity: item_quantity)
                            self.saveInvoiceItem(quantity: item_quantity)
                        }
                    }))

                    // 4. Present the alert.
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    @objc func myTextFieldDidChange(_ textField: UITextField) {
        var entered_text = textField.text!
        if entered_text.isInt {
            if(entered_text.count > 2) {
                textField.text = String(entered_text.prefix(2))
            }
        } else {
            textField.text = ""
        }
        
    }
    func saveInvoiceItem(quantity : Int) {
        //self.selected_item.append([self.product_name,self.product_description, self.product_price, item_quantity, self.item_response.invoiceitem, self.currency_symbol])
        //print([self.product_name,self.product_description, self.product_price, quantity, "", self.currency_symbol, self.product_price_id])
        self.selected_item.append([self.product_name,self.product_description, self.product_price, quantity, "", self.currency_symbol, self.product_price_id])
        UserDefaults.standard.set(self.selected_item, forKey: "selected_item")
        UserDefaults.standard.set(self.selected_item, forKey: "updated_qty_array")
        if(fromEditInvoice == true) {
            self.performSegue(withIdentifier: "back_to_edit_segue", sender: self)
        } else {
            self.performSegue(withIdentifier: "back_to_add_invoice_screen", sender: self)
        }
    }
    func addInvoiceItem(quantity : Int) {
        item_quantity = quantity
        let customer_id = UserDefaults.standard.string(forKey: "selected_customer_id") ?? nil
        let baseurl = (UserDefaults.standard.string(forKey: "api_base_url"))!
        if(fromEditInvoice == false) {
            let postData = [ "invoiceitemInformation":[
                      "currency": UserDefaults.standard.string(forKey: "short_currency") ?? "",
                      "customer": customer_id,
                      "description" : product_description,
                      "price" : product_price_id,
                      "quantity" : quantity
                    ]] as [String : Any]
            self.serverApiCall(route: ("\(baseurl)/invoiceitem"), method: "POST", data: postData, responseHandler: handleResponseAddItem, errorHandler: handleErrorAddItem)
        } else {
            let postData = [ "invoiceitemInformation":[
                      "currency": UserDefaults.standard.string(forKey: "short_currency") ?? "",
                      "customer": customer_id,
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
            self.item_response = try JSONDecoder().decode(InvoiceItemResponse.self, from: data)
            SnowplowManager.shared?.track_item_details(itemId: self.item_response.invoiceitem, quantity: item_quantity)
            if(fromEditInvoice == true) {
                self.performSegue(withIdentifier: "back_to_edit_segue", sender: self)
            } else {
                if(self.fromEditInvoice == false) {
                    self.selected_item.append([self.product_name,self.product_description, self.product_price, item_quantity, self.item_response.invoiceitem, self.currency_symbol])
                    UserDefaults.standard.set(self.selected_item, forKey: "selected_item")
                    UserDefaults.standard.set(self.selected_item, forKey: "updated_qty_array")
                }
                self.performSegue(withIdentifier: "back_to_add_invoice_screen", sender: self)
            }
        }catch let decodingEror as DecodingError {
            
        }catch{
            
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "back_to_edit_segue" {
            let destViewController = segue.destination as! EditInvoiceController
            destViewController.invoice_id = invoice_id
            let backItem = UIBarButtonItem()
            backItem.title = "Cancel"
            navigationItem.backBarButtonItem = backItem
        }
        if segue.identifier == "add_new_invoice_item" {
            let destViewController = segue.destination as! NewInvoiceItemController
            let backItem = UIBarButtonItem()
            backItem.title = "Cancel"
            navigationItem.backBarButtonItem = backItem
            destViewController.invoice_id = invoice_id
            destViewController.fromEditInvoice = fromEditInvoice
        }
        if(segue.identifier == "clone_segue") {
            let destViewController = segue.destination as! NewInvoiceItemController
            destViewController.fromCloneItem = true
            destViewController.product_name = product_name
            destViewController.product_description = product_description
            destViewController.product_price = Double(product_price)
            let backItem = UIBarButtonItem()
            backItem.title = "Cancel"
            navigationItem.backBarButtonItem = backItem
        }
    }
    
    func handleErrorAddItem(error: Error) {
        print(error)
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(itemList.count <= 0) {
            return 320
        } /*else if(indexPath.row == 0) {
            return 25
        } */else {
            return UITableView.automaticDimension
        }
    }
    func getAddButton() -> UIBarButtonItem {
        //create a new button
        let button: UIButton = UIButton(type: UIButton.ButtonType.custom) as! UIButton
        //set image for button
        button.setImage(UIImage(named: "add_invoice.png"), for: .normal)
        //add function for button
        button.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: -10)
        button.addTarget(self, action: "addTapped", for: .touchUpInside)
        //set frame
        let barButton = UIBarButtonItem(customView: button)
        //assign button to navigationbar
        return barButton
    }
}

extension InvoiceItemController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.count > 0) {
            searching = true
            searchedItem = itemList.filter { (dataArray:[String]) -> Bool in
                return dataArray.filter({ (string) -> Bool in
                    return string.lowercased().contains(searchText.lowercased())
                }).count > 0
            }
            print(searchedItem)
            for searchId in searchedItem {
                searchIds.append(searchId[0])
            }
            //SnowplowManager.shared?.track_item_list(search: searchText, itemIds: searchIds)
            SnowplowManager.shared?.track_item_list(search: "", itemIds: searchIds)
            tableView.reloadData()
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        tableView.reloadData()
    }
}
class NoInvoiceItemListCell: UITableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: Common.table_content_inset)
    }
}

class InvoiceItemListEmptyCell: UITableViewCell {
    
}
class InvoiceRoundedItemCell: UITableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: Common.table_content_inset)
    }
}
class NoSearchInvoiceItemCell: UITableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: Common.table_content_inset)
    }
}
