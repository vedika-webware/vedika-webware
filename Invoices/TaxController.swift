//
//  TaxController.swift
//  WebwarePay
//
//  Created by Vedika on 16/12/21.
//

import UIKit
import SwiftyJSON
class TaxController: MyTableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    var taxList = [[String]]()
    var taxIdList = [String]()
    var searchedTax = [[String]]()
    var searching = false
    var from_add_invoice = false
    var from_edit_invoice = false
    var selected: String?
    var selected_id: String?
    var selected_name: String?
    var taxResponse: TaxResponse!
    var invoice_id = ""
    var is_snowplow_track = false
    var isListLoaded = false
    var tax_name = ""
    var tax_percent:Double = 0.00
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.listOfTax()
        searchBar.setDetaults()
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
        tableView.tableFooterView = UIView()
        navigationItem.rightBarButtonItem = getAddButton()
        //self.tableView.layer.cornerRadius = 10.0
        self.title = "Tax"
        //navigationItem.backButtonTitle = "< Back"
        let buttonIcon = UIImage(named: "back_with_arrow")
        self.navigationItem.leftBarButtonItem?.image = buttonIcon
    }
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func getAddButton() -> UIBarButtonItem {
        //create a new button
        let button: UIButton = UIButton(type: UIButton.ButtonType.custom) as! UIButton
        //set image for button
        button.setImage(UIImage(named: "add_invoice.png"), for: .normal)
        //add function for button
        button.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: -10)
        button.addTarget(self, action: "addTax", for: .touchUpInside)
        //set frame
        let barButton = UIBarButtonItem(customView: button)
        //assign button to navigationbar
        return barButton
    }
    @objc func reloadData(_ sender: AnyObject) {
        self.listOfTax()
    }
    @objc func addTax() {
        let alert = UIAlertController(title: "Add Tax", message: "Please enter tax details to Add", preferredStyle: .alert)
        alert.view.tintColor = Common.alert_tint_color
        alert.addTextField { (textFieldName) in
            textFieldName.placeholder = "Tax Name"
        }
        alert.addTextField { (textFieldTax) in
            textFieldTax.placeholder = "Percentage"
            //textFieldTax.delegate = self
            textFieldTax.addTarget(self, action: #selector(self.myTextFieldDidChange), for: .editingChanged)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak alert] (_) in
            
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textFieldName = alert?.textFields![0]
            let textFieldPercent = alert?.textFields![1]
            if(textFieldName?.text == "" || textFieldPercent?.text == "") {
                self.present(Common.showRequiredErrorAlert(title: Common.required_error_title, content: Common.required_error_text), animated: true)
            } else {
                self.tax_name = textFieldName!.text!
                self.tax_percent = Double((textFieldPercent?.text!)!) ?? 0.0
                if self.tax_percent != 0 {
                    self.saveTax(taxName: self.tax_name, percent: self.tax_percent)
                } else {
                    self.present(Common.showRequiredErrorAlert(title: Common.required_error_title, content: Common.required_error_text), animated: true)
                }
                    
                
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    @objc func myTextFieldDidChange(_ textField: UITextField) {
        if let taxString = textField.text?.TaxInputFormatting() {
            textField.text = taxString
        }
    }
    func saveTax(taxName: String, percent: Double) {
        var baseurl = (UserDefaults.standard.string(forKey: "api_base_url"))!
        let postData = [
            "taxRateInformation":[
                "display_name":taxName,
                "inclusive":"false",
                "percentage":percent,
                "active":"true"
            ]
         ] as [String : Any]
        self.serverApiCall(route: ("\(baseurl)/taxRates"), method: "POST", data: postData, responseHandler: handleResponseAdd, errorHandler: handleErrorAdd)
    }
    func handleResponseAdd(data: Data) {
        do{
            self.taxResponse = try JSONDecoder().decode(TaxResponse.self, from: data)
            if(self.taxResponse != nil) {
                SnowplowManager.shared?.track_tax_actions(id: self.taxResponse.taxrates, action: "add", name: tax_name, rate: String(tax_percent))
                self.present(showOkAlertWithHandler(title: "Tax Added", content: "Tax Added Successfully!"), animated: true)
            
                
                
                
                
                //self.listOfTax()
            }
        }catch let decodingEror as DecodingError {
            
        }catch{
            
        }
    }
    func handleErrorAdd(error: Error) {
        
    }
    func listOfTax() {
        
        var baseurl = (UserDefaults.standard.string(forKey: "api_base_url"))!
        let postData = ["":""] as [String : Any]
        self.serverApiCall(route: ("\(baseurl)/taxRates"), method: "GET", data: postData, responseHandler: handleResponse, errorHandler: handleError)
    }
    func handleResponse(data: Data) {
        do{
            isListLoaded = true
            taxList = [[String]]()
            taxIdList = [String]()
            let json = try JSON(data: data)
            if let data = json["taxrates"].array {
                //print(data)
                for tax in data {
                    var counter = 0
                    var taxObj = [String]()
                    var id = ""
                    var name = ""
                    var percentage = ""
                    var percentage_string = ""
                    for field in tax {
                        if(field.0 == "DisplayName") {
                            name = field.1.string ?? ""
                        }
                        if(field.0 == "Percentage") {
                            let percentage_int : Double = field.1.rawValue as! Double
                            var percent_string = String(percentage_int)
                            percentage = percent_string
                            percentage_string = "\(percentage)%"
                        }
                        if(field.0 == "Id") {
                            id = field.1.string ?? ""
                        }
                    }
                    taxObj.append(id)
                    taxObj.append(name)
                    taxObj.append(percentage_string)
                    taxObj.append(percentage)
                    if(taxObj != nil) {
                        taxList.append(taxObj)
                        taxIdList.append(id)
                    }
                }
                if(is_snowplow_track == false) {
                    SnowplowManager.shared?.track_tax_list(search: "", taxids: taxIdList)
                    is_snowplow_track = true
                }
            }
            tableView.refreshControl?.endRefreshing()
            tableView.reloadData()
            let indexPath = IndexPath(item: 0, section: 0)
            tableView.scrollToRow(at: indexPath, at: .none, animated: false)
        }catch let decodingEror as DecodingError {
            tableView.refreshControl?.endRefreshing()
        }catch{
            tableView.refreshControl?.endRefreshing()
        }
    }
    func handleError(error: Error) {
        tableView.refreshControl?.endRefreshing()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
    }
    func showOkAlertWithHandler(title: String, content: String) -> UIAlertController{
        let alert = UIAlertController(title: title, message: content, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: { [self]  action in
            redirect_back()
        })
        OKAction.setValue(UIColor.black, forKey: "titleTextColor")
        alert.addAction(OKAction)
        return alert
    }
    func redirect_back() {
        let selectedTax = String(self.tax_percent)
        selected = selectedTax
        selected_id = taxResponse.taxrates
        selected_name = self.tax_name
        print("selected \(selected)")
        print("selected_id \(selected_id)")
        print("selected_name \(selected_name)")
        UserDefaults.standard.set(selected, forKey: "selected_tax_percent")
        UserDefaults.standard.set(selected_id, forKey: "selected_tax_id")
        UserDefaults.standard.set(selected_name, forKey: "selected_tax_name")
        UserDefaults.standard.set(false, forKey: "is_tax_removed")
        if(from_add_invoice == true) {
            var storyboard: UIStoryboard = UIStoryboard(name: "Invoice", bundle: nil)
            var vc = storyboard.instantiateViewController(withIdentifier: "add_invoice_screen") as! AddInvoiceController
            vc.from_tax_add = true
            self.show(vc, sender: self)
        }
        if(from_edit_invoice == true) {
            var storyboard: UIStoryboard = UIStoryboard(name: "Invoice", bundle: nil)
            var vc = storyboard.instantiateViewController(withIdentifier: "edit_invoice_screen") as! EditInvoiceController
            vc.invoice_id = invoice_id
            vc.tax_name_updated = selected_name
            vc.tax_id_updated = selected_id
            vc.tax_percent_updated = Double(selected ?? "0.0")
            self.show(vc, sender: self)
        }
    }
}

extension TaxController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(taxList.count <= 0 && isListLoaded == true) {
            return 1
        } else {
            if searching {
                if(searchedTax.count <= 0) {
                    return 1
                } else {
                    return searchedTax.count
                }
            } else {
                return taxList.count
            }
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(taxList.count <= 0) {
            return 300
        } else {
            return UITableView.automaticDimension
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("taxList.count \(taxList.count) and isloaded \(isListLoaded)")
        if(taxList.count <= 0 && isListLoaded == true) {
            print("here in tax list")
            let cell = tableView.dequeueReusableCell(withIdentifier: "no_tax", for: indexPath) as! NoTaxCell
            cell.separatorInset = UIEdgeInsets(top: 0.0, left: cell.bounds.size.width, bottom: 0.0, right: 0.0);
            return cell
        } else {
            if(searching == true && searchedTax.count <= 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "no_tax_result", for: indexPath) as! NoSearchTaxCell
                cell.separatorInset = UIEdgeInsets(top: 0.0, left: cell.bounds.size.width, bottom: 0.0, right: 0.0);
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "tax_cell", for: indexPath) as! TaxCell
                if searching {
                    cell.tax_name.text = searchedTax[indexPath.row][1]
                    cell.tax_percent.text = searchedTax[indexPath.row][2]
                } else {
                    cell.tax_name.text = taxList[indexPath.row][1]
                    cell.tax_percent.text = taxList[indexPath.row][2]
                }
                if(from_add_invoice == true || from_edit_invoice == true) {
                    cell.edit_btn.isHidden = true
                } else {
                    cell.edit_btn.isHidden = false
                }
                cell.actionBlock = {
                    let alert = UIAlertController(title: "Update Tax", message: "Please enter tax details to update", preferredStyle: .alert)
                    alert.view.tintColor = Common.alert_tint_color
                    alert.addTextField { (textFieldName) in
                        textFieldName.placeholder = "Tax Name"
                        textFieldName.text = self.taxList[indexPath.row][1]
                    }
                    /*
                    alert.addTextField { (textFieldTax) in
                        textFieldTax.placeholder = "Percentage"
                        textFieldTax.text = self.taxList[indexPath.row][3]
                        textFieldTax.keyboardType = .numberPad
                    }
                     */
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                        let textFieldName = alert?.textFields![0]
                        let textFieldPercent = alert?.textFields![1]
                        self.tax_name = textFieldName!.text!
                        self.tax_percent = Double(textFieldPercent!.text!)!
                        var tax_id = self.taxList[indexPath.row][0]
                        self.updateTax(taxName: self.tax_name, taxId: tax_id)
                        alert?.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                    
                }
                if(indexPath.row == 0) {
                    //cell.contentView.roundCorners(corners: [.topLeft, .topRight], radius: 8.0)
                    if(taxList.count == 1 || searchedTax.count == 1) {
                        cell.contentView.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 8.0)
                        cell.separatorInset = UIEdgeInsets(top: 0.0, left: cell.bounds.size.width, bottom: 0.0, right: 0.0);
                    } else {
                        cell.contentView.roundCorners(corners: [.topLeft, .topRight], radius: 8.0)
                        cell.separatorInset = Common.separatorInset
                        //cell.corners = [.topLeft, .topRight]
                    }
                    
                } else if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
                    cell.contentView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 10.0)
                    cell.separatorInset = UIEdgeInsets(top: 0.0, left: cell.bounds.size.width, bottom: 0.0, right: 0.0);
                } else {
                    cell.separatorInset = Common.separatorInset
                    cell.contentView.roundCorners(corners: [], radius: 10.0)
                }
                return cell
            }
        }
    }
    func updateTax(taxName: String, taxId: String) {
        var baseurl = (UserDefaults.standard.string(forKey: "api_base_url"))!
        let postData = [
            "taxRateInformation":[
                "id": taxId,
                "display_name":taxName,
                "active":"true"
            ]
         ] as [String : Any]
        self.serverApiCall(route: ("\(baseurl)/taxRates"), method: "PUT", data: postData, responseHandler: handleResponseUpdate, errorHandler: handleErrorUpdate)
    }
    func handleResponseUpdate(data: Data) {
        //print(data.prettyPrintedJSONString)
        do{
            self.taxResponse = try JSONDecoder().decode(TaxResponse.self, from: data)
            if(self.taxResponse != nil) {
                SnowplowManager.shared?.track_tax_actions(id: self.taxResponse.taxrates, action: "edit", name: self.tax_name, rate: String(self.tax_percent))
                self.present(Common.showOkAlert(title: "Tax Updated", content: "Tax Updated Successfully!"), animated: true)
                self.listOfTax()
            }
        }catch let decodingEror as DecodingError {
            
        }catch{
            
        }
    }
    func handleErrorUpdate(error: Error) {
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searching {
            let selectedTax = searchedTax[indexPath.row][3]
            selected = selectedTax
            selected_id = searchedTax[indexPath.row][0]
            selected_name = searchedTax[indexPath.row][1]
        } else {
            let selectedTax = taxList[indexPath.row][3]
            selected = selectedTax
            selected_id = taxList[indexPath.row][0]
            selected_name = taxList[indexPath.row][1]
        }
        UserDefaults.standard.set(selected, forKey: "selected_tax_percent")
        UserDefaults.standard.set(selected_id, forKey: "selected_tax_id")
        UserDefaults.standard.set(selected_name, forKey: "selected_tax_name")
        UserDefaults.standard.set(false, forKey: "is_tax_removed")
        if(from_add_invoice == true) {
            var storyboard: UIStoryboard = UIStoryboard(name: "Invoice", bundle: nil)
            var vc = storyboard.instantiateViewController(withIdentifier: "add_invoice_screen") as! AddInvoiceController
            vc.from_tax_add = true
            self.show(vc, sender: self)
        }
        if(from_edit_invoice == true) {
            var storyboard: UIStoryboard = UIStoryboard(name: "Invoice", bundle: nil)
            var vc = storyboard.instantiateViewController(withIdentifier: "edit_invoice_screen") as! EditInvoiceController
            vc.invoice_id = invoice_id
            vc.tax_name_updated = selected_name
            vc.tax_id_updated = selected_id
            vc.tax_percent_updated = Double(selected ?? "0.0")
            self.show(vc, sender: self)
        }
    }
}

extension TaxController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.count > 0) {
            searchedTax = taxList.filter { (dataArray:[String]) -> Bool in
                return dataArray.filter({ (string) -> Bool in
                    return string.lowercased().contains(searchText.lowercased())
                }).count > 0
            }
            searching = true
            tableView.reloadData()
        } else {
            searching = false
            tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        tableView.reloadData()
    }
}
class TaxCell: UITableViewCell {
    var actionBlock: (() -> Void)? = nil
    @IBOutlet weak var tax_name: UILabel!
    @IBOutlet weak var tax_percent: UILabel!
    
    @IBOutlet weak var edit_btn: UIButton!
    
    @IBAction func edit_btn_click(_ sender: UIButton) {
        actionBlock?()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: Common.table_content_inset)
        
    }
}
class NoTaxCell: UITableViewCell {
    @IBOutlet weak var no_invoice_label: UILabel!
    @IBOutlet weak var small_text: UILabel!
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: Common.table_content_inset)
    }
}
class NoSearchTaxCell: UITableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: Common.table_content_inset)
    }
}
