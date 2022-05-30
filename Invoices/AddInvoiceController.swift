//
//  AddInvoiceController.swift
//  WebwarePay
//
//  Created by Vedika on 27/10/21.
//

import UIKit
import SwiftyJSON
class AddInvoiceController: MyTableViewController {
    @IBOutlet weak var header_view: UIView!
    
    var posoNumber: String!
    var projectName: String!
    var customerName: String!
    var customerEmail: String!
    var tax_percent: Double!
    var tax_id: String!
    var tax_name : String!
    var item_array = [[String]]()
    var selected_item_array: [[ Any]] = []
    var subtotal = 0;
    var total = 0;
    var invoice_response: InvoiceResponse!
    var invoice_id = ""
    var current_currency = ""
    var customer_added = false
    var frame_width = 0;
    var from_tax_add = false
    var tax_amount_save:Double = 0.00
    var invoice_date = ""
    var due_date = ""
    var total_amount = ""
    var deleted_invoice_item = ""
    var quantity_saved = [Int]()
    var is_open_draft = false
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(true, forKey: "save_draft_values")
        self.title = "New Invoice"
        self.tabBarController?.selectedIndex = 0
        //if(UserDefaults.standard.array(forKey: "selected_item") != nil) {
            //selected_item_array = (UserDefaults.standard.array(forKey: "selected_item") as? [[ Any]])!;
        //}
        //selected_item_array.append(["test","test desc", 1.0, 2, "sdfsdfsdf", "r"])
        //selected_item_array.append(["test123","test123 desc", 12.0, 2, "22dsf", "r"])
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Tax", style: .plain, target: self, action: #selector(addTax))
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "back_arrow"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -10, bottom: 0, right: 0)
        button.setTitle("Cancel", for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        
        tableView.tableFooterView = UIView()
        frame_width = Int(self.view.frame.width - 45)
        
    }
    
    @objc private func dateChanged() {
        if let due_date = self.view.viewWithTag(2) as? UIDatePicker {
            let formatter3 = DateFormatter()
            formatter3.dateFormat = Common.dateFormatSelected
            let selected_date = formatter3.string(from: due_date.date)
            print("due date after add \(selected_date)")
            UserDefaults.standard.set(selected_date, forKey: "due_date")
        }
        presentedViewController?.dismiss(animated: true, completion: nil)
    }
    @objc func backTapped() {
        let alert = UIAlertController(title: "You will lose the invoice", message: "Are you sure you want to discard this new invoice?", preferredStyle: .alert)

        alert.view.tintColor = Common.alert_tint_color
        alert.addAction(UIAlertAction(title: "Discard Invoice", style: .default, handler: { [weak alert] (_) in
            Common.clearSavedValues()
            Common.clearDraftValues()
            let storyboard: UIStoryboard = UIStoryboard(name: "Invoice", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "invoice_list_view") as! InvoiceViewController
            self.show(vc, sender: self)
        }))
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Keep Editing", style: .default, handler: { [weak alert] (_) in
            
        }))

        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
        //performSegue(withIdentifier: "manage_tax_segue", sender: Self.self)
    }
    override func viewDidAppear(_ animated: Bool) {
        
        self.setNavigationDefaults()
        //print(is_open_draft)
        //print(UserDefaults.standard.string(forKey: "draft_selected_customer_name"))
        Common.saveDraftValues()
        if(is_open_draft == true) {
            Common.loadDraftValues()
        }
        //print(UserDefaults.standard.array(forKey: "selected_item"))
        //self.navigationItem.hidesBackButton = true
        current_currency = UserDefaults.standard.string(forKey: "currency")!
        customerName = UserDefaults.standard.string(forKey: "selected_customer_name") ?? nil
        posoNumber = UserDefaults.standard.string(forKey: "poso_number") ?? nil
        projectName = UserDefaults.standard.string(forKey: "description") ?? nil
        customerEmail = UserDefaults.standard.string(forKey: "selected_customer") ?? nil
        tax_percent = Double(UserDefaults.standard.string(forKey: "selected_tax_percent") ?? "0.00")
        tax_id = UserDefaults.standard.string(forKey: "selected_tax_id")  ?? nil
        tax_name = UserDefaults.standard.string(forKey: "selected_tax_name")  ?? nil
        if(UserDefaults.standard.array(forKey: "selected_item") != nil) {
            selected_item_array = (UserDefaults.standard.array(forKey: "selected_item") as? [[ Any]])!;
        }

        self.tableView.reloadData()
    } 
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(selected_item_array.count > 0) {
            return 9
            //subtotal = 0
            //return selected_item_array.count + 16
        } else {
            return 5
            //return 7
            //subtotal = 0
            //return 8
        }
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(indexPath.row == 1) {
            cell.round(corners: [.bottomLeft, .bottomRight, .topLeft, .topRight], withRadius: 8)
        }
        if let lastVisibleIndexPath = tableView.indexPathsForVisibleRows?.last {
            if indexPath == lastVisibleIndexPath {
                if(from_tax_add == true) {
                    let tax_id_save = UserDefaults.standard.string(forKey: "selected_tax_id")  ?? nil
                    //print(tax_id_save)
                    SnowplowManager.shared?.track_tax_details(taxId: tax_id_save!, taxAmount: String(tax_amount_save))
                    from_tax_add = false
                }
            }
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 1) {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "basic_info", for: indexPath) as! BasicCell
            cell1.posoNumber.text = posoNumber ?? "P.O./S.O. Number"
            var projectNameCroped = projectName
            if(projectName != nil) {
                if(projectName.count > 40) {
                    projectNameCroped = "\(String(projectName.prefix(40)))..."
                }
            }
            cell1.project_name.text = projectNameCroped ?? "Project Name / Description"
            cell1.layoutIfNeeded()
            if(posoNumber == nil) {
                cell1.posoNumber.textColor = UIColor(red: 0.92, green: 0.92, blue: 0.96, alpha: 0.3)
            } else {
                cell1.posoNumber.textColor = UIColor.white
            }
            if(projectName == nil) {
                cell1.project_name.textColor = UIColor(red: 0.92, green: 0.92, blue: 0.96, alpha: 0.3)
            } else {
                cell1.project_name.textColor = UIColor.white
            }
            cell1.contentView.dropShadow()
            return cell1
        } else if(indexPath.row == 3) {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "invoice_date_cell", for: indexPath) as! InvoiceDateCell
            cell1.container_view.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 8.0)
            //cell1.container_view.roundCorners(corners: [.topLeft, .topRight], radius: 8.0)
            cell1.left_title.text = "Invoice Date"
            let today = Date()
            //print("today \(today)")
            let formatter3 = DateFormatter()
            formatter3.dateFormat = Common.dateFormatSelected
            //print("today formated \(formatter3.string(from: today))")
            cell1.right_title.text = formatter3.string(from: today)
            invoice_date = cell1.right_title.text!
            cell1.label_date.text = "Payment Due"
            cell1.dateSelectBlock = {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = Common.dateFormatSelected
                let strDate = dateFormatter.string(from: cell1.date_picker.date)
                let dateObj = dateFormatter.date(from: strDate)
                //cell1.date_text_field.text = strDate
                //UserDefaults.standard.set(dateObj, forKey: "due_date")
            }
            if(UserDefaults.standard.string(forKey: "due_date") != nil) {
                let isoDate = UserDefaults.standard.string(forKey: "due_date")
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                dateFormatter.dateFormat = Common.dateFormatSelected
                let date = dateFormatter.date(from:isoDate!)
                //cell1.date_text_field.text = ""//formatter3.string(from: nextDate!)
                cell1.date_picker.setDate(date!, animated: true)
            } else {
                let formatter3 = DateFormatter()
                formatter3.dateFormat = Common.dateFormatSelected
                var dayComponent    = DateComponents()
                dayComponent.day    = 7 // For removing one day (yesterday): -1
                let theCalendar     = Calendar.current
                let nextDate        = theCalendar.date(byAdding: dayComponent, to: Date())
                //cell1.date_text_field.text = ""//formatter3.string(from: nextDate!)
                cell1.date_picker.setDate(nextDate!, animated: true)
            }
            //cell1.date_text_field.tag = 2
            cell1.date_picker.minimumDate = Date()
            cell1.date_picker.tag = 2
            cell1.date_picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
            if #available(iOS 14, *) {
                
            } else {
                if #available(iOS 13.4, *) {
                    cell1.date_picker.preferredDatePickerStyle = .compact
                }
                cell1.date_picker.widthAnchor.constraint(equalToConstant: CGFloat(150)).isActive = true
                cell1.date_picker.heightAnchor.constraint(equalToConstant: CGFloat(44)).isActive = true
            }
            
            cell1.layoutIfNeeded()
            return cell1
        } else if(indexPath.row == 2) {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "other_info", for: indexPath) as! OtherCell
            var customer_name_show = " Add Customer"
            cell1.container_view.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 8.0)
            if(customerName != nil) {
                customer_name_show = " \(customerName!)"
                //cell1.left_title.text = customer_name_show
                cell1.left_title.addTextWithImage(text: customer_name_show,image: UIImage(named: "add_customer")!,imageBehindText: false,keepPreviousText: false)
            } else {
                cell1.left_title.addTextWithImage(text: customer_name_show,image: UIImage(named: "add_customer")!,imageBehindText: false,keepPreviousText: false)
            }
            cell1.layoutIfNeeded()
            cell1.right_title.text = ""
            return cell1
        } else if(indexPath.row == 4) {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "other_info", for: indexPath) as! OtherCell
            cell1.container_view.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 8.0)
            cell1.left_title.addTextWithImage(text: " Add Product",image: UIImage(named: "add_item")!,imageBehindText: false,keepPreviousText: false)
            //cell1.left_title.text = "ITEMS"
            cell1.right_title.text = ""
            cell1.layoutIfNeeded()
            return cell1
        } else if(selected_item_array.count > 0 && indexPath.row == 5) {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "invoice_all_item_cell", for: indexPath) as! InvoiceAllItemCell
            cell1.container_view.layer.cornerRadius = 8
            cell1.container_view.layer.masksToBounds = true
            cell1.item_stack.removeAllArrangedSubviews()
            //subtotal = 0
            var z = 100
            var itemcnt = 1
            print("in tablecell \(selected_item_array)")
            for itemObj in selected_item_array {
                
                var name = itemObj[0] as! String
                var desc = itemObj[1] as! String
                let quantity : Int = itemObj[3] as! Int
                var quantity_str = String(quantity)
                let price : Double = itemObj[2] as! Double
                var price_str = "\(current_currency)\(String(price))"
                
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
                
                var qty_width = SizeOfString.width + 50
                
                
                let txt_qty = UITextField(frame: CGRect(x: 15, y: 48, width: qty_width, height: 30))
                txt_qty.textColor = UIColor(red: 0.55, green: 0.55, blue: 0.56, alpha: 1.00)
                txt_qty.font = txt_qty.font?.withSize(17)
                //txt_qty.layer.borderColor = UIColor(red: 0.55, green: 0.55, blue: 0.56, alpha: 1.00).cgColor
                //txt_qty.layer.borderWidth = 1.5
                txt_qty.layer.cornerRadius = 5
                txt_qty.textAlignment = NSTextAlignment.center
                txt_qty.backgroundColor = UIColor(red: 0.90, green: 0.89, blue: 0.89, alpha: 1.00)
                txt_qty.text = quantity_str
                txt_qty.tag = itemcnt * 5
                txt_qty.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)
                
                /*
                let label_qty = UILabel(frame: CGRect(x: 15, y: 48, width: SizeOfString.width + 10, height: 21))
                label_qty.textColor = UIColor(red: 0.24, green: 0.24, blue: 0.26, alpha: 0.6)
                label_qty.font = label_qty.font.withSize(17)
                label_qty.layer.borderColor = UIColor.darkGray.cgColor
                label_qty.layer.borderWidth = 1.5
                label_qty.layer.cornerRadius = 3
                label_qty.textAlignment = NSTextAlignment.center
                label_qty.text = quantity_str
                */
                
                let label3 = UILabel(frame: CGRect(x: qty_width + 18, y: 52, width: 200, height: 21))
                label3.textColor = UIColor(red: 0.24, green: 0.24, blue: 0.26, alpha: 0.6)
                label3.font = label3.font.withSize(17)
                label3.text = (" x \(price_str)")
                
                let label4 = UILabel(frame: CGRect(x: 15, y: 7, width: frame_width - 20, height: 21))
                label4.textColor = UIColor(red: 0.24, green: 0.24, blue: 0.26, alpha: 0.6)
                label4.font = label4.font.withSize(17)
                label4.textAlignment = .right
                var item_total = 0.0
                item_total = Double(Double(quantity) * Double(price))
                //label4.text = "\(current_currency)\(String(item_total))"
                var qty_price = Common.roundTwoDecimal(val: Double(Double(quantity) * (price)))
                label4.text = "\(current_currency)\(String(qty_price))"
                label4.tag = (itemcnt * 5) + 1
                
                let tap = MyRemoveInvoiceTapGesture(target: self, action: #selector(self.tapFunction(_:)))
                tap.invoice_itm_id = itemObj[4] as! String
                /*let label5 = UILabel(frame: CGRect(x: 15, y: 35, width: frame_width, height: 21))
                tap.invoice_itm_id = itemObj[4] as! String
                label5.textColor = UIColor(red: 0.95, green: 0.37, blue: 0.15, alpha: 1.00)
                label5.font = label4.font.withSize(17)
                label5.textAlignment = .right
                label5.isUserInteractionEnabled = true
                label5.addTextWithImage(text: "",image: UIImage(named: "trash_icon")!,imageBehindText: false,keepPreviousText: false)
                label5.addGestureRecognizer(tap)
                */
                let imageName = "trash_icon_dark.png"
                let image = UIImage(named: imageName)
                let imageView = UIImageView(image: image!)
                imageView.frame = CGRect(x: frame_width - 20, y: 52, width: 20, height: 21)
                imageView.isUserInteractionEnabled = true
                imageView.addGestureRecognizer(tap)
                
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
                //view_item.addSubview(label_qty)
                view_item.addSubview(txt_qty)
            
                view_item.addSubview(label3)
                view_item.addSubview(label4)
                view_item.addSubview(imageView)
                
                cell1.item_stack.addArrangedSubview(view_item)
                cell1.item_stack.addArrangedSubview(lineView)
                print("itemcnt \(itemcnt)")
                //subtotal += Int(quantity) * Int(price)
                z = z + 120
                itemcnt = itemcnt + 1
                
            }
            cell1.item_stack.translatesAutoresizingMaskIntoConstraints = false
            return cell1
        } else if(selected_item_array.count > 0 && indexPath.row == 6) {
            var subtotal_numeric = 0.00 as! Double
            for itemObj in selected_item_array {
                //let quantity : Double = itemObj[3] as! Double
                let quantity : Int = itemObj[3] as! Int
                let price : Double = itemObj[2] as! Double
                //subtotal_numeric += Double(quantity) * Double(price)
                subtotal_numeric += Common.roundTwoDecimal(val:(Double(quantity) * Double(price)))
            }
            subtotal_numeric = Common.roundTwoDecimal(val: subtotal_numeric)
            print("subtotal_numeric \(subtotal_numeric)")
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "subtotal_cell", for: indexPath) as! SubtotalCell
            cell1.container_view.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 8.0)
            cell1.last_view.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 8.0)
            var subtotal = "\(current_currency)\(String(subtotal_numeric))" ?? "\(current_currency)0.00"
            //print("subtotal \(subtotal)")
            
            var tax_show = "Add Tax"
            var tax_amount:Double = 0.00
            if(tax_name != nil) {
                tax_show = "\(tax_name!) \(tax_percent!)%"
                //print("tax percent before \(tax_percent)")
                //tax_percent = (tax_percent/100)
                //tax_amount = round(Double(subtotal_numeric) * (tax_percent/100))
                tax_amount = Common.roundTwoDecimal(val: (Double(subtotal_numeric) * (tax_percent/100)))
                tax_amount_save = tax_amount
                cell1.remove_btn.isHidden = false
                //print("tax percent after \(tax_percent)")
            } else {
                tax_percent = 0
                cell1.remove_btn.isHidden = true
            }
            
            //var amount_due =  "\(current_currency)\(String(round(Double(subtotal_numeric) * (tax_percent ?? 0) + Double(subtotal_numeric))))"
            var amount_due =  Common.roundTwoDecimal(val: subtotal_numeric + tax_amount)
            total = Int(subtotal_numeric) + Int(tax_amount)
            var total_array: [[ Any]] = []
            total_array.append(["Subtotal", "\(current_currency)\(String(subtotal_numeric))"])
            total_array.append([tax_show, "\(current_currency)\(String(tax_amount))"])
            total_array.append(["Total", "\(current_currency)\(String(amount_due))"])
            total_array.append(["Amount Due", "\(current_currency)\(String(amount_due))"])
            total_amount = "\(current_currency)\(String(amount_due))"
            UserDefaults.standard.set(String(amount_due), forKey: "total_amount")
            cell1.label1.text = total_array[0][0]  as! String
            cell1.label2.text = total_array[0][1]  as! String
            
            cell1.label3.text = total_array[1][0]  as! String
            cell1.label4.text = total_array[1][1]  as! String
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.addTaxTapped(_:)))
            cell1.add_tax_view.addGestureRecognizer(tap)
            
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
            
            cell1.delete_tax_block = {
                let alert = UIAlertController(title: "Confirm", message: "Are you sure you want to remove the tax.", preferredStyle: .alert)
                alert.view.tintColor = Common.alert_tint_color
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
                    
                }))
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                    self.tax_name = nil
                    self.tax_percent = 0
                    UserDefaults.standard.removeObject(forKey: "selected_tax_id")
                    UserDefaults.standard.removeObject(forKey: "selected_tax_name")
                    tableView.reloadData()
                }))
                self.present(alert, animated: true, completion: nil)
                
            }
            return cell1
        } else if(selected_item_array.count > 0 && indexPath.row == 7) {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "note_cell", for: indexPath) as! InvoiceNoteCell
            cell1.layoutIfNeeded()
            cell1.container_view.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 8.0)
            cell1.note_value.tag = 1
            //if(UserDefaults.standard.string(forKey: "note") != nil) {
                cell1.note_value.text = UserDefaults.standard.string(forKey: "note") ?? ""
            //} else {
                //cell1.note_value.text = footer_note
            //}
            cell1.note_value.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)
            return cell1
            return cell1
        } else if(selected_item_array.count > 0 && indexPath.row == 8) {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "action_cell", for: indexPath) as! ActionCell
            cell1.btn_save.layer.cornerRadius = 8
            cell1.btn_save.tag = 8
            cell1.layoutIfNeeded()
            return cell1
        } else {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "empty_cell", for: indexPath) as! EmptyCell
            if(indexPath.row == 0) {
                cell1.backgroundColor = Common.navigation_back_color
            }
            cell1.layoutIfNeeded()
            return cell1
        }
        
    }
    
    @objc func tapFunction(_ sender: MyRemoveTapGesture? = nil) {
        let alert = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this product.", preferredStyle: .alert)
        alert.view.tintColor = Common.alert_tint_color
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
            
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            //self.invoiceItemDelete(invoice_item_id: sender?.invoice_itm_id ?? "")
            self.invoiceItemDeleteNew(invoice_item_id: sender?.invoice_itm_id ?? "")
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    func invoiceItemDeleteNew(invoice_item_id : String) {
        self.present(Common.showOkAlert(title: "Invoive Product Deleted", content: "Product is deleted from invoice."), animated: true)
        var cnt = 0
        for itemObj in selected_item_array {
            if(itemObj[4] as! String == deleted_invoice_item) {
                selected_item_array.remove(at: cnt)
                break
            }
            cnt = cnt + 1
        }
        UserDefaults.standard.set(selected_item_array, forKey: "selected_item")
        self.tableView.reloadData()
    }
    func invoiceItemDelete(invoice_item_id : String) {
        deleted_invoice_item = invoice_item_id
        let postData = [
            "invoiceitemId": invoice_item_id
         ]
        let baseurl = (UserDefaults.standard.string(forKey: "api_base_url"))!
        self.serverApiCall(route: ("\(baseurl)/invoiceitem"), method: "DELETE" , data: postData, responseHandler: handleResponseDelete, errorHandler: handleErrorDelete)
    }
    func handleResponseDelete(data: Data) {
        self.present(Common.showOkAlert(title: "Invoive Product Deleted", content: "Product is deleted from invoice."), animated: true)
        var cnt = 0
        for itemObj in selected_item_array {
            if(itemObj[4] as! String == deleted_invoice_item) {
                selected_item_array.remove(at: cnt)
                break
            }
            cnt = cnt + 1
        }
        UserDefaults.standard.set(selected_item_array, forKey: "selected_item")
        self.tableView.reloadData()
    }
    func handleErrorDelete(error: Error) {
        print(error)
        self.present(Common.showErrorAlert(title: Common.add_error_title, content: Common.add_error_text), animated: true)
    }
    @objc func addTaxTapped(_ sender: UITapGestureRecognizer? = nil) {
        //if(UserDefaults.standard.string(forKey: "selected_tax_id") != nil) {
            performSegue(withIdentifier: "add_tax_segue", sender: self)
        /*} else {
            self.present(Common.showRequiredErrorAlert(title: "Error", content: "Please Select Item First"), animated: true)
        }*/
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == 1) {
            return 155
        } else if(indexPath.row == 3) {
            return 135
        } else if(indexPath.row == 2 || indexPath.row == 4) {
                return 80
        } else if(selected_item_array.count > 0 && indexPath.row == 6) {
            //return 215
            return 235
        } else if(selected_item_array.count > 0 && indexPath.row == 7) {
            return 120
        } else if(indexPath.row == 0) {
            return 0
        } else {
            //return 200
            return UITableView.automaticDimension
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(indexPath.row)
        if(indexPath.row == 1) {
            performSegue(withIdentifier: "add_details_segue", sender: self)
        }
        if(indexPath.row == 2) {
            //if(UserDefaults.standard.string(forKey: "poso_number") != nil) {
                performSegue(withIdentifier: "add_customer_segue", sender: self)
            //} else {
                //self.present(Common.showRequiredErrorAlert(title: "Error", content: "Please add P.O./S.O. Number and description First"), animated: true)
            //}
        }
        if(indexPath.row == 4) {
            if(UserDefaults.standard.string(forKey: "selected_customer_id") != nil) {
                performSegue(withIdentifier: "add_invoice_item_segue", sender: self)
            } else {
                self.present(Common.showRequiredErrorAlert(title: "Error", content: "Please Select Customer First"), animated: true)
            }
        }
        if(indexPath.row == 7)
        {
            //if(UserDefaults.standard.string(forKey: "selected_tax_id") != nil) {
                //performSegue(withIdentifier: "add_tax_segue", sender: self)
            /*} else {
                self.present(Common.showRequiredErrorAlert(title: "Error", content: "Please Select Item First"), animated: true)
            }*/
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let note_text = self.view.viewWithTag(1) as? UITextField {
            UserDefaults.standard.set(note_text.text, forKey: "note")
        }
        if let due_date = self.view.viewWithTag(2) as? UIDatePicker {
            print("in if \(due_date.date)")
            let formatter3 = DateFormatter()
            formatter3.dateFormat = Common.dateFormatSelected
            let selected_date = formatter3.string(from: due_date.date)
            print(selected_date)
            UserDefaults.standard.set(selected_date, forKey: "due_date")
        }
        if segue.identifier == "add_customer_segue" {
            let destViewController = segue.destination as! CustomerController
            destViewController.from_add_invoice = true
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
        }
        if segue.identifier == "send_invoice_segue" {
            let destViewController = segue.destination as! SendInvoiceController
            UserDefaults.standard.set(invoice_id, forKey: "invoice_id")
            
            destViewController.invoice_id = invoice_id
            destViewController.customer_email_var = customerEmail
            destViewController.total = total_amount
            destViewController.from_add_invoice = true
            destViewController.poso_number = posoNumber
        }
        if segue.identifier == "manage_tax_segue" {
            let destViewController = segue.destination as! TaxController
            destViewController.from_add_invoice = false
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
        }
        if segue.identifier == "add_tax_segue" {
            let destViewController = segue.destination as! TaxController
            destViewController.from_add_invoice = true
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
        }
        if segue.identifier == "add_invoice_item_segue" {
            let destViewController = segue.destination as! InvoiceItemController
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
        }
        if segue.identifier == "add_details_segue" {
            let destViewController = segue.destination as! InvoiceDetailsController
            
            destViewController.poso_number = posoNumber ?? ""
            destViewController.project_description = projectName ?? ""
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
        }
        
    }
    func convertDateFormater(_ date: String, format: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "MMM d, y"
        return  dateFormatter.string(from: date!)
    }
    
    @IBAction func send_invoice_tapped(_ sender: Any)
    {
        Common.clearDraftValues()
        var tmpButton = self.view.viewWithTag(8) as? UIButton
        tmpButton?.isEnabled = false
        tmpButton?.backgroundColor = UIColor.gray
        if let note_text = self.view.viewWithTag(1) as? UITextField {
            UserDefaults.standard.set(note_text.text, forKey: "note")
        }
        var customer_id = ""
        var note = ""
        var poso_number = ""
        var description = ""
        var duedate = ""
        if(UserDefaults.standard.string(forKey: "selected_customer_id") != nil) {
            customer_id = UserDefaults.standard.string(forKey: "selected_customer_id")!
        }
        if(UserDefaults.standard.string(forKey: "note") != nil) {
            let note_defaults = UserDefaults.standard.string(forKey: "note") ?? ""
            if(note_defaults != "") {
                note = "\(note_defaults)"
            }
        }
        if(UserDefaults.standard.string(forKey: "poso_number") != nil) {
            poso_number = UserDefaults.standard.string(forKey: "poso_number")!
        }
        if(UserDefaults.standard.string(forKey: "description") != nil) {
            description = UserDefaults.standard.string(forKey: "description")!
        }
        if(UserDefaults.standard.string(forKey: "tax_id") != nil) {
            tax_id = UserDefaults.standard.string(forKey: "tax_id")!
        }
        if(UserDefaults.standard.string(forKey: "due_date") != nil) {
            let duedate_saved = UserDefaults.standard.string(forKey: "due_date") ?? ""
            // current date and time
            let dfmatter = DateFormatter()
            dfmatter.dateFormat = Common.dateFormatSelected
            let date = dfmatter.date(from: duedate_saved)
            let dateStamp:TimeInterval = date!.timeIntervalSince1970
            let dateSt:Int = Int(dateStamp)
            duedate = String(dateSt)
        }
        if(customer_id != "" && poso_number != "" && description != "" && duedate != "" && selected_item_array.count > 0) {
            var customer_id = ""
            var note = ""
            var poso_number = ""
            var description = ""
            var duedate = ""
            if(UserDefaults.standard.string(forKey: "selected_customer_id") != nil) {
                customer_id = UserDefaults.standard.string(forKey: "selected_customer_id")!
            }
            if(UserDefaults.standard.string(forKey: "note") != nil) {
                let note_defaults = UserDefaults.standard.string(forKey: "note") ?? ""
                if(note_defaults != "") {
                    note = "\(note_defaults)"
                }
            }
            if(UserDefaults.standard.string(forKey: "poso_number") != nil) {
                poso_number = UserDefaults.standard.string(forKey: "poso_number")!
            }
            if(UserDefaults.standard.string(forKey: "description") != nil) {
                description = UserDefaults.standard.string(forKey: "description")!
            }
            if(UserDefaults.standard.string(forKey: "due_date") != nil) {
                let duedate_saved = UserDefaults.standard.string(forKey: "due_date") ?? ""
                // current date and time
                let dfmatter = DateFormatter()
                dfmatter.dateFormat = Common.dateFormatSelected
                let date = dfmatter.date(from: duedate_saved)
                let dateStamp:TimeInterval = date!.timeIntervalSince1970
                let dateSt:Int = Int(dateStamp + 86399)
                duedate = String(dateSt)
                due_date = String(dateSt)
            }
            if(selected_item_array.count > 0) {
                saveInvoiceItem()
            } else {
                
            }
        } else {
            tmpButton?.isEnabled = true
            tmpButton?.backgroundColor = UIColor.black
            var error_message_title = Common.required_error_title
            var error_message_text = Common.required_error_text
            if(poso_number == "") {
                error_message_title = "PO/SO Number is required."
                error_message_text = "Please enter PO/SO Number. It is required field."
            } else if(description == "") {
                error_message_title = "Description is required."
                error_message_text = "Please enter description. It is required field."
            } else if(customer_id == "") {
                error_message_title = "Customer is required."
                error_message_text = "Please enter customer. It is required field."
            } else if(duedate == "") {
                error_message_title = "Due date is required."
                error_message_text = "Please enter due date. It is required field."
            } else if(selected_item_array.count <= 0) {
                error_message_title = "Items are required."
                error_message_text = "Please add product. It is required field."
            }/*else if(note == "") {
                error_message_title = "Note is required."
                error_message_text = "Please enter note. It is required field."
            }*/
            self.present(Common.showRequiredErrorAlert(title: error_message_title, content: error_message_text), animated: true)
        }
        
    }
    func handleResponse(data: Data) {
        do{
            print("add inv response \(data.prettyPrintedJSONString)")
            self.invoice_response = try JSONDecoder().decode(InvoiceResponse.self, from: data)
            if(invoice_response.invoice != nil) {
                //self.present(self.showOkAlertWithHandler(title: "Invoive Sent", content: "Your invoice Sent to customer successfully."), animated: true)
                invoice_id = invoice_response.invoice
                SnowplowManager.shared?.track_invoice_action(id: invoice_id, action: "add", status: "draft", purchaseOrder: posoNumber, invoiceDate: invoice_date, dueDate: due_date, subTotal: String(subtotal), totalTax: String(format: "%f", tax_amount_save), total: String(total))
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
    func handleError(error: Error) {
        print(error)
        self.present(Common.showErrorAlert(title: Common.add_error_title, content: Common.add_error_text), animated: true)
    }
    func saveInvoiceItem() {
        var customer_id = ""
        if(UserDefaults.standard.string(forKey: "selected_customer_id") != nil) {
            customer_id = UserDefaults.standard.string(forKey: "selected_customer_id")!
        }
        var invoiceitemInformationObj = [Any]()
        for itemObj in selected_item_array {
            var invItemObj = [String : Any]()
            var qty = itemObj[3] as! Int
            invItemObj["currency"] = UserDefaults.standard.string(forKey: "short_currency") ?? ""
            invItemObj["customer"] = customer_id
            invItemObj["description"] = itemObj[1]  as! String
            invItemObj["price"] = itemObj[6]  as! String
            invItemObj["quantity"] = String(qty)
            
            /*
            invItemObj.append(["currency" , current_currency])
            invItemObj.append(["customer" , customer_id])
            invItemObj.append(["description" , itemObj[1]  as! String])
            invItemObj.append(["price" , itemObj[6]  as! String])
            invItemObj.append(["quantity" , String(qty)])
            */
            //invItemObj.append(["invoiceid" , current_currency])
            invoiceitemInformationObj.append(invItemObj)
            quantity_saved.append(qty)
        }
        let postData =  [
            "multipleInvoice":1,
            "invoiceitemInformation":
                invoiceitemInformationObj
         ] as [String : Any]
        //print(postData)
        let baseurl = (UserDefaults.standard.string(forKey: "api_base_url"))!
        self.serverApiCall(route: ("\(baseurl)/invoiceitem"), method: "POST" , data: postData, responseHandler: handleSaveItemResponse, errorHandler: handleSaveItemError)
    }
    func handleSaveItemResponse(data: Data) {
        do{
            //print("add inv response \(data.prettyPrintedJSONString)")
            let json = try JSON(data: data)
            if let invoiceitems = json["invoiceitem"].array {
                var qty_cnt = 0
                for itms in invoiceitems {
                    //print("item_id \(itms.rawValue) quantity\(quantity_saved[qty_cnt])")
                    SnowplowManager.shared?.track_item_details(itemId: itms.rawValue as! String, quantity: quantity_saved[qty_cnt])
                    qty_cnt = qty_cnt + 1
                }
            }
            saveInvoice()
            
        }catch let decodingEror as DecodingError {
            self.present(Common.showErrorAlert(title: Common.add_error_title, content: Common.add_error_text), animated: true)
            //print("in decoding error \(decodingEror)")
        }catch{
        }
    }
    func handleSaveItemError(error: Error) {
        print(error)
        self.present(Common.showErrorAlert(title: Common.add_error_title, content: Common.add_error_text), animated: true)
    }
    func saveInvoice() {
        var customer_id = ""
        var note = ""
        var poso_number = ""
        var description = ""
        var duedate = ""
        if(UserDefaults.standard.string(forKey: "selected_customer_id") != nil) {
            customer_id = UserDefaults.standard.string(forKey: "selected_customer_id")!
        }
        if(UserDefaults.standard.string(forKey: "note") != nil) {
            let note_defaults = UserDefaults.standard.string(forKey: "note") ?? ""
            if(note_defaults != "") {
                note = "\(note_defaults)"
            }
        }
        if(UserDefaults.standard.string(forKey: "poso_number") != nil) {
            poso_number = UserDefaults.standard.string(forKey: "poso_number")!
        }
        if(UserDefaults.standard.string(forKey: "description") != nil) {
            description = UserDefaults.standard.string(forKey: "description")!
        }
        if(UserDefaults.standard.string(forKey: "tax_id") != nil) {
            tax_id = UserDefaults.standard.string(forKey: "tax_id")!
        }
        if(UserDefaults.standard.string(forKey: "due_date") != nil) {
            let duedate_saved = UserDefaults.standard.string(forKey: "due_date") ?? ""
            // current date and time
            let dfmatter = DateFormatter()
            dfmatter.dateFormat = Common.dateFormatSelected
            let date = dfmatter.date(from: duedate_saved)
            let dateStamp:TimeInterval = date!.timeIntervalSince1970
            let dateSt:Int = Int(dateStamp)
            duedate = String(dateSt)
        }
        if(customer_id != "" && poso_number != "" && description != "" && duedate != "" && selected_item_array.count > 0) {
            var customer_id = ""
            var note = ""
            var poso_number = ""
            var description = ""
            var duedate = ""
            if(UserDefaults.standard.string(forKey: "selected_customer_id") != nil) {
                customer_id = UserDefaults.standard.string(forKey: "selected_customer_id")!
            }
            if(UserDefaults.standard.string(forKey: "note") != nil) {
                let note_defaults = UserDefaults.standard.string(forKey: "note") ?? ""
                if(note_defaults != "") {
                    note = "\(note_defaults)"
                }
            }
            if(UserDefaults.standard.string(forKey: "poso_number") != nil) {
                poso_number = UserDefaults.standard.string(forKey: "poso_number")!
            }
            if(UserDefaults.standard.string(forKey: "description") != nil) {
                description = UserDefaults.standard.string(forKey: "description")!
            }
            if(UserDefaults.standard.string(forKey: "due_date") != nil) {
                let duedate_saved = UserDefaults.standard.string(forKey: "due_date") ?? ""
                // current date and time
                let dfmatter = DateFormatter()
                dfmatter.dateFormat = Common.dateFormatSelected
                let date = dfmatter.date(from: duedate_saved)
                let dateStamp:TimeInterval = date!.timeIntervalSince1970
                let dateSt:Int = Int(dateStamp + 86399)
                duedate = String(dateSt)
                due_date = String(dateSt)
            }
            let postData =  [
                "invoiceInformation":[
                     "customer": customer_id,
                     "description": description,
                     "collection_method":"send_invoice",
                     "due_date":duedate,
                     "default_tax_rates":tax_id,
                     "footer": note,
                     "custom_fields":[[
                           "name":"P.O. Number",
                         "value": poso_number
                     ]]
                 ]
             ] as [String : Any]
            let baseurl = (UserDefaults.standard.string(forKey: "api_base_url"))!
            self.serverApiCall(route: ("\(baseurl)/invoice"), method: "POST" , data: postData, responseHandler: handleResponse, errorHandler: handleError)
        } else {
            var error_message_title = Common.required_error_title
            var error_message_text = Common.required_error_text
            if(poso_number == "") {
                error_message_title = "PO/SO Number is required."
                error_message_text = "Please enter PO/SO Number. It is required field."
            } else if(description == "") {
                error_message_title = "Description is required."
                error_message_text = "Please enter description. It is required field."
            } else if(customer_id == "") {
                error_message_title = "Customer is required."
                error_message_text = "Please enter customer. It is required field."
            } else if(duedate == "") {
                error_message_title = "Due date is required."
                error_message_text = "Please enter due date. It is required field."
            } else if(selected_item_array.count <= 0) {
                error_message_title = "Products are required."
                error_message_text = "Please add product. It is required field."
            }/*else if(note == "") {
                error_message_title = "Note is required."
                error_message_text = "Please enter note. It is required field."
            }*/
            self.present(Common.showRequiredErrorAlert(title: error_message_title, content: error_message_text), animated: true)
        }
    }
    
    @objc func myTextFieldDidChange(_ textField: UITextField) {
        if(textField.tag == 1) {
            if let note_text = self.view.viewWithTag(1) as? UITextField {
                UserDefaults.standard.set(note_text.text, forKey: "note")
            }
        }
        if(textField.tag % 5 == 0) {
            var entered_text = textField.text!
            var row_updated = textField.tag / 5
            if entered_text.isInt {
                if(entered_text.count > 2) {
                    textField.text = String(entered_text.prefix(2))
                }
                if let qty_text = textField.text {
                    var entered_qty = Int(qty_text) ?? 0
                    if(entered_qty != 0) {
                        selected_item_array[row_updated - 1][3] = Int(qty_text) ?? 0
                        UserDefaults.standard.set(selected_item_array, forKey: "updated_qty_array")
                        UserDefaults.standard.set(selected_item_array, forKey: "selected_item")
                        print("on change \(selected_item_array)")
                        updateRow(tag_changed: textField.tag + 1, price: selected_item_array[row_updated - 1][2] as! Double, quantity: Int(qty_text) ?? 0)
                        
                        let indexPath6 = IndexPath(item: 6, section: 0)
                        tableView.reloadRows(at: [indexPath6], with: .top)
                    } else {
                        selected_item_array[row_updated - 1][3] = 0
                        updateRow(tag_changed: textField.tag + 1, price: selected_item_array[row_updated - 1][2] as! Double, quantity: 0)
                        
                        let indexPath6 = IndexPath(item: 6, section: 0)
                        tableView.reloadRows(at: [indexPath6], with: .top)
                    }
                }
            } else {
                selected_item_array[row_updated - 1][3] = 0
                updateRow(tag_changed: textField.tag + 1, price: selected_item_array[row_updated - 1][2] as! Double, quantity: 0)
                let indexPath6 = IndexPath(item: 6, section: 0)
                tableView.reloadRows(at: [indexPath6], with: .top)
                textField.text = ""
            }
            
            //updateCalculations(tag_changed: textField.tag + 1)
        }
        func updateRow(tag_changed: Int, price: Double, quantity: Int) {
            if let label_txt = self.view.viewWithTag(tag_changed) as? UILabel {
                var qty_price = Common.roundTwoDecimal(val: Double(Double(quantity) * (price)))
                label_txt.text = "\(current_currency)\(String(qty_price))"
            }
        }
        
    }
}

class BasicCell: UITableViewCell {
    
    @IBOutlet weak var posoNumber: UILabel!
    @IBOutlet weak var project_name: UILabel!
    //@IBOutlet weak var invoice_lbl: UILabel
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: Common.add_inv_cell_inset)
    }
}
class OtherCell: UITableViewCell {
    
    @IBOutlet weak var container_view: UIView!
    @IBOutlet weak var right_title: UILabel!
    @IBOutlet weak var left_title: UILabel!
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: Common.add_inv_cell_inset)
    }
}
class SubtotalCell: UITableViewCell {
    var actionBlock: (() -> Void)? = nil
    var delete_tax_block: (() -> Void)? = nil
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
    
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view4: UIView!
    @IBOutlet weak var view5: UIView!
    
