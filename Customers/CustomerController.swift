//
//  CustomerController.swift
//  WebwarePay
//
//  Created by Vedika on 29/10/21.
//

import UIKit
import SwiftyJSON
class CustomerController: MyTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var customerList = [[String]]()
    var searchedCustomer = [[String]]()
    var customerIds = [String]()
    var searching = false
    var from_add_invoice = false
    var from_edit_invoice = false
    var invoice_id = ""
    var selected: String?
    var selected_id: String?
    var selected_name: String?
    var selected_fname: String?
    var selected_country: String?
    var selected_state: String?
    var selected_city: String?
    var selected_line1: String?
    var selected_line2: String?
    var selected_postal: String?
    var is_data_loaded = false
    @IBOutlet weak var header_view: UIView!
    var carSectionTitles = [String]()
    var customer_response: CustomerResponse!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.tableHeaderView = header_view
        searchBar.setDetaults()
        //addDoneToolBarToKeyboardSearch(textView: searchBar.searchTextField)
        searchBar.placeholder = "Search by name or email"
        self.searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
        //searchBar.backgroundColor = UIColor.white
        navigationItem.rightBarButtonItem = getAddButton()
        navigationItem.leftBarButtonItem = UIBarButtonItem()
        var refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadData), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refreshControl
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        tableView.separatorColor = Common.separatorColor
        tableView.separatorInset = Common.separatorInset
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        //self.listOfCustomers()
        
        self.setNavigationDefaults()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.setNavigationDefaults()
        searching = false
        searchedCustomer.removeAll()
        searchBar.setDetaults()
        searchBar.placeholder = "Search by customer name or email"
        self.listOfCustomers()
        //tableView.reloadData()
    }
    
    @objc func reloadData(_ sender: AnyObject) {
        self.listOfCustomers()
    }
    @objc func addTapped() {
        performSegue(withIdentifier: "add_customer_segue", sender: Self.self)
    }
    func listOfCustomers() {
        var baseurl = (UserDefaults.standard.string(forKey: "api_base_url"))!
        let postData = ["":""] as [String : Any]
        self.serverApiCall(route: ("\(baseurl)/customer?customerList=1"), method: "GET", data: postData, responseHandler: handleResponse, errorHandler: handleError)
    }
    func handleResponse(data: Data) {
        do{
            is_data_loaded = true
            customerList = [[String]]()
            let json = try JSON(data: data)
            if let columns = json["customer"]["COLUMNS"].array {
                if let data = json["customer"]["DATA"].array {
                    for customer in data {
                        var counter = 0
                        var customerObj = [String]()
                        var id = ""
                        var name = ""
                        var lname = ""
                        var email = ""
                        var country = ""
                        var state = ""
                        var city = ""
                        var line1 = ""
                        var line2 = ""
                        var postal = ""
                        for field in customer {
                            if(columns[counter] == "UNIQUE_ID") {
                                if let unique_id = field.1.int {
                                    id = String(unique_id) ?? "" //"cus_L6ktBN4DYZwewT"
                                }
                            }
                            if(columns[counter] == "FIRST_NAME") {
                                name = field.1.string?.capitalizingFirstLetter() ?? ""
                            }
                            if(columns[counter] == "LAST_NAME") {
                                lname = field.1.string?.capitalizingFirstLetter() ?? ""
                            }
                            if(columns[counter] == "PRIMARY_EMAIL") {
                                email = field.1.string ?? ""
                            }
                            if(columns[counter] == "BILLING_COUNTRY") {
                                country = field.1.string ?? ""
                            }
                            if(columns[counter] == "BILLING_REGION") {
                                state = field.1.string ?? ""
                            }
                            if(columns[counter] == "WORK_CITY") {
                                city = field.1.string ?? ""
                            }
                            if(columns[counter] == "WORK_LINE_1") {
                                line1 = field.1.string ?? ""
                            }
                            if(columns[counter] == "WORK_LINE_2") {
                                line2 = field.1.string ?? ""
                            }
                            if(columns[counter] == "WORK_LINE_2") {
                                line2 = field.1.string ?? ""
                            }
                            if(columns[counter] == "HOME_POSTAL_CODE") {
                                postal = field.1.string ?? ""
                            }
                            
                            counter = counter + 1;
                            
                        }
                        customerObj.append(id)
                        customerObj.append(name)
                        customerObj.append(email)
                        customerObj.append(country)
                        customerObj.append(state)
                        customerObj.append(city)
                        customerObj.append(line1)
                        customerObj.append(line2)
                        customerObj.append(postal)
                        customerObj.append(lname)
                        
                        let carKey = String(name.prefix(1))
                        carSectionTitles.append(carKey)
                        if(customerObj != nil) {
                            if(email != "") {
                                customerList.append(customerObj)
                                customerIds.append("\"\(id)\"")
                            }
                            //customerList.append(customerObj)
                        }
                        //print(customerObj)
                        //break
                    }
                    //print(customerList)
                }
                carSectionTitles = carSectionTitles.sorted(by: { $0 < $1 })
                SnowplowManager.shared?.track_customer_list(search: "null", customerIds: customerIds)
            }
            tableView.refreshControl?.endRefreshing()
            tableView.reloadData()
            let indexPath = IndexPath(item: 0, section: 0)
            tableView.scrollToRow(at: indexPath, at: .none, animated: false)
            //let indexPath = IndexPath(item: 0, section: 0)
            //tableView.reloadRows(at: [indexPath], with: .top)
        }catch let decodingEror as DecodingError {
            tableView.refreshControl?.endRefreshing()
            tableView.reloadData()
        }catch{
            tableView.refreshControl?.endRefreshing()
            tableView.reloadData()
        }
    }
    func handleError(error: Error) {
        tableView.refreshControl?.endRefreshing()
        tableView.reloadData()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "edit_customer_segue" {
            let destViewController = segue.destination as! EditCustomerController
            destViewController.email = selected!
        }
        if segue.identifier == "add_customer_segue" {
            let destViewController = segue.destination as! AddCustomerViewController
            destViewController.from_add_invoice = from_add_invoice
            let backItem = UIBarButtonItem()
            backItem.title = "Cancel"
            navigationItem.backBarButtonItem = backItem
        }
        
        
    }
}

