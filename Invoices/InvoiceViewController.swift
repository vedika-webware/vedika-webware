//
//  InvoiceViewController.swift
//  WebwarePay
//
//  Created by Vedika on 20/10/21.
//

import UIKit
import SwiftyJSON
class InvoiceViewController: MyTableViewController {
    @IBOutlet weak var search_bar: UISearchBar!
    @IBOutlet weak var signUp: UIButton!
    @IBOutlet weak var invoice_title: UILabel!
    
    
    @IBOutlet weak var stripe_connect_view: UIView!
    var customerList = [[String]]()
    var searching = false
    var searchedInvoice = [[String]]()
    var customerNameList = [String]()
    @IBOutlet weak var invoiceTypeChange: UISegmentedControl!
    var selected: String?
    var invoiceList = [[String]]()
    var selectedListType = ""
    var selected_invoice_id = ""
    var selected_url = ""
    var back_from_strip = false
    var accountResponse = ""
    var account_exist = false
    @IBOutlet weak var invoiceTableView: UITableView!
    var invoice_response: InvoiceResponse!
    var invoice_id_to_delete = ""
    var subtotal_of_delete_item = ""
    var total_of_delete_item = ""
    let myRefreshControl = UIRefreshControl()
    var is_paid_invoice = false
    var is_data_loaded = false
    var search_placeholder = "Search by customer or invoice #"
    var from_notification = false
    var is_open_draft = false
    override func viewDidLoad() {
        super.viewDidLoad()
        clearBadgeserver()
        self.setNavigationDefaults()
        self.navigationItem.setHidesBackButton(true, animated: true)
        tableView.tableFooterView = UIView()
        search_bar.isHidden = true
        search_bar.layer.borderWidth = 0
        search_bar.backgroundImage = UIImage()
        stripe_connect_view.isHidden = true
        stripe_connect_view.heightAnchor.constraint(equalToConstant: 1000).isActive = true
        invoiceTypeChange.isHidden = true
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadData), for: UIControl.Event.valueChanged)
        refreshControl.layoutIfNeeded()
        tableView.refreshControl = refreshControl
        
    }
    override func viewDidAppear(_ animated: Bool) {
        self.setNavigationDefaults()
        clearBadgelocal()
        account_exist = true
        //tableView.tableHeaderView?.backgroundColor = Common.navigation_back_color
        invoice_title.isHidden = false
        self.navigationItem.rightBarButtonItem = getAddButton()
        tableView.separatorColor = UIColor.clear
        
        self.invoiceTypeChange.isHidden = false
        search_bar.isHidden = false
        searching = false
        //invoiceList.removeAll()
        search_bar.setDetaults()
        search_bar.placeholder = search_placeholder
        stripe_connect_view.isHidden = true
        if(from_notification == true) {
            self.invoiceTypeChange.selectedSegmentIndex = 2
            is_data_loaded = false
            selectedListType = "paid"
            getInvoiceList(listtype: "paid")
            from_notification = false
        } else {
            self.invoiceTypeChange.selectedSegmentIndex = 0
            selectedListType = "open"
            getInvoiceList(listtype: "open")
        }
        //self.tabBarController?.selectedIndex = 0
        self.search_bar.delegate = self
        //self.navigationItem.title = "Invoices"
           
    }
    func clearBadgelocal(){
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    func clearBadgeserver(){
        UIApplication.shared.applicationIconBadgeNumber = 0
        var email =  (UserDefaults.standard.string(forKey: "user_email"))!
        print("/badgeclear/\(email)")
        self.serverDatawareApiCall(route: ("badgeclear/\(email)"), method: "GET", data: "", responseHandler: handleBadgeResponse, errorHandler: handleBadgeError)
    }
    func handleBadgeResponse(data: Data) {
        do{
            print("badge response \(data.prettyPrintedJSONString)")
        }catch let decodingEror as DecodingError {
        }catch{
        }
    }
    func handleBadgeError(error: Error) {

    }
    func getAccountStatus() {
        var baseurl = (UserDefaults.standard.string(forKey: "api_base_url"))!
        let postData = ["":""] as [String : Any]
        //print("\(baseurl)/account")
        self.serverApiCall(route: ("\(baseurl)/account?source=app"), method: "GET", data: postData, responseHandler: handleAccountResponse, errorHandler: handleAccountError, showSpiner: true)
    }
    func handleAccountResponse(data: Data) {
        do{
            let json = try JSON(data: data)
            //print(json)
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
                    account_exist = false
                    self.navigationItem.title = "Sign Up Stripe"
                    UserDefaults.standard.set(false, forKey: "stripe_account_exist")
                } else if let account_status = json["account"].bool {
                    print("here in get account response")
                    //self.setNavigationDefaults()
                    if(account_status == true) {
                        UserDefaults.standard.set(1, forKey: "is_stripe_connected")
                        let dc : UITabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tab_bar") as! MyTabBarController
                        self.present(dc, animated: true, completion: nil)
                        account_exist = true
                        UserDefaults.standard.set(true, forKey: "stripe_account_exist")
                        if(back_from_strip == true) {
                            Common.showOkAlert(title: "Connected", content: "You have successfully connect your stripe account.")
                        }
                    } else {
                        self.setNavigationToWhite()
                        account_exist = false
                        UserDefaults.standard.set(false, forKey: "stripe_account_exist")
                    }
                }
            }
            if(account_exist == true) {
                invoice_title.isHidden = false
                self.navigationItem.rightBarButtonItem = getAddButton()
                tableView.separatorColor = UIColor.clear
                self.invoiceTypeChange.isHidden = false
                search_bar.isHidden = false
                search_bar.placeholder = "Search by customer or invoice #"
                //signUp.isHidden = true
                stripe_connect_view.isHidden = true
                selectedListType = "open"
                getInvoiceList(listtype: "open")
                //self.tabBarController?.selectedIndex = 0
                self.search_bar.delegate = self
                //self.navigationItem.title = "Invoices"
                //var refreshControl = UIRefreshControl()
                //refreshControl.addTarget(self, action: #selector(reloadData), for: UIControl.Event.valueChanged)
                //tableView.refreshControl = refreshControl
            } else {
                invoice_title.isHidden = true
                self.navigationItem.title = "Sign Up Stripe"
                signUp.layer.cornerRadius = 5
                //signUp.isHidden = false
                stripe_connect_view.isHidden = false
                self.invoiceTypeChange.isHidden = true
                search_bar.isHidden = true
            }
            
            
        }catch let decodingEror as DecodingError {
        }catch{
        }
    }
    func handleAccountError(error: Error) {
    }
    
    @IBAction func sign_up_tap(_ sender: Any) {
        //{
        //    "account": true
        //}
        
        //{
        //    "account": "https://connect.stripe.com/setup/s/iWOdl0ylGfFZ"
        //}
        //selected_url = "https://dashboard.stripe.com/register"
        self.performSegue(withIdentifier: "create_stripe_account", sender: self)
    }
    @objc func reloadData(_ sender: AnyObject) {
        print("account exist \(account_exist)")
        if(account_exist == true) {
            self.getInvoiceList(listtype: selectedListType)
        } else {
            getAccountStatus()
        }
        //getAccountStatus()
    }
    @objc func reloadAccount(_ sender: AnyObject) {
        getAccountStatus()
    }
    @objc func addTapped() {
        if(Common.checkIfDraftSaved()) {
            let alert = UIAlertController(title: "You have a saved Invoice", message: "Do you want to make changes in the saved invoice?", preferredStyle: .alert)

            alert.view.tintColor = Common.alert_tint_color
            alert.addAction(UIAlertAction(title: "Yes, Edit the saved Invoice.", style: .default, handler: { [weak alert] (_) in
                self.is_open_draft = true
                self.performSegue(withIdentifier: "add_invoice_segue", sender: Self.self)
            }))
            alert.addAction(UIAlertAction(title: "No, Create a New Invoice.", style: .default, handler: { [weak alert] (_) in
                self.is_open_draft = false
                Common.clearDraftValues()
                self.performSegue(withIdentifier: "add_invoice_segue", sender: Self.self)
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.is_open_draft = false
            self.performSegue(withIdentifier: "add_invoice_segue", sender: Self.self)
        }
        
    }
    @IBAction func segment_changed(_ sender: UISegmentedControl) {
        switch invoiceTypeChange.selectedSegmentIndex
        {
        case 0:
            selectedListType = "open"
            getInvoiceList(listtype: "open")
            search_placeholder = "Search by customer or invoice #"
            search_bar.searchTextField.placeholder = search_placeholder
            break
        case 1:
            selectedListType = "draft"
            getInvoiceList(listtype: "draft")
            search_placeholder = "Search by customer"
            search_bar.searchTextField.placeholder = search_placeholder
            break
        case 2:
            selectedListType = "paid"
            getInvoiceList(listtype: "paid")
            search_placeholder = "Search by customer or invoice #"
            search_bar.searchTextField.placeholder = search_placeholder
            break
        default:
            selectedListType = "open"
            getInvoiceList(listtype: "open")
            search_placeholder = "Search by customer or invoice #"
            search_bar.searchTextField.placeholder = search_placeholder
            break
        }
    }
    func getInvoiceList(listtype: String) {
        search_bar.setDetaults()
        searchedInvoice.removeAll()
        searching = false
        
        Common.clearSavedValues()
        is_data_loaded = false
        var baseurl = (UserDefaults.standard.string(forKey: "api_base_url"))!
        let postData = ["":""] as [String : Any]
        
        self.serverApiCall(route: ("\(baseurl)/invoice?invoicelist=1&status=\(listtype)"), method: "GET", data: postData, responseHandler: handleResponse, errorHandler: handleError, showSpiner: true)
    
    }
    func handleResponse(data: Data) {
        invoiceList.removeAll()
        do{
            let json = try JSON(data: data)
            print(json)
            var invoiceIds = [String]()
            if let data = json["invoice"].array {
                    for invoice in data {
                        var invoiceObj = [String]()
                        var id = ""
                        var name = ""
                        var posonumber = ""
                        var number = ""
                        var amount_due = ""
                        var due_date = ""
                        var currency = ""
                        var created = ""
                        var pdf_link = ""
                        for field in invoice {
                            
                            /*if(field.0 == "CustomerEmail") {
                                var name_str = field.1.string ?? ""
                                var name_part = name_str.components(separatedBy: "@")
                                name = name_str
                            }*/
                            if(field.0 == "CustomerName") {
                                name = field.1.string ?? ""
                            }
                            if(field.0 == "CustomFields") {
                                if let custom_fields = field.1.array {
                                    for custom_field in custom_fields {
                                        for c_field in custom_field {
                                            if(c_field.0 == "value") {
                                                posonumber = c_field.1.rawString() ?? ""
                                            }
                                        }
                                    }
                                }
                            }
                            if(field.0 == "Number") {
                                number = field.1.string ?? ""
                            }
                            if(field.0 == "CurrencyPrefix") {
                                currency = field.1.string ?? ""
                                currency = String(htmlEncodedString: currency) ?? ""
                            }
                            if(field.0 == "AmountDue") {
                                //let pricestring = String((Double(round(1000 * price) / 1000))/100)
                                let amount_total : Double = field.1.rawValue as! Double
                                let amount_string = String(Double(Common.roundTwoDecimal(val: amount_total) / 100))
                                var amount_due_str = String(amount_string)
                                amount_due = amount_due_str
                            }
                            if(field.0 == "DueDate") {
                                let duedate_saved = field.1.string ?? ""
                                due_date = "\(convertDateFormater(duedate_saved))"
                            }
                            if(field.0 == "Id") {
                                id = field.1.string ?? ""
                            }
                            if(field.0 == "Created") {
                                let created_date_saved = field.1.string ?? ""
                                created = convertDateFormater(created_date_saved)
                            }
                            if(field.0 == "InvoicePdf") {
                                pdf_link = field.1.string ?? ""
                            }
                        }
                        //invoiceObj.append(String(name.prefix(10)))
                        invoiceObj.append(String(name))
                        invoiceObj.append(number)
                        invoiceObj.append("\(currency)\(amount_due)")
                        invoiceObj.append(String(due_date.prefix(12)))
                        invoiceObj.append(id)
                        invoiceObj.append(created)
                        invoiceObj.append(pdf_link)
                        invoiceObj.append(posonumber)
                        
                        invoiceIds.append(id)
                        
                        if(invoiceObj != nil) {
                            invoiceList.append(invoiceObj)
                        }
                    }
            }
            is_data_loaded = true
            //print("after load \(invoiceList)")
            SnowplowManager.shared?.track_invoice_list(type: selectedListType, invoiceids: invoiceIds)
            tableView.reloadData()
            tableView.refreshControl?.endRefreshing()
            
        }catch let decodingEror as DecodingError {
            is_data_loaded = true
            print("in decoding error")
            tableView.refreshControl?.endRefreshing()
        }catch{
            print("in catch error")
            is_data_loaded = true
            tableView.refreshControl?.endRefreshing()
        }
    }
    func handleError(error: Error) {
        print("in handle error")
        is_data_loaded = true
        tableView.refreshControl?.endRefreshing()
    }
    func convertDateFormater(_ date: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM, dd yyyy HH:mm:ss"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return  dateFormatter.string(from: date!)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "edit_invoice_segue" {
            let destViewController = segue.destination as! EditInvoiceController
            destViewController.invoice_id = selected_invoice_id
        }
        if segue.identifier == "preview_invoice" {
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
            let destViewController = segue.destination as! PreViewController
            destViewController.from_paid_invoice = is_paid_invoice
            destViewController.invoice_id = selected_invoice_id
        }
        if segue.identifier == "view_pdf_segue" {
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
            let destViewController = segue.destination as! WebviewController
            destViewController.urlToOpen = selected_url
        }
        if segue.identifier == "create_stripe_account" {
            //let backItem = UIBarButtonItem()
            //backItem.title = "Back"
            //navigationItem.backBarButtonItem = backItem
            let destViewController = segue.destination as! CreateStripeAccountController
            destViewController.urlToOpen = selected_url
        }
        if(segue.identifier == "add_invoice_segue") {
            let destViewController = segue.destination as! AddInvoiceController
            destViewController.is_open_draft = is_open_draft
        }
        
    }
    
    func getAddButton() -> UIBarButtonItem {
        //create a new button
        let button: UIButton = UIButton(type: UIButton.ButtonType.custom) as! UIButton
        //set image for button
        button.setImage(UIImage(named: "add_invoice.png"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: -10)
        //add function for button
        button.addTarget(self, action: "addTapped", for: .touchUpInside)
        //set frame
        let barButton = UIBarButtonItem(customView: button)
        //assign button to navigationbar
        return barButton
    }
}
class InvoiceListItemCell: UITableViewCell {
    var actionBlock: (() -> Void)? = nil
    var sendInvoiceBlock: (() -> Void)? = nil
    var deleteInvoiceBlock: (() -> Void)? = nil
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    
    @IBOutlet weak var send_btn: UIButton!
    @IBOutlet weak var edit_click: UIButton!
    
    @IBOutlet weak var card_view: UIView!
    @IBOutlet weak var delete_btn: UIButton!
    
    @IBAction func send_click(_ sender: Any) {
        sendInvoiceBlock?()
    }
    
    @IBAction func edit_click(_ sender: Any) {
        actionBlock?()
    }
    
    @IBAction func delete_click(_ sender: Any) {
        print("in delete click")
        deleteInvoiceBlock?()
    }
}
class NoInvoiceItemCell: UITableViewCell {
    @IBOutlet weak var no_invoice_label: UILabel!
    @IBOutlet weak var small_text: UILabel!
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: Common.table_content_inset)
    }
}

