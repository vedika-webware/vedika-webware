//
//  PreViewController.swift
//  WebwarePay
//
//  Created by Vedika on 07/03/22.
//

import UIKit
import SwiftyJSON
class PreViewController: MyTableViewController {

    var posoNumber: String!
    var projectName: String!
    var customerName: String!
    var customerId: String!
    var customerEmail: String!
    var item_array = [[String]]()
    var selected_item_array: [[ Any]] = []
    var invoice_item_array: [[ Any]] = []
    var subtotal = 0;
    var invoice_id = ""
    var invoice_item = [[ Any]]()
    var due_date = ""
    var invoice_date = ""
    var tax_percent: Double!
    var tax_id: String!
    var tax_name : String!
    var invoice_response: InvoiceResponse!
    
    var tax_percent_updated: Double!
    var tax_id_updated: String!
    var tax_name_updated : String!
    
    var product_price = 0.0
    var tax_amount:Double = 0
    var footer_note = ""
    var current_currency = ""
    var total_amount = ""
    var frame_width = 0;
    var from_paid_invoice = false
    var from_add_edit = false
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(false, forKey: "save_draft_values")
        self.title = "View Invoice"
        self.tabBarController?.selectedIndex = 0
        //if(UserDefaults.standard.array(forKey: "selected_item") != nil) {
            //selected_item_array = (UserDefaults.standard.array(forKey: "selected_item") as? [[ Any]])!;
        //}
        //selected_item_array.append(["test","test desc", 1.0, 2, "sdfsdfsdf", "r"])
        //selected_item_array.append(["test123","test123 desc", 12.0, 2, "22dsf", "r"])
        tableView.tableFooterView = UIView()
        frame_width = Int(self.view.frame.width - 45)
        //getInvoiceDetails()
        //self.tableView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        if(from_paid_invoice == false) {
            let sendButton = UIBarButtonItem(title: "Send",  style: .plain, target: self, action: #selector(sendTapped))
            navigationItem.rightBarButtonItems = [sendButton]
        } else {
            
        }
        if(from_add_edit == true) {
            navigationItem.hidesBackButton = true
        }
        current_currency = UserDefaults.standard.string(forKey: "currency")!
        customerName = UserDefaults.standard.string(forKey: "selected_customer_name") ?? nil
        posoNumber = UserDefaults.standard.string(forKey: "poso_number") ?? nil
        projectName = UserDefaults.standard.string(forKey: "description") ?? nil
        if(customerName != nil) {
            //self.showToast(message: "\(customerName!) Added", font: UIFont.boldSystemFont(ofSize: 12))
        }
        print("on load \(invoice_id)")
        getInvoiceDetails()
        self.tableView.reloadData()
    }
    @objc func sendTapped() {
        invoiceSend(invoice_id: invoice_id)
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
                self.present(self.showOkAlertWithHandler(title: "Invoice sent successfully!", content: "Your Invoice has been sent to customer."), animated: true)
            } else {
                self.present(Common.showErrorAlert(title: Common.add_error_title, content: Common.add_error_text), animated: true)
            }
            
        }catch let decodingEror as DecodingError {
            self.present(Common.showErrorAlert(title: Common.add_error_title, content: Common.add_error_text), animated: true)
            //print("in decoding error \(decodingEror)")
        }catch{
        }
    }
    func showOkAlertWithHandler(title: String, content: String) -> UIAlertController{
        let alert = UIAlertController(title: title, message: content, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: { [self]  action in
            let storyboard: UIStoryboard = UIStoryboard(name: "Invoice", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "invoice_list_view") as! InvoiceViewController
            self.show(vc, sender: self)
        })
        OKAction.setValue(UIColor.black, forKey: "titleTextColor")
        alert.addAction(OKAction)
        return alert
    }
    func handleErrorSend(error: Error) {
        print(error)
        self.present(Common.showErrorAlert(title: Common.add_error_title, content: Common.add_error_text), animated: true)
    }
    func getInvoiceDetails() {
        var baseurl = (UserDefaults.standard.string(forKey: "api_base_url"))!
         
        let postData = ["":""] as [String : Any]
        self.serverApiCall(route: ("\(baseurl)/invoice?invoiceId=\(invoice_id)"), method: "GET", data: postData, responseHandler: handleResponse, errorHandler: handleError)
    }
    func handleResponse(data: Data) {
        do{
            selected_item_array = []
            //if(UserDefaults.standard.array(forKey: "selected_item") != nil) {
                //selected_item_array = (UserDefaults.standard.array(forKey: "selected_item") as? [[ Any]])!;
            //}
            //print("RESPONSE \(data.prettyPrintedJSONString)")
            item_array = [[String]]()
            let json = try JSON(data: data)
            print(json["invoice"])
                if let linedata = json["invoice"]["Lines"]["data"].array {
                    print("line count \(linedata.count)")
                    for invoiceItem in linedata {
                        //print(invoiceItem)
                        var counter = 0
                        var invoiceItemObj = [Any]()
                        var name = ""
                        var description = ""
                        var price = 0
                        var quantity = 0
                        var id = ""
                        var total_amount = 0.0
                        var unit_item_price = 0.0
                        //var product_price = 0
                        for field in invoiceItem {
                            if(field.0 == "amount") {
                                total_amount = field.1.rawValue as! Double
                                //print("total_amount \(total_amount)")
                            }
                            if(field.0 == "price") {
                                for pricefield in field.1 {
                                    if(pricefield.0 == "product") {
                                        if var x = pricefield.1.rawValue as? Int{
                                            name = String(x)
                                        } else if var x = pricefield.1.rawValue as? String{
                                            name = pricefield.1.rawValue as! String
                                        }
                                    }
                                    if(pricefield.0 == "unit_amount") {
                                        //var unit_price = (pricefield.1.rawValue as! Int)
                                        //product_price = Double(unit_price / 100)
                                        //var pricestring = String(product_price)
                                        //product_price = pricestring
                                        
                                        let unit_price : Double = pricefield.1.rawValue as! Double
                                        let pricestring = Double(Common.roundTwoDecimal(val: unit_price) / 100)
                                        product_price = pricestring
                                    }
                                }
                            }
                            if(field.0 == "description") {
                                if(field.1.rawString() != "null") {
                                    description = field.1.string ?? ""
                                }
                                //projectName = description
                            }
                            
                            if(field.0 == "quantity") {
                                let quantity_int : Int = 3 //field.1.rawValue as! Int
                                var quantity_str = String(quantity_int)
                                quantity = quantity_int
                            }
                            if(field.0 == "id") {
                                id = field.1.string ?? ""
                            }
                        }
                        if(total_amount != 0.0 && unit_item_price != 0) {
                            let quantity_int : Int = Int(total_amount / unit_item_price) //field.1.rawValue as! Int
                            var quantity_str = String(quantity_int)
                            quantity = quantity_int
                        }
                        invoiceItemObj.append(name)
                        invoiceItemObj.append(description)
                        invoiceItemObj.append(product_price)
                        invoiceItemObj.append(quantity)
                        invoiceItemObj.append(id)
                        invoiceItemObj.append(price)
                        if(invoiceItemObj != nil) {
                            selected_item_array.append(invoiceItemObj)
                        }
                    }
                    
                    print(selected_item_array)
                }
                //if let footerNote = json["invoice"]["Footer"].string {
                    //footer_note = footerNote
                //}
                if let footerNote_raw = json["invoice"]["Footer"].rawString() {
                    if(footerNote_raw != "null") {
                        footer_note = footerNote_raw
                    }
                }
                if let customerNameObj = json["invoice"]["CustomerName"].rawString() {
                    customerName = customerNameObj
                }
                if let customerIdObj = json["invoice"]["Customer"].rawString() {
                    customerId = customerIdObj
                }
                if let customerEmailObj = json["invoice"]["CustomerEmail"].rawString() {
                    customerEmail = customerEmailObj
                }
                if let due_date_obj = json["invoice"]["DueDate"].rawString() {
                    due_date = due_date_obj
                }
                if let invoice_date_obj = json["invoice"]["Created"].rawString() {
                    invoice_date = invoice_date_obj
                }
                if let custom_fields = json["invoice"]["CustomFields"].array {
                    for custom_field in custom_fields {
                        for c_field in custom_field {
                            if(c_field.0 == "value") {
                                posoNumber = c_field.1.rawString() ?? ""
                            }
                        }
                    }
                }
                if let invoice_description_obj = json["invoice"]["Description"].rawString() {
                    projectName = invoice_description_obj
                }
                print("projectName \(projectName)")
            /*
                print("customerId \(customerId)")
                print("customerEmail \(customerEmail)")
                print("customerName \(customerName)")
                UserDefaults.standard.set(customerEmail!, forKey: "selected_customer")
                UserDefaults.standard.set(customerId!, forKey: "selected_customer_id")
                UserDefaults.standard.set(customerName!, forKey: "selected_customer_name")
               */
                //if(UserDefaults.standard.string(forKey: "poso_number") == nil) {
                    //UserDefaults.standard.set(posoNumber, forKey: "poso_number")
                //}
                //if(UserDefaults.standard.string(forKey: "description") == nil) {
                    //UserDefaults.standard.set(projectName, forKey: "description")
                //}
                print(due_date)
                if let taxDetails = json["invoice"]["DefaultTaxRates"].array {
                    var tax_percent_str = ""
                    for taxItem in taxDetails {
                        for field in taxItem {
                            if(field.0 == "Percentage") {
                                tax_percent = (field.1.rawValue as! Double)
                                tax_percent_str = String(tax_percent)
                            }
                            if(field.0 == "DisplayName") {
                                tax_name = field.1.rawString() ?? ""
                            }
                            if(field.0 == "Id") {
                                tax_id = field.1.string ?? ""
                            }
                        }
                    }
                    print("before tax name updated \(tax_name_updated) = \(tax_percent)")
                    if(tax_name_updated != nil) {
                        tax_id = tax_id_updated
                        tax_name = tax_name_updated
                        tax_percent = tax_percent_updated
                    }
                    print("after tax name updated \(tax_name_updated) = \(tax_percent)")
                    UserDefaults.standard.set(tax_percent, forKey: "selected_tax_percent")
                    UserDefaults.standard.set(tax_id, forKey: "selected_tax_id")
                    UserDefaults.standard.set(tax_name, forKey: "selected_tax_name")
                    
                }
                tableView.refreshControl?.endRefreshing()
                tableView.reloadData()
            
        }catch let decodingEror as DecodingError {
            tableView.refreshControl?.endRefreshing()
        }catch{
            tableView.refreshControl?.endRefreshing()
        }
    }
    func handleError(error: Error) {
        tableView.refreshControl?.endRefreshing()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(selected_item_array.count > 0) {
            if(footer_note == "") {
                return 6
            } else {
                return 7
            }
        } else {
            return 4
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 1) {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "basic_info", for: indexPath) as! PreviewBasicCell
            cell1.container_view.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 8.0)
            cell1.container_view.dropShadow()
            cell1.invoice_lbl.text = "Invoice"
            if(UserDefaults.standard.string(forKey: "poso_number") == nil) {
                cell1.posoNumber.text = posoNumber ?? "P.O./S.O. Number"
                UserDefaults.standard.set(posoNumber, forKey: "poso_number")
            } else {
                cell1.posoNumber.text = UserDefaults.standard.string(forKey: "poso_number") ?? "P.O./S.O. Number"
            }
            print("project name \(projectName)")
            //if(UserDefaults.standard.string(forKey: "description") == nil) {
            if(projectName == "") {
                var projectNameCroped = "Project Name / Description"
                if(projectNameCroped.count > 30) {
                    projectNameCroped = "\(String(projectNameCroped.prefix(30)))..."
                }
                cell1.project_name.text = projectNameCroped ?? "Project Name/Description"
            } else {
                var projectNameCroped = projectName ?? "Project Name / Description"
                if(projectNameCroped.count > 30) {
                    projectNameCroped = "\(String(projectNameCroped.prefix(30)))..."
                }
                cell1.project_name.text = projectNameCroped
            }
            cell1.project_name.textColor = UIColor.white
            cell1.posoNumber.textColor = UIColor.white
            return cell1
        } else if(indexPath.row == 3) {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "invoice_date_cell", for: indexPath) as! PreviewInvoiceDateCell
            cell1.container_view.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 8.0)
            cell1.left_title.text = "Invoice Date"
            print("invoice date \(invoice_date)")
            if(invoice_date == "") {
                print("in if")
                let today = Date()
                let formatter3 = DateFormatter()
                formatter3.dateFormat = Common.dateFormatSelected
                cell1.right_title.text = formatter3.string(from: today)
            } else {
                print("in else")
                cell1.right_title.text = convertDateFormater(invoice_date, format: "MMMM, dd yyyy HH:mm:ss")
            }
            print("due date \(due_date)")
            cell1.label_date.text = "Invoice Due"
            cell1.dateSelectBlock = {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = Common.dateFormatSelected
                let strDate = dateFormatter.string(from: cell1.date_picker.date)
                let dateObj = dateFormatter.date(from: strDate)
                //cell1.date_text_field.text = strDate
            }
            if(UserDefaults.standard.string(forKey: "due_date") != nil) {
                print("in if")
                let isoDate = UserDefaults.standard.string(forKey: "due_date")
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                dateFormatter.dateFormat = Common.dateFormatSelected
                let date = dateFormatter.date(from:isoDate!)
                //cell1.date_text_field.text = ""//formatter3.string(from: nextDate!)
                cell1.date_picker.setDate(date!, animated: true)
            } else if(due_date != "") {
                print("in else if \(due_date)")
                //var nextDate = convertDateFormater(due_date, format: "MMMM, dd yyyy HH:mm:ss")
                //cell1.date_picker.setDate(nextDate, animated: true)
                let isoDate = due_date
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                dateFormatter.dateFormat = "MMMM, dd yyyy HH:mm:ss"
                let date = dateFormatter.date(from:isoDate)
                print(date)
                //cell1.date_text_field.text = ""//formatter3.string(from: nextDate!)
                cell1.date_picker.setDate(date!, animated: true)
            } else {
                print("in else")
                let formatter3 = DateFormatter()
                formatter3.dateFormat = Common.dateFormatSelected
                var dayComponent    = DateComponents()
                dayComponent.day    = 8 // For removing one day (yesterday): -1
                let theCalendar     = Calendar.current
                let nextDate        = theCalendar.date(byAdding: dayComponent, to: Date())
                //cell1.date_text_field.text = ""//formatter3.string(from: nextDate!)
                cell1.date_picker.setDate(nextDate!, animated: true)
            }
            cell1.date_picker.isEnabled = false
            //cell1.date_picker.minimumDate = Date()
            //cell1.date_text_field.tag = 2
            cell1.date_picker.tag = 2
            if #available(iOS 14, *) {
                
            } else {
                if #available(iOS 13.4, *) {
                    cell1.date_picker.preferredDatePickerStyle = .compact
                }
                cell1.date_picker.widthAnchor.constraint(equalToConstant: CGFloat(150)).isActive = true
                cell1.date_picker.heightAnchor.constraint(equalToConstant: CGFloat(44)).isActive = true
            }
            return cell1
        } else if(indexPath.row == 2) {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "other_info", for: indexPath) as! PreviewOtherCell
            var customer_name_show = " Add Customer"
            cell1.container_view.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 8.0)
            if(customerName != nil) {
                customer_name_show = " \(customerName!)"
                //cell1.left_title.text = customer_name_show
                cell1.left_title.addTextWithImage(text: customer_name_show,image: UIImage(named: "add_customer")!,imageBehindText: false,keepPreviousText: false)
            } else {
                cell1.left_title.addTextWithImage(text: customer_name_show,image: UIImage(named: "add_customer")!,imageBehindText: false,keepPreviousText: false)
            }
            cell1.right_title.text = ""//>"
            cell1.arrow.isHidden = true
            return cell1
        } /*else if(indexPath.row == 4) {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "other_info", for: indexPath) as! PreviewOtherCell
            cell1.container_view.roundCorners(corners: [.bottomLeft , .bottomRight, .topLeft, .topRight], radius: 8.0)
            cell1.left_title.addTextWithImage(text: " Add Product",image: UIImage(named: "add_item")!,imageBehindText: false,keepPreviousText: false)
            cell1.right_title.text = ">"
            return cell1
        } */else if(selected_item_array.count > 0 && indexPath.row == 4) {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "invoice_all_item_cell", for: indexPath) as! PreviewInvoiceAllItemCell
            //cell1.container_view.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 8.0)
            cell1.container_view.layer.cornerRadius = 8
            cell1.container_view.layer.masksToBounds = true
            cell1.item_stack.removeAllArrangedSubviews()
            //subtotal = 0
            var z = 100
            var itemcnt = 1
            for itemObj in selected_item_array {
                print("in for \(itemObj)")
                let name = itemObj[0] as! String
                let desc = itemObj[1] as! String
                let quantity : Int = itemObj[3] as! Int
                let quantity_str = String(quantity)
                let price : Double = itemObj[2] as! Double
                let price_str = "\(current_currency)\(String(price.rounded(toPlaces:2)))"
                
                let label1 = UILabel(frame: CGRect(x: 15, y: 7, width: 200, height: 21))
                label1.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
                label1.font = label1.font.withSize(17)
                label1.text = name
                
                let label2 = UILabel(frame: CGRect(x: 15, y: 25, width: 200, height: 21))
                label2.textColor = UIColor(red: 0.24, green: 0.24, blue: 0.26, alpha: 0.6)
                label2.font = label2.font.withSize(15)
                label2.text = desc
                
                let Font =  UIFont.systemFont(ofSize: 17.0)
                let SizeOfString = quantity_str.SizeOf_String(font: Font)
                let txt_qty = UITextField(frame: CGRect(x: 15, y: 48, width: SizeOfString.width + 20, height: 30))
                txt_qty.textColor = UIColor(red: 0.55, green: 0.55, blue: 0.56, alpha: 1.00)
                txt_qty.font = txt_qty.font?.withSize(17)
                //txt_qty.layer.borderColor = UIColor.darkGray.cgColor
                //txt_qty.layer.borderWidth = 1.5
                txt_qty.layer.cornerRadius = 5
                txt_qty.textAlignment = NSTextAlignment.center
                txt_qty.backgroundColor = UIColor(red: 0.90, green: 0.89, blue: 0.89, alpha: 1.00)
                txt_qty.text = quantity_str
                txt_qty.isEnabled = false
                /*
                let Font =  UIFont.systemFont(ofSize: 17.0)
                let SizeOfString = quantity_str.SizeOf_String(font: Font)
                let label_qty = UILabel(frame: CGRect(x: 15, y: 48, width: SizeOfString.width + 20, height: 30))
                label_qty.textColor = UIColor(red: 0.55, green: 0.55, blue: 0.56, alpha: 1.00)
                label_qty.font = label_qty.font.withSize(17)
                //label_qty.layer.borderColor = UIColor.red.cgColor
                //label_qty.layer.borderColor = .none
                
                label_qty.backgroundColor = UIColor(red: 0.90, green: 0.89, blue: 0.89, alpha: 1.00)
                label_qty.layer.cornerRadius = 5
                label_qty.textAlignment = NSTextAlignment.center
                label_qty.text = quantity_str
                */
                
                let label3 = UILabel(frame: CGRect(x: SizeOfString.width + 38, y: 52, width: 200, height: 21))
                label3.textColor = UIColor(red: 0.24, green: 0.24, blue: 0.26, alpha: 0.6)
                label3.font = label3.font.withSize(17)
                label3.text = (" x \(price_str)")
                
                let label4 = UILabel(frame: CGRect(x: 15, y: 7, width: frame_width - 20, height: 21))
                label4.textColor = UIColor(red: 0.24, green: 0.24, blue: 0.26, alpha: 0.6)
                label4.font = label4.font.withSize(17)
                label4.textAlignment = .right
                //label4.text = "\(current_currency)\(String(Double(Int(quantity) * Int(price)).rounded(toPlaces:2)))"
                var qty_price = Common.roundTwoDecimal(val: Double(Double(quantity) * (price)))
                label4.text = "\(current_currency)\(String(qty_price))"
                
                let view_item = UIView()
                view_item.backgroundColor = UIColor(red: 0.96, green: 0.95, blue: 0.95, alpha: 1.00)
                if(itemcnt == selected_item_array.count) {
                    view_item.heightAnchor.constraint(equalToConstant: 115).isActive = true
                } else {
                    view_item.heightAnchor.constraint(equalToConstant: 85).isActive = true
                }
                view_item.widthAnchor.constraint(equalToConstant: CGFloat(frame_width)).isActive = true
                
                
                let lineView = UIView()
                lineView.backgroundColor = UIColor(red: 0.96, green: 0.95, blue: 0.95, alpha: 1.00)
                if(itemcnt == selected_item_array.count) {
                    //view_item1.heightAnchor.constraint(equalToConstant: 0).isActive = true
                } else {
                    lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
                }
                lineView.widthAnchor.constraint(equalToConstant: CGFloat(frame_width)).isActive = true
                
                var lineViewSub = UIView(frame: CGRect(x: 10, y: 0, width: frame_width + 10 , height: Int(1.0)))
                lineViewSub.backgroundColor = UIColor(red: 0.78, green: 0.78, blue: 0.78, alpha: 1.00)
                lineView.addSubview(lineViewSub)
                
                view_item.addSubview(label1)
                view_item.addSubview(label2)
                view_item.addSubview(txt_qty)
                view_item.addSubview(label3)
                view_item.addSubview(label4)
                
                cell1.item_stack.addArrangedSubview(view_item)
                cell1.item_stack.addArrangedSubview(lineView)
                
                //subtotal += Int(quantity) * Int(price)
                z = z + 100
                itemcnt = itemcnt + 1
                /*
                print("in for")
                var name = itemObj[0] as! String
                var desc = itemObj[1] as! String
                let quantity : Int = itemObj[3] as! Int
                var quantity_str = String(quantity)
                let price : Double = itemObj[2] as! Double
                var price_str = "\(current_currency)\(String(price))"
                
                let label1 = UILabel(frame: CGRect(x: 15, y: 15, width: 200, height: 21))
                label1.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
                label1.font = label1.font.withSize(17)
                label1.text = name
                
                let label2 = UILabel(frame: CGRect(x: 15, y: 35, width: 200, height: 21))
                label2.textColor = UIColor(red: 0.24, green: 0.24, blue: 0.26, alpha: 0.6)
                label2.font = label2.font.withSize(15)
                label2.text = desc
                
                let Font =  UIFont.systemFont(ofSize: 17.0)
                let SizeOfString = quantity_str.SizeOf_String(font: Font)
                let label_qty = UILabel(frame: CGRect(x: 15, y: 55, width: SizeOfString.width + 10, height: 21))
                label_qty.textColor = UIColor(red: 0.24, green: 0.24, blue: 0.26, alpha: 0.6)
                label_qty.font = label_qty.font.withSize(17)
                label_qty.layer.borderColor = UIColor.darkGray.cgColor
                label_qty.layer.borderWidth = 1.0
                label_qty.textAlignment = NSTextAlignment.center
                label_qty.text = quantity_str
                
                let label3 = UILabel(frame: CGRect(x: 28 + SizeOfString.width, y: 55, width: 200, height: 21))
                label3.textColor = UIColor(red: 0.24, green: 0.24, blue: 0.26, alpha: 0.6)
                label3.font = label3.font.withSize(17)
                label3.text = (" X \(price_str)")
                
                let label4 = UILabel(frame: CGRect(x: 15, y: 15, width: frame_width, height: 21))
                label4.textColor = UIColor(red: 0.24, green: 0.24, blue: 0.26, alpha: 0.6)
                label4.font = label4.font.withSize(17)
                label4.textAlignment = .right
                label4.text = "\(current_currency)\(String(Int(quantity) * Int(price)))"
                
                let view_item = UIView()
                view_item.backgroundColor = UIColor(red: 0.96, green: 0.95, blue: 0.95, alpha: 1.00)
                if(itemcnt == selected_item_array.count) {
                    view_item.heightAnchor.constraint(equalToConstant: 130).isActive = true
                } else {
                    view_item.heightAnchor.constraint(equalToConstant: 100).isActive = true
                }
                view_item.widthAnchor.constraint(equalToConstant: CGFloat(frame_width)).isActive = true
                
                view_item.addSubview(label1)
                view_item.addSubview(label2)
                view_item.addSubview(label_qty)
                view_item.addSubview(label3)
                view_item.addSubview(label4)
                cell1.item_stack.addArrangedSubview(view_item)
                //subtotal += Int(quantity) * Int(price)
                z = z + 100
                itemcnt = itemcnt + 1
                */
                
            }
            //cell1.item_stack.translatesAutoresizingMaskIntoConstraints = false
 
            return cell1
        } else if(selected_item_array.count > 0 && indexPath.row == 5) {
            var subtotal_numeric = 0.0 as! Double
            for itemObj in selected_item_array {
                let quantity : Int = itemObj[3] as! Int
                let price : Double = itemObj[2] as! Double
                //subtotal_numeric += Double(Int(quantity) * Int(price))
                subtotal_numeric += Common.roundTwoDecimal(val:(Double(quantity) * Double(price)))
            }
            subtotal_numeric = Common.roundTwoDecimal(val: subtotal_numeric)
            //print("subtotal_numeric \(subtotal_numeric)")
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "edit_subtotal_cell", for: indexPath) as! PreviewSubtotalCell
            //cell1.container_view.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 8.0)
            //cell1.last_view.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 8.0)
            
            cell1.container_view.layer.cornerRadius = 8
            cell1.container_view.layer.masksToBounds = true
            
            var subtotal = "\(current_currency)\(String(subtotal_numeric))" ?? "\(current_currency)0.00"
            
            var tax_show = "Add Tax"
            var tax_amount:Double = 0
            if(tax_name != nil) {
                tax_show = "\(tax_name!) \(tax_percent!)%"
                //tax_percent = (tax_percent/100) as Double
                //tax_amount = round(Double(subtotal_numeric) * tax_percent)
                //tax_amount = round(Double(subtotal_numeric) * (tax_percent/100))
                tax_amount = Common.roundTwoDecimal(val: (Double(subtotal_numeric) * (tax_percent/100)))
            } else {
                tax_percent = 0
            }
            //print("in load total \(tax_percent) = \(tax_amount)")
            /*
            var amount_due = "\(current_currency)\(String(round(Double(subtotal_numeric) * (tax_percent ?? 0) + Double(subtotal_numeric))))"
            total_amount = "\(String(amount_due))"
            var total_array: [[ Any]] = []
            total_array.append(["Subtotal", String(subtotal)])
            total_array.append([tax_show, String(tax_amount)])
            total_array.append(["Total", String(amount_due)])
            total_array.append(["Amount Due", String(amount_due)])
            */
            var amount_due =  Common.roundTwoDecimal(val: subtotal_numeric + tax_amount)
            var total = Int(subtotal_numeric) + Int(tax_amount)
            var total_array: [[ Any]] = []
            total_array.append(["Subtotal", "\(current_currency)\(String(subtotal_numeric))"])
            total_array.append([tax_show, "\(current_currency)\(String(tax_amount))"])
            total_array.append(["Total", "\(current_currency)\(String(amount_due))"])
            total_array.append(["Amount Due", "\(current_currency)\(String(amount_due))"])
            total_amount = "\(current_currency)\(String(amount_due))"
            
            cell1.label1.text = total_array[0][0]  as! String
            cell1.label2.text = total_array[0][1]  as! String
            
            cell1.label3.text = total_array[1][0]  as! String
            cell1.label4.text = total_array[1][1]  as! String
            
            //let tap = UITapGestureRecognizer(target: self, action: #selector(self.addTaxTapped(_:)))
            //cell1.add_tax_view.addGestureRecognizer(tap)
            
            cell1.label5.text = total_array[2][0]  as! String
            cell1.label6.text = total_array[2][1]  as! String
            
            cell1.label7.text = total_array[3][0]  as! String
            cell1.label8.text = total_array[3][1]  as! String
 
            var short_currency = UserDefaults.standard.string(forKey: "short_currency")
            if(short_currency == "INR") {
                cell1.currency_label.text = "INR"
            } else if(short_currency == "CAD") {
                cell1.currency_label.text = "CAD"
            } else if(short_currency == "USD") {
                cell1.currency_label.text = "USD"
            } else {
                cell1.currency_label.isHidden = true
            }
            cell1.currency_label.layer.borderColor = UIColor.gray.cgColor
            cell1.currency_label.layer.borderWidth = 2.0
            cell1.currency_label.layer.cornerRadius = 3.0
            
            return cell1
        } else if(selected_item_array.count > 0 && indexPath.row == 6 && footer_note != "") {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "note_cell", for: indexPath) as! PreviewInvoiceNoteCell
            cell1.layoutIfNeeded()
            cell1.container_view.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 8.0)
            cell1.note_value.tag = 1
            cell1.note_value.text = footer_note
            cell1.note_value.isEnabled = false
            return cell1
        } /*else if(selected_item_array.count > 0 && indexPath.row == 8) {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "action_cell", for: indexPath) as! PreviewActionCell
            cell1.save_btn.layer.cornerRadius = 8
            cell1.layoutIfNeeded()
            return cell1
        } */ else {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "empty_cell", for: indexPath) as! PreviewEmptyCell
            if(indexPath.row == 0) {
                cell1.backgroundColor = Common.navigation_back_color
            }
            cell1.layoutIfNeeded()
            return cell1
        }
        
    }
    func convertDateFormater(_ date: String, format: String) -> String
    {
        if(date != nil && date != "") {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = format
            let date = dateFormatter.date(from: date)
            dateFormatter.dateFormat = Common.dateFormatSelected
            return  dateFormatter.string(from: date!)
        } else {
            let today = Date()
            let formatter3 = DateFormatter()
            formatter3.dateFormat = Common.dateFormatSelected
            return formatter3.string(from: today)
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*
        if(indexPath.row == 1) {
            //back_to_edit_segue
            performSegue(withIdentifier: "edit_invoice_detail_segue", sender: self)
        }
        if(indexPath.row == 6) {
        
        }
        if(indexPath.row == 4) {
            if(UserDefaults.standard.string(forKey: "selected_customer_id") != nil) {
                performSegue(withIdentifier: "add_item_segue", sender: self)
            } else {
                self.present(Common.showRequiredErrorAlert(title: "Error", content: "Please Select Customer First"), animated: true)
            }
        }
        */
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == 1) {
            return 155
        } else if(indexPath.row == 3) {
            return 125
        } else if(indexPath.row == 2) {
                return 80
        } else if(selected_item_array.count > 0 && indexPath.row == 5) {
            //return 215
            return 235
        } else if(selected_item_array.count > 0 && indexPath.row == 6) {
            return 160
        } else if(indexPath.row == 0) {
            return 0
        } else {
            //return 200
            return UITableView.automaticDimension
        }
    }
    func addTopAndBottomBorders(currentView : UIView) {
       let thickness: CGFloat = 22.0
       let topBorder = CALayer()
       let bottomBorder = CALayer()
       topBorder.frame = CGRect(x: 0.0, y: 0.0, width: currentView.frame.size.width, height: thickness)
       topBorder.backgroundColor = UIColor.red.cgColor
       bottomBorder.frame = CGRect(x:0, y: 10, width: currentView.frame.size.width, height:thickness)
       bottomBorder.backgroundColor = UIColor.red.cgColor
        currentView.layer.addSublayer(topBorder)
        currentView.layer.addSublayer(bottomBorder)
        //currentView.layer.insertSublayer(bottomBorder, above: currentView.layer)
        //currentView.clipsToBounds = true
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let due_date = self.view.viewWithTag(2) as? UIDatePicker {
            let formatter3 = DateFormatter()
            formatter3.dateFormat = Common.dateFormatSelected
            var selected_date = formatter3.string(from: due_date.date)
            UserDefaults.standard.set(selected_date, forKey: "due_date")
        }
        if segue.identifier == "edit_customer_segue" {
            let destViewController = segue.destination as! CustomerController
            destViewController.from_edit_invoice = true
            destViewController.invoice_id = invoice_id
        }
        if(segue.identifier == "add_item_segue") {
            let destViewController = segue.destination as! InvoiceItemController
            destViewController.fromAddInvoice = false
            destViewController.invoice_id = invoice_id
            destViewController.fromEditInvoice = true
        }
        if(segue.identifier == "add_tax_segue") {
            let destViewController = segue.destination as! TaxController
            destViewController.from_add_invoice = false
            destViewController.from_edit_invoice = true
            destViewController.invoice_id = invoice_id
        }
        if(segue.identifier == "edit_invoice_detail_segue") {
            let destViewController = segue.destination as! InvoiceDetailsController
            destViewController.fromEditInvoice = true
            destViewController.invoice_id = invoice_id
            destViewController.poso_number = posoNumber ?? ""
            destViewController.project_description = projectName ?? ""
        }
        if(segue.identifier == "send_invoice_segue") {
            let destViewController = segue.destination as! SendInvoiceController
            destViewController.customer_email_var = customerEmail
            destViewController.invoice_id = invoice_id
            destViewController.total = total_amount
            destViewController.note = footer_note
        }
    }
    @IBAction func send_invoice_tapped(_ sender: Any)
    {
        if let due_date = self.view.viewWithTag(2) as? UIDatePicker {
            let formatter3 = DateFormatter()
            formatter3.dateFormat = Common.dateFormatSelected
            var selected_date = formatter3.string(from: due_date.date)
            UserDefaults.standard.set(selected_date, forKey: "due_date")
        }
        if let note_text = self.view.viewWithTag(1) as? UITextField {
            UserDefaults.standard.set(note_text.text, forKey: "note")
        }
        var customer_id = ""
        var note = ""
        var poso_number = ""
        var description = ""
        var duedate = ""
        var tax_id_saved = ""
        if(UserDefaults.standard.string(forKey: "selected_customer_id") != nil) {
            customer_id = UserDefaults.standard.string(forKey: "selected_customer_id")!
        }
        if(UserDefaults.standard.string(forKey: "note") != nil) {
            var note_defaults = UserDefaults.standard.string(forKey: "note") ?? ""
            if(note_defaults != "") {
                note = "\(note_defaults)"
            }
        }
        if(UserDefaults.standard.string(forKey: "poso_number") != nil) {
            poso_number = UserDefaults.standard.string(forKey: "poso_number")!
        }
        if(UserDefaults.standard.string(forKey: "description") != nil) {
            projectName = UserDefaults.standard.string(forKey: "description")!
        }
        if(UserDefaults.standard.string(forKey: "due_date") != nil) {
            let duedate_saved = UserDefaults.standard.string(forKey: "due_date") ?? ""
            print("due date saved \(duedate_saved)")
            // current date and time
            var dfmatter = DateFormatter()
            dfmatter.dateFormat = Common.dateFormatSelected
            var date = dfmatter.date(from: duedate_saved)
            var dateStamp:TimeInterval = date!.timeIntervalSince1970
            var dateSt:Int = Int(dateStamp + 86399)
            duedate = String(dateSt)
            print("duedate \(duedate)")
        }
        if(UserDefaults.standard.string(forKey: "selected_tax_id") != nil) {
            tax_id_saved = UserDefaults.standard.string(forKey: "selected_tax_id") ?? ""
        }
        if(customer_id != "" && note != "" && poso_number != "" && projectName != "" && duedate != "" && tax_id_saved != "") {
            //performSegue(withIdentifier: "send_invoice_segue", sender: self)
            let postData =  [
                "invoiceInformation":[
                     "id" : invoice_id,
                     "description": projectName,
                     "collection_method":"send_invoice",
                     "due_date":duedate,
                     "default_tax_rates":tax_id_saved,
                     "footer": note,
                     "custom_fields":[[
                           "name":"P.O. Number",
                         "value": poso_number
                     ]]
                 ]
             ] as [String : Any]
            print(postData)
            var baseurl = (UserDefaults.standard.string(forKey: "api_base_url"))!
            self.serverApiCall(route: ("\(baseurl)/invoice"), method: "PUT" , data: postData, responseHandler: handleResponseUpdate, errorHandler: handleErrorUpdate)
        } else {
            print(customer_id)
            print(note)
            print(poso_number)
            print(projectName)
            print(duedate)
            print(tax_id_saved)
            self.present(Common.showRequiredErrorAlert(title: Common.required_error_title, content: Common.required_error_text), animated: true)
        }
    }
    
    func handleResponseUpdate(data: Data) {
        do{
            self.invoice_response = try JSONDecoder().decode(InvoiceResponse.self, from: data)
            if(invoice_response.invoice != nil) {
                //self.present(self.showOkAlertWithHandler(title: "Invoive Sent", content: "Your invoice Sent to customer successfully."), animated: true)
                invoice_id = invoice_response.invoice
                SnowplowManager.shared?.track_invoice_action(id: invoice_id, action: "edit", status: "draft", purchaseOrder: posoNumber ?? "", invoiceDate: invoice_date, dueDate: due_date, subTotal: String(subtotal), totalTax: String(format: "%f", tax_amount), total: String(total_amount))
                Common.clearSavedValues()
                performSegue(withIdentifier: "send_invoice_segue", sender: self)
                
            } else {
                self.present(Common.showErrorAlert(title: Common.add_error_title, content: Common.add_error_text), animated: true)
            }
            
        }catch let decodingEror as DecodingError {
            self.present(Common.showErrorAlert(title: Common.add_error_title, content: Common.add_error_text), animated: true)
            //print("in decoding error \(decodingEror)")
        }catch{
        }
    }
    func handleErrorUpdate(error: Error) {
        print(error)
        self.present(Common.showErrorAlert(title: Common.add_error_title, content: Common.add_error_text), animated: true)
    }
    
}