extension CustomerController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(customerList.count <= 0 && is_data_loaded == true) {
            return 1
        }
        if searching {
            if(searchedCustomer.count <= 0) {
                return 1
            } else {
                return searchedCustomer.count
            }
        } else {
            return customerList.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(customerList.count <= 0 && is_data_loaded == true) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "no_customer", for: indexPath) as! NoCustomerCell
            cell.separatorInset = UIEdgeInsets(top: 0.0, left: cell.bounds.size.width, bottom: 0.0, right: 0.0);
            cell.contentView.dropShadow()
            return cell;
        } /*else if(indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "empty_cell", for: indexPath) as! CustomerListEmptyCell
            cell.separatorInset = UIEdgeInsets(top: 0.0, left: cell.bounds.size.width, bottom: 0.0, right: 0.0);
            return cell;
            
        } */else {
            if(searching == true && searchedCustomer.count <= 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "no_search_customer", for: indexPath) as! NoSearchCustomerCell
                cell.separatorInset = UIEdgeInsets(top: 0.0, left: cell.bounds.size.width, bottom: 0.0, right: 0.0);
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "customer_info", for: indexPath) as! CustomerCell
                cell.layoutSubviews()
                var list_count = 0
                if searching {
                    if(searchedCustomer.indices.contains(indexPath.row)) {
                        //cell.label_link.text = "first"
                        cell.customer_name.text = "\((searchedCustomer[indexPath.row][1])) \( (searchedCustomer[indexPath.row][9]))"
                        cell.customer_email.text = searchedCustomer[indexPath.row][2]
                        //cell.textLabel?.text = searchedCustomer[indexPath.row][1]
                        list_count = searchedCustomer.count
                    }
                } else {
                    if(customerList.indices.contains(indexPath.row)) {
                        //cell.label_link.text = "first"
                        cell.customer_name.text = "\((customerList[indexPath.row][1])) \( (customerList[indexPath.row][9]))"
                        cell.customer_email.text = customerList[indexPath.row][2]
                        //cell.textLabel?.text = customerList[indexPath.row][1]
                        list_count = customerList.count
                        
                    }
                }
                if indexPath.row == 0 {
                    if(customerList.count == 1 || searchedCustomer.count == 1) {
                        cell.contentView.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10.0)
                        cell.separatorInset = UIEdgeInsets(top: 0.0, left: cell.bounds.size.width, bottom: 0.0, right: 0.0);
                    } else {
                        cell.contentView.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
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
    //override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        //return carSectionTitles
    //}
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(from_add_invoice)
        //print(from_edit_invoice)
        //if(indexPath.row != 0) {
            if searching {
                let selectedCustomer = searchedCustomer[indexPath.row][2]
                selected = selectedCustomer
                selected_id = searchedCustomer[indexPath.row][0]
                selected_name = "\(searchedCustomer[indexPath.row][1]) \(searchedCustomer[indexPath.row][9])"
                
                selected_country = searchedCustomer[indexPath.row][3]
                selected_state = searchedCustomer[indexPath.row][4]
                selected_city = searchedCustomer[indexPath.row][5]
                selected_line1 = searchedCustomer[indexPath.row][6]
                selected_line2 = searchedCustomer[indexPath.row][7]
                selected_postal = searchedCustomer[indexPath.row][8]
                selected_fname = searchedCustomer[indexPath.row][1]
            } else {
                let selectedCustomer = customerList[indexPath.row][2]
                selected = selectedCustomer
                
                selected_id = customerList[indexPath.row][0]
                selected_name = "\(customerList[indexPath.row][1]) \(customerList[indexPath.row][9])"
                
                selected_country = customerList[indexPath.row][3]
                selected_state = customerList[indexPath.row][4]
                selected_city = customerList[indexPath.row][5]
                selected_line1 = customerList[indexPath.row][6]
                selected_line2 = customerList[indexPath.row][7]
                selected_postal = customerList[indexPath.row][8]
                selected_fname = customerList[indexPath.row][1]
                
            }
            
            if(self.from_add_invoice == true || self.from_edit_invoice == true) {
                //UserDefaults.standard.set(selected_name, forKey: "selected_customer")
                UserDefaults.standard.set(selected, forKey: "selected_customer")
                UserDefaults.standard.set(selected_id, forKey: "selected_customer_id")
                UserDefaults.standard.set(selected_name, forKey: "selected_customer_name")
                UserDefaults.standard.set(selected_fname, forKey: "selected_customer_fname")
                getCustomerId()
            } else {
                //performSegue(withIdentifier: "edit_customer_segue", sender: self)
            }
        //12}
    }
    
    func getCustomerId() {
        var baseurl = (UserDefaults.standard.string(forKey: "api_base_url"))!
        let postData = ["":""] as [String : Any]
        //print("\(baseurl)/customer?email=\(selected!)")
        self.serverApiCall(route: ("\(baseurl)/customer?email=\(selected!)&source=app"), method: "GET", data: postData, responseHandler: handleResponseCustomer, errorHandler: handleErrorCustomer, showSpiner: true)
    }
    func handleResponseCustomer(data: Data) {
        do{
            let json = try JSON(data: data)
            print(json["customer"])
            if let customerObj = json["customer"].array {
                if customerObj.count > 0 {
                    selected_id = customerObj[0]["Id"].string
                    SnowplowManager.shared?.track_customer_details(customerId: selected_id ?? "")
                    UserDefaults.standard.set(selected_id, forKey: "selected_customer_id")
                    var storyboard: UIStoryboard = UIStoryboard(name: "Invoice", bundle: nil)
                    var vc = storyboard.instantiateViewController(withIdentifier: "add_invoice_screen") as! AddInvoiceController
                    self.show(vc, sender: self)
                } else {
                    let postData = [ "customerInformation":[
                              "Address":[
                                 "Country":selected_country,
                                 "State":selected_state,
                                 "City":selected_city,
                                 "Line1":selected_line1,
                                 "Line2":selected_line2,
                                 "PostalCode":selected_postal
                              ],
                              "Name": selected_name,
                              "Email": selected
                           ]] as [String : Any]
                    //print(postData)
                    var baseurl = (UserDefaults.standard.string(forKey: "api_base_url"))!
                    self.serverApiCall(route: ("\(baseurl)/customer"), method: "POST" , data: postData, responseHandler: handleResponseAdd, errorHandler: handleErrorAdd)
                }
            }
        }catch let decodingEror as DecodingError {
            
        }catch{
            
        }
    }
    func handleErrorCustomer(error: Error) {
        //print(error)
    }
    func handleResponseAdd(data: Data) {
        print("in handleResponseAdd \(data.prettyPrintedJSONString)")
        do{
            self.customer_response = try JSONDecoder().decode(CustomerResponse.self, from: data)
            if(customer_response.customer != nil) {
                //self.present(self.showOkAlertWithHandler(title: "Customer Added", content: "Customer Added Successfully"), animated: true)
                UserDefaults.standard.set(customer_response.customer, forKey: "selected_customer_id")
                SnowplowManager.shared?.track_customer_details(customerId: customer_response.customer ?? "")
                var storyboard: UIStoryboard = UIStoryboard(name: "Invoice", bundle: nil)
                if(from_add_invoice == true) {
                    var vc = storyboard.instantiateViewController(withIdentifier: "add_invoice_screen") as! AddInvoiceController
                    vc.customer_added = true
                    self.show(vc, sender: self)
                } else if(from_edit_invoice == true) {
                    var vc = storyboard.instantiateViewController(withIdentifier: "edit_invoice_screen") as! EditInvoiceController
                    vc.invoice_id = invoice_id
                    self.show(vc, sender: self)
                }
                
            } else {
                self.present(Common.showErrorAlert(title: "\(Common.add_error_title)", content: Common.add_error_text), animated: true)
            }
        }catch let decodingEror as DecodingError {
            
        }catch{
            
        }
    }
    func handleErrorAdd(error: Error) {
        //tableView.refreshControl?.endRefreshing()
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

extension CustomerController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.count > 0) {
            var searchIds = [String]()
            searchedCustomer = customerList.filter { (dataArray:[String]) -> Bool in
                return dataArray.filter({ (string) -> Bool in
                    //print(string.lowercased())
                    return string.lowercased().contains(searchText.lowercased())
                }).count > 0
            }
            for searchId in searchedCustomer {
                searchIds.append("\"\(searchId[0])\"")
               
            }
            //print(searchedCustomer)
            SnowplowManager.shared?.track_customer_list(search: "null", customerIds: searchIds)
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(customerList.count <= 0) {
            return 320
        } /*else if(indexPath.row == 0) {
            return 25
        }*/else {
            return UITableView.automaticDimension
        }
    }
}