extension InvoiceViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(invoiceList.count <= 0 && account_exist == true) {
            return 1
        } else {
            search_bar.isHidden = false
            if searching {
                if(searchedInvoice.count <= 0) {
                    return 1
                } else {
                    return searchedInvoice.count
                }
            } else {
                return invoiceList.count
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print("invoiceList.count \(invoiceList.count)")
        //let cell = UITableViewCell()
        if(invoiceList.count <= 0 && account_exist == true && is_data_loaded == true) {
        //if(invoiceList.count <= 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "no_invoice_item", for: indexPath) as! NoInvoiceItemCell
            switch selectedListType
            {
            case "open":
                cell.no_invoice_label.text = "You have no unpaid invoices"
                cell.small_text.text = "Sent, viewed, partially paid or overdue invoices will appear here"
                break
            case "draft":
                cell.no_invoice_label.text = "You have no draft invoices"
                cell.small_text.text = "Draft invoices will appear here"
                break
            case "paid":
                cell.no_invoice_label.text = "You have no paid invoices"
                cell.small_text.text = "Paid invoices will appear here"
                break
            default:
                cell.no_invoice_label.text = "You have no unpaid invoices"
                cell.small_text.text = "Sent, viewed, partially paid or overdue invoices will appear here"
                break
            }
            cell.contentView.dropShadow()
            return cell
        } else {
            if(searching == true && searchedInvoice.count <= 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "no_invoice_result", for: indexPath) as! NoSearchInvoiceCell
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "invoice_item", for: indexPath) as! InvoiceListItemCell
                //cell.card_view.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 8.0)
                cell.card_view.dropShadow()
                let offset = CGSize(width: -1, height: 1)

                //cell.card_view.addShadow(color: .black,radius: 3, offset: offset)
                var invoice_id = ""
                if searching {
                    //print(searchedInvoice)
                    if(searchedInvoice.indices.contains(indexPath.row)) {
                        cell.label1.text = searchedInvoice[indexPath.row][0]
                        cell.label2.text = searchedInvoice[indexPath.row][7]
                        if(selectedListType == "draft") {
                            //cell.label2.text = searchedInvoice[indexPath.row][5]
                            cell.delete_btn.isHidden = false
                        } else {
                            //cell.label2.text = searchedInvoice[indexPath.row][1]
                            cell.delete_btn.isHidden = true
                        }
                        if(selectedListType == "paid") {
                            cell.label3.text = searchedInvoice[indexPath.row][2]
                        } else {
                            cell.label3.text = searchedInvoice[indexPath.row][2]
                        }
                        
                        cell.label4.text = searchedInvoice[indexPath.row][3]
                        invoice_id = searchedInvoice[indexPath.row][4]
                    }
                } else {
                    if(invoiceList.indices.contains(indexPath.row)) {
                        cell.label1.text = invoiceList[indexPath.row][0]
                        cell.label2.text = invoiceList[indexPath.row][7]
                        if(selectedListType == "draft") {
                            //cell.label2.text = invoiceList[indexPath.row][5]
                            cell.delete_btn.isHidden = false
                        } else {
                            //cell.label2.text = invoiceList[indexPath.row][1]
                            cell.delete_btn.isHidden = true
                        }
                        if(selectedListType == "paid") {
                            cell.label3.text = invoiceList[indexPath.row][2]
                        } else {
                            cell.label3.text = invoiceList[indexPath.row][2]
                        }
                        cell.label4.text = invoiceList[indexPath.row][3]
                        invoice_id = invoiceList[indexPath.row][4]
                    }
                }
                //cell.send_btn.backgroundColor = .clear
                cell.send_btn.layer.cornerRadius = 10
                cell.send_btn.layer.borderWidth = 1
                cell.send_btn.layer.borderColor = UIColor(red: 0.24, green: 0.24, blue: 0.26, alpha: 1.00).cgColor
                cell.actionBlock = {
                        if self.searching {
                            if(self.searchedInvoice.indices.contains(indexPath.row)) {
                                self.selected_invoice_id = self.searchedInvoice[indexPath.row][4]
                                self.performSegue(withIdentifier: "edit_invoice_segue", sender:  Self.self)
                            }
                        } else {
                            if(self.invoiceList.indices.contains(indexPath.row)) {
                                self.selected_invoice_id = self.invoiceList[indexPath.row][4]
                                self.performSegue(withIdentifier: "edit_invoice_segue", sender:  Self.self)
                            }
                        }
                        
                }
                cell.sendInvoiceBlock = {
                    if(self.selectedListType == "open" || self.selectedListType == "paid") {
                        if self.searching {
                            if(self.searchedInvoice.indices.contains(indexPath.row)) {
                                self.selected_url = self.searchedInvoice[indexPath.row][6]
                                self.selected_invoice_id = self.searchedInvoice[indexPath.row][4]
                                
                                //self.performSegue(withIdentifier: "view_pdf_segue", sender: self)
                                if(self.selectedListType == "open") {
                                    self.performSegue(withIdentifier: "preview_invoice", sender: self)
                                }
                            }
                        } else {
                            if(self.invoiceList.indices.contains(indexPath.row)) {
                                self.selected_url = self.invoiceList[indexPath.row][6]
                                self.selected_invoice_id = self.invoiceList[indexPath.row][4]
                                
                                //self.performSegue(withIdentifier: "view_pdf_segue", sender: self)
                                if(self.selectedListType == "open") {
                                    self.performSegue(withIdentifier: "preview_invoice", sender: self)
                                }
                                
                            }
                        }
                        
                    } else {
                        self.invoiceSend(invoice_id: invoice_id)
                    }
                }
                cell.deleteInvoiceBlock = {
                    if self.searching {
                        if(self.searchedInvoice.indices.contains(indexPath.row)) {
                            self.selected_invoice_id = self.searchedInvoice[indexPath.row][4]
                            self.subtotal_of_delete_item = self.searchedInvoice[indexPath.row][2]
                            let alert = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this invoice.", preferredStyle: .alert)
                            alert.view.tintColor = Common.alert_tint_color
                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak alert] (_) in
                            }))
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                                self.invoiceDelete(invoice_id: invoice_id)
                                tableView.reloadData()
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                    } else {
                        if(self.invoiceList.indices.contains(indexPath.row)) {
                            self.selected_invoice_id = self.invoiceList[indexPath.row][4]
                            self.subtotal_of_delete_item = self.invoiceList[indexPath.row][2]
                            let alert = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this invoice.", preferredStyle: .alert)
                            alert.view.tintColor = Common.alert_tint_color
                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak alert] (_) in
                            }))
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                                self.invoiceDelete(invoice_id: invoice_id)
                                tableView.reloadData()
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                    
                }
                if(selectedListType == "open") {
                    cell.edit_click.isHidden = true
                    cell.send_btn.setTitle("Open", for: .normal)
                } else if(selectedListType == "paid") {
                    cell.send_btn.setTitle("Paid", for: .normal)
                    cell.edit_click.isHidden = true
                } else {
                    cell.send_btn.setTitle("Draft", for: .normal)
                    cell.edit_click.isHidden = false
                }
                
                
                //let myCustomSelectionColorView = UIView()
                //cell.selectedBackgroundView = myCustomSelectionColorView
                return cell
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if(invoiceList.count > 0) {
            if(searching) {
                if(searchedInvoice.indices.contains(indexPath.row)) {
                    selected_invoice_id = searchedInvoice[indexPath.row][4]
                }
            } else {
                if(invoiceList.indices.contains(indexPath.row)) {
                    selected_invoice_id = invoiceList[indexPath.row][4]
                }
            }
            if(selected_invoice_id != "") {
                //if(selectedListType == "open" || selectedListType == "paid") {
                if(selectedListType == "open") {
                    self.performSegue(withIdentifier: "preview_invoice", sender: self)
                } else if(selectedListType == "paid") {
                    is_paid_invoice = true
                    self.performSegue(withIdentifier: "preview_invoice", sender:  Self.self)
                } else if(selectedListType == "draft") {
                    self.performSegue(withIdentifier: "edit_invoice_segue", sender:  Self.self)
                }
            }
        //performSegue(withIdentifier: "add_item_segue", sender: Self.self)
        }
    }
    func invoiceSend(invoice_id : String) {
        let postData = [
            "invoiceInformation": [
                 "invoiceId" : invoice_id,
                 "sendInvoice":"1"
             ]
         ] as [String : Any]
        var baseurl = (UserDefaults.standard.string(forKey: "api_base_url"))!
        self.serverApiCall(route: ("\(baseurl)/invoice"), method: "PUT" , data: postData, responseHandler: handleResponseSend, errorHandler: handleErrorSend)
    }
    func handleResponseSend(data: Data) {
        //print("in invoice send response \(data.prettyPrintedJSONString)")
        do{
            self.invoice_response = try JSONDecoder().decode(InvoiceResponse.self, from: data)
            if(invoice_response.invoice != nil) {
                self.present(Common.showOkAlert(title: "Invoive Send", content: "Your invoice sent to customer."), animated: true)
                getInvoiceList(listtype: selectedListType)
            } else {
                self.present(Common.showErrorAlert(title: Common.add_error_title, content: Common.add_error_text), animated: true)
            }
            
        }catch let decodingEror as DecodingError {
            self.present(Common.showErrorAlert(title: Common.add_error_title, content: Common.add_error_text), animated: true)
            //print("in decoding error \(decodingEror)")
        }catch{
        }
    }
    func handleErrorSend(error: Error) {
        print(error)
        self.present(Common.showErrorAlert(title: Common.add_error_title, content: Common.add_error_text), animated: true)
    }
    func invoiceDelete(invoice_id : String) {
        invoice_id_to_delete = invoice_id
        let postData = [
            "invoiceId": invoice_id
         ]
        var baseurl = (UserDefaults.standard.string(forKey: "api_base_url"))!
        self.serverApiCall(route: ("\(baseurl)/invoice"), method: "DELETE" , data: postData, responseHandler: handleResponseDelete, errorHandler: handleErrorDelete)
    }
    func handleResponseDelete(data: Data) {
        SnowplowManager.shared?.track_invoice_action(id: invoice_id_to_delete, action: "delete", status: "draft", purchaseOrder: "", invoiceDate: "", dueDate: "", subTotal: subtotal_of_delete_item, totalTax: "", total: subtotal_of_delete_item)
        self.present(Common.showOkAlert(title: "Invoice Deleted", content: "Your invoice is deleted."), animated: true)
        getInvoiceList(listtype: selectedListType)
    }
    func handleErrorDelete(error: Error) {
        print(error)
        self.present(Common.showErrorAlert(title: Common.add_error_title, content: Common.add_error_text), animated: true)
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(invoiceList.count <= 0 && is_data_loaded == true) {
            return 320
        } else {
            return UITableView.automaticDimension
        }
    }
}

extension InvoiceViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.count > 0) {
            searching = true
            searchedInvoice = invoiceList.filter { (dataArray:[String]) -> Bool in
                return dataArray.filter({ (string) -> Bool in
                    //print("string compare \(string.lowercased()) == \(searchText.lowercased())")
                    return string.lowercased().contains(searchText.lowercased())
                }).count > 0
            }
            //print(searchedInvoice)
            tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        tableView.reloadData()
    }
}

class NoSearchInvoiceCell: UITableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: Common.table_content_inset)
    }
}