class PreviewBasicCell: UITableViewCell {
    
    @IBOutlet weak var posoNumber: UILabel!
    @IBOutlet weak var project_name: UILabel!
    @IBOutlet weak var invoice_lbl: UILabel!
    @IBOutlet weak var container_view: UIView!
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: Common.add_inv_cell_inset)
    }
}
class PreviewOtherCell: UITableViewCell {
    
    @IBOutlet weak var container_view: UIView!
    @IBOutlet weak var right_title: UILabel!
    @IBOutlet weak var left_title: UILabel!
    
    @IBOutlet weak var arrow: UIImageView!
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: Common.add_inv_cell_inset)
    }
}
class PreviewInvoiceItemCell: UITableViewCell {
    @IBOutlet weak var item_name: UILabel!
    @IBOutlet weak var item_desc: UILabel!
    @IBOutlet weak var item_details: UILabel!
    @IBOutlet weak var item_price: UILabel!
    @IBOutlet weak var tax_info: UILabel!
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: Common.add_inv_cell_inset)
    }
}
class PreviewInvoiceNoteCell: UITableViewCell {
    @IBOutlet weak var note_label: UILabel!
    @IBOutlet weak var container_view: UIView!
    @IBOutlet weak var note_value: UITextField!
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: Common.add_inv_cell_inset)
    }
}
class PreviewInvoiceDateCell: UITableViewCell {
    @IBOutlet weak var container_view: UIView!
    var dateSelectBlock: (() -> Void)? = nil
    @IBOutlet weak var label_date: UILabel!
    @IBOutlet weak var date_text_field: UITextField!
    