    @IBOutlet weak var remove_btn: UIButton!
    
    @IBOutlet weak var currency_label: UILabel!
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: Common.add_inv_cell_inset)
    }
    @IBAction func btn_tax_click(_ sender: UIButton) {
        actionBlock?()
    }
    @IBAction func remove_tax(_ sender: Any) {
        delete_tax_block?()
    }
    
    
}
class InvoiceAllItemCell: UITableViewCell {
    @IBOutlet weak var container_view: UIView!
    @IBOutlet weak var item_stack: UIStackView!
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: Common.add_inv_cell_inset)
    }
}
class InvoiceNoteCell: UITableViewCell {
    @IBOutlet weak var note_label: UILabel!
    @IBOutlet weak var container_view: UIView!
    @IBOutlet weak var note_value: UITextField!
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: Common.add_inv_cell_inset)
    }
}
class InvoiceDateCell: UITableViewCell {
    
    @IBOutlet weak var container_view: UIView!
    var dateSelectBlock: (() -> Void)? = nil
    @IBOutlet weak var label_date: UILabel!
    @IBOutlet weak var date_text_field: UITextField!
    
    @IBOutlet weak var date_picker: UIDatePicker!
    
    @IBOutlet weak var left_title: UILabel!
    
    @IBOutlet weak var right_title: UILabel!
    
    @IBOutlet weak var datepic_height: NSLayoutConstraint!
    
    @IBOutlet weak var datepic_width: NSLayoutConstraint!
    
    
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

class ActionCell: UITableViewCell {
    @IBOutlet weak var btn_save: UIButton!
}
class EmptyCell: UITableViewCell {
    
}
class MyRemoveInvoiceTapGesture: UITapGestureRecognizer {
    var invoice_itm_id = String()
}
