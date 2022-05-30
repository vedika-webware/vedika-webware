//
//  InvoiceDetailsController.swift
//  WebwarePay
//
//  Created by Vedika on 28/10/21.
//

import UIKit

class InvoiceDetailsController: MyTableViewController, UITextViewDelegate {

    var fromEditInvoice = false
    var invoice_id = ""
    var poso_number = ""
    var project_description = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Invoice Details"
        self.tableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
        let button1 = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.saveInvoice))
        self.navigationItem.rightBarButtonItem  = button1
        self.tabBarController?.selectedIndex = 0
        self.setNavigationToWhite()
    }
    
    @objc func saveInvoice(){
        if(fromEditInvoice == false) {
            performSegue(withIdentifier: "save_invoice_details", sender: self)
        } else {
            performSegue(withIdentifier: "back_to_edit_segue", sender: self)
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*if(indexPath.row == 1) {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "other_info", for: indexPath) as! InvoiceDetilsOtherCell
            cell1.left_label.text = "Invoice Title"
            return cell1
        } else if(indexPath.row == 2) {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "other_info", for: indexPath) as! InvoiceDetilsOtherCell
            cell1.left_label.text = "Invoice Number"
            return cell1
        } else */if(indexPath.row == 1) {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "other_info", for: indexPath) as! InvoiceDetilsOtherCell
            if(poso_number != "") {
                cell1.text_field.text = poso_number
            }
            let border_color = UIColor.white
            cell1.text_field.layer.borderColor = border_color.cgColor
            cell1.text_field.layer.borderWidth = 0
            cell1.text_field.tag = indexPath.row
            cell1.text_field.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)
            //cell1.left_label.text = "P.O. / S.O. Number"
            return cell1
        } else if(indexPath.row == 3) {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "project_name", for: indexPath) as! InvoiceProjectNameCell
            /*let color = UIColor(red: 186/255, green: 186/255, blue: 186/255, alpha: 1.0).cgColor
            cell1.project_name_desc.layer.borderColor = color
            cell1.project_name_desc.layer.borderWidth = 0.5*/
            cell1.project_name_desc.layer.cornerRadius = 8
            cell1.project_name_desc.tag = indexPath.row
            cell1.project_name_desc.delegate = self
            cell1.project_name_desc.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            if(project_description != "") {
                cell1.project_name_desc.text = project_description
            }
            //cell1.project_name_desc.delegate = self
            return cell1
        } else {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "empty_cell", for: indexPath) as! InvoiceDetilsEmptyCell
            return cell1
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(textView.tag == 3) {
            let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
            let numberOfChars = newText.count
            return numberOfChars < 200
        } else {
            return true
        }
    }
    @objc func myTextFieldDidChange(_ textField: UITextField) {
        if(textField.tag == 1) {
            var limit = 20
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
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 3 {
            return 120
        } else if (indexPath.row == 0 || indexPath.row == 2){
            return 30
        } else {
            return UITableView.automaticDimension
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "save_invoice_details") {
            let posoNumberRow = IndexPath(row: 1, section: 0)
            let posoNumber: InvoiceDetilsOtherCell = self.tableView.cellForRow(at: posoNumberRow) as! InvoiceDetilsOtherCell
            let descriptionRow = IndexPath(row: 3, section: 0)
            let description: InvoiceProjectNameCell = self.tableView.cellForRow(at: descriptionRow) as! InvoiceProjectNameCell
            
            if(posoNumber.text_field.text != "" && description.project_name_desc.text != "") {
                let vc = segue.destination as! AddInvoiceController
                vc.posoNumber = posoNumber.text_field.text
                vc.projectName = description.project_name_desc.text
                UserDefaults.standard.set(posoNumber.text_field.text, forKey: "poso_number")
                UserDefaults.standard.set(description.project_name_desc.text, forKey: "description")
                SnowplowManager.shared?.track_invoice_details(name: description.project_name_desc.text!, poNumber: posoNumber.text_field.text!)
            } else {
                self.present(Common.showRequiredErrorAlert(title: Common.required_error_title, content: Common.required_error_text), animated: true)
            }
            
        }
        if(segue.identifier == "back_to_edit_segue") {
            let posoNumberRow = IndexPath(row: 1, section: 0)
            let posoNumber: InvoiceDetilsOtherCell = self.tableView.cellForRow(at: posoNumberRow) as! InvoiceDetilsOtherCell
            let descriptionRow = IndexPath(row: 3, section: 0)
            let description: InvoiceProjectNameCell = self.tableView.cellForRow(at: descriptionRow) as! InvoiceProjectNameCell
            if(posoNumber.text_field.text != "" && description.project_name_desc.text != "") {
                let vc = segue.destination as! EditInvoiceController
                vc.posoNumber = posoNumber.text_field.text
                vc.projectName = description.project_name_desc.text
                vc.invoice_id = invoice_id
                UserDefaults.standard.set(posoNumber.text_field.text, forKey: "poso_number")
                UserDefaults.standard.set(description.project_name_desc.text, forKey: "description")
            } else {
                self.present(Common.showRequiredErrorAlert(title: Common.required_error_title, content: Common.required_error_text), animated: true)
            }
            
            
        }
        
    }
}
class InvoiceDetilsOtherCell: UITableViewCell {
    @IBOutlet weak var text_field: UITextField!
    @IBOutlet weak var left_label: UILabel!
}
class InvoiceProjectNameCell: UITableViewCell {
    
    @IBOutlet weak var project_name_desc: UITextView!
}
class InvoiceDetilsEmptyCell: UITableViewCell {
    
}