    @IBOutlet weak var date_picker: UIDatePicker!
    
    @IBOutlet weak var left_title: UILabel!
    
    @IBOutlet weak var right_title: UILabel!
    
    @IBAction func date_change(_ sender: UIDatePicker) {
        dateSelectBlock?()
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.short
            dateFormatter.timeStyle = DateFormatter.Style.short
            let strDate = dateFormatter.string(from: date_picker.date)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: Common.add_inv_cell_inset)
    }
}

class PreviewActionCell: UITableViewCell {

    @IBOutlet weak var save_btn: UIButton!
}
class PreviewEmptyCell: UITableViewCell {
    
}
class PreviewInvoiceAllItemCell: UITableViewCell {
    @IBOutlet weak var container_view: UIView!
    @IBOutlet weak var item_stack: UIStackView!
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: Common.add_inv_cell_inset)
    }
}
class PreviewSubtotalCell: UITableViewCell {
    var actionBlock: (() -> Void)? = nil
    @IBOutlet weak var container_view: UIView!
    @IBOutlet weak var total_stack: UIStackView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var add_tax_view: UIView!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var label6: UILabel!
    @IBOutlet weak var label7: UILabel!
    @IBOutlet weak var label8: UILabel!
    
    @IBOutlet weak var last_view: UIView!
    
    @IBOutlet weak var currency_label: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: Common.add_inv_cell_inset)
    }
    
    @IBAction func btn_tax_click(_ sender: UIButton) {
        actionBlock?()
    }
}