class CustomerCell: UITableViewCell {
    @IBOutlet weak var customer_name: UILabel!
    @IBOutlet weak var customer_email: UILabel!
    @IBOutlet weak var container_view: UIView!
    //private lazy var maskLayer = CAShapeLayer()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: Common.table_content_inset)
    }
    /*
    var corners: UIRectCorner = [] {
        didSet {
            setNeedsLayout()
            updatePath(with: corners)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updatePath(with: corners)
        //contentView.frame = contentView.frame.inset(by: Common.table_content_inset)
    }

    private func updatePath(with corners: UIRectCorner) {
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: 20, height:  20)
        )
        maskLayer.path = path.cgPath
        contentView.clipsToBounds = true
        //maskLayer.masksToBounds = true
        layer.mask = maskLayer
    }
    */
    /*
    var shadowLayer = CAShapeLayer()

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(roundedRect: self.container_view.bounds, byRoundingCorners: [.bottomRight, .bottomLeft], cornerRadii: CGSize(width: 10, height: 10))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.container_view.layer.mask = mask
        // Handle Cell reuse case
        shadowLayer.removeFromSuperlayer()

        shadowLayer.shadowPath = path.cgPath
        shadowLayer.frame = self.container_view.layer.frame
        print(shadowLayer.frame)
        shadowLayer.shadowOffset = CGSize(width: 0, height: 0)
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowOpacity = 0.9
        self.contentView.layer.insertSublayer(shadowLayer, below: self.container_view.layer)
        super.draw(rect)
    }
   */
}
class NoCustomerCell: UITableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: Common.table_content_inset)
    }
}
class CustomerListEmptyCell: UITableViewCell {
    
}
class NoSearchCustomerCell: UITableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: Common.table_content_inset)
    }
}
