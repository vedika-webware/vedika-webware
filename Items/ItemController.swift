//
//  ItemController.swift
//  WebwarePay
//
//  Created by Vedika on 05/11/21.
//

import UIKit
import SwiftyJSON
class ItemController: MyTableViewController {
    @IBOutlet weak var search_bar: UISearchBar!
    //let refreshControl = UIRefreshControl()
    var itemList = [[String]]()
    var searching = false
    // this is our array of arrays
    var searchedItem = [[String]]()
    var itemNameList = [String]()
    var itemIds = [String]()
    var searchIds = [String]()
    var selected: String?
    var fromAddInvoice = true
    var product_id = ""
    var product_name = ""
    var product_description = ""
    var product_price = 0.0
    var is_edit_click = 0;
    var is_data_loaded = false
    var expandedIndexSet : IndexSet = []
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.title = "Products"
        self.search_bar.delegate = self
        search_bar.backgroundImage = UIImage()
        //addDoneToolBarToKeyboardSearch(textView: search_bar.searchTextField)
        search_bar.setDetaults()
        search_bar.placeholder = "Search by product name or description"
        navigationItem.rightBarButtonItem = getAddButton()
        self.tableView.separatorStyle = .none
        self.tableView.tintColor = UIColor.black
        self.tableView.backgroundColor = UIColor.white
        //self.tabBarController?.selectedIndex = 2
        navigationItem.leftBarButtonItem = UIBarButtonItem()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadData), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refreshControl
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        tableView.separatorColor = Common.separatorColor
        tableView.separatorInset = Common.separatorInsetItem
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        //self.listOfItem()
        self.setNavigationDefaults()
       
    }
    override func viewDidAppear(_ animated: Bool) {
        self.setNavigationDefaults()
        searching = false
        searchedItem.removeAll()
        search_bar.setDetaults()
        search_bar.placeholder = "Search by product name or description"
        self.listOfItem()
        tableView.reloadData()
    }
    @objc func reloadData(_ sender: AnyObject) {
        self.listOfItem()
    }
    @objc func addTapped() {
        is_edit_click = 0
        performSegue(withIdentifier: "add_edit_item_segue", sender: Self.self)
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
                    //print(product)
                    var productObj = [String]()
                    var name = ""
                    var product_price = ""
                    var product_id = ""
                    var price_id = ""
                    var description = ""
                    var CurrencyPrefix = ""
                    for field in product {
                        if(field.0 == "Name") {
                            //name = field.1.string ?? ""
                            if var x = field.1.rawValue as? Int{
                                name = String(x)
                            } else if var x = field.1.rawValue as? String{
                                name = field.1.rawValue as! String
                            }
                            name = name.crop_string(length: Common.product_name_maxlength)
                            itemNameList.append(name.capitalizingFirstLetter() ?? "")
                        }
                        if(field.0 == "UnitAmount") {
                            let price : Double = field.1.rawValue as! Double
                            let pricestring = String(Double(Common.roundTwoDecimal(val: price) / 100))
                            product_price = pricestring
                        }
                        if(field.0 == "Description") {
                            description = field.1.string?.capitalizingFirstLetter() ?? ""
                            //description = description.crop_string(length: Common.product_desc_maxlength)
                        }
                        if(field.0 == "DESCRIPTION" && description == "") {
                            description = field.1.string?.capitalizingFirstLetter() ?? ""
                            //description = description.crop_string(length: Common.product_desc_maxlength)
                        }
                        if(field.0 == "Id") {
                            product_id = field.1.string ?? ""
                        }
                        if(field.0 == "PriceID") {
                            price_id = field.1.string ?? ""
                        }
                        if(field.0 == "CurrencyPrefix") {
                            CurrencyPrefix = String(htmlEncodedString: field.1.string ?? "") ?? ""
                        }
                    }
                    productObj.append(name.capitalizingFirstLetter())
                    productObj.append(product_id)
                    productObj.append(product_price)
                    productObj.append(price_id)
                    productObj.append(description)
                    productObj.append(CurrencyPrefix)
                    if(productObj != nil) {
                        itemList.append(productObj)
                        itemIds.append(product_id)
                    }
                }
            }
            //print(itemList)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "add_edit_item_segue" {
            if(is_edit_click == 1) {
                let destViewController = segue.destination as! EditItemViewController
                destViewController.product_name = product_name
                destViewController.product_description = product_description
                destViewController.product_price = Double(Int(product_price))
                destViewController.product_id = product_id
                destViewController.fromEditItem = true
                let backItem = UIBarButtonItem()
                backItem.title = "Cancel"
                navigationItem.backBarButtonItem = backItem
            } else {
                let destViewController = segue.destination as! EditItemViewController
                destViewController.fromEditItem = false
                let backItem = UIBarButtonItem()
                backItem.title = "Cancel"
                navigationItem.backBarButtonItem = backItem
            }
        }
        if(segue.identifier == "clone_segue") {
            let destViewController = segue.destination as! EditItemViewController
            destViewController.fromEditItem = false
            destViewController.fromCloneItem = true
            destViewController.product_name = product_name
            destViewController.product_description = product_description
            destViewController.product_price = Double(product_price)
            let backItem = UIBarButtonItem()
            backItem.title = "Cancel"
            navigationItem.backBarButtonItem = backItem
        }
    }

}
class ItemCell: UITableViewCell {
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    var cloneBlock: (() -> Void)? = nil
    //@IBOutlet weak var label4: UILabel!
    private lazy var maskLayer = CAShapeLayer()
    @IBOutlet weak var label_height: NSLayoutConstraint!
    /*
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: Common.table_content_inset)
    }*/
    @IBAction func clone_btn(_ sender: UIButton) {
        cloneBlock?()
    }
    
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
            cornerRadii: CGSize(width: 20, height:  20)
        )
        maskLayer.path = path.cgPath
        contentView.clipsToBounds = true
        //maskLayer.masksToBounds = true
        layer.mask = maskLayer
    }
 
}

class RoundedItemCell: UITableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: Common.table_content_inset)
    }
}

extension ItemController {
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "no_item", for: indexPath) as! NoItemCell
            cell.separatorInset = UIEdgeInsets(top: 0.0, left: cell.bounds.size.width, bottom: 0.0, right: 0.0);
            cell.contentView.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10.0)
            cell.contentView.dropShadow()
            return cell
        } else {
            //print(searching)
            //print(searchedItem.count)
            //no_search_result
            if(searching == true && searchedItem.count <= 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "no_search_result", for: indexPath) as! NoSearchItemCell
                return cell
            } else {
                if(indexPath.row == 0) {
                    //if(itemList.count == 1 || searchedItem.count == 1) {
                        
                    //} else {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "rounded_cell", for: indexPath) as! RoundedItemCell
                        cell.separatorInset = UIEdgeInsets(top: 0.0, left: cell.bounds.size.width, bottom: 0.0, right: 0.0);
                        cell.contentView.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
                        return cell
                    //}
                } else if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "rounded_cell", for: indexPath) as! RoundedItemCell
                    cell.contentView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 10.0)
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "item", for: indexPath) as! ItemCell
                    if expandedIndexSet.contains(indexPath.row) {
                        cell.label2.numberOfLines = 0
                        cell.label1.numberOfLines = 0
                    } else {
                        cell.label2.numberOfLines = 1
                        cell.label1.numberOfLines = 1
                    }
                    if indexPath.row == itemList.count ||  indexPath.row == searchedItem.count {
                        cell.separatorInset = UIEdgeInsets(top: 0.0, left: cell.bounds.size.width, bottom: 0.0, right: 0.0);
                    } else {
                        cell.separatorInset = Common.separatorInsetItem
                    }
                    if searching {
                        var row_current = indexPath.row - 1
                        if(searchedItem.indices.contains(row_current)) {
                            cell.label1.text = searchedItem[row_current][0]
                            var desc = "-"
                            if(searchedItem[row_current][4] != "") {
                                desc = searchedItem[row_current][4]
                            }
                            cell.label2.text = desc
                            //cell.label2.sizeToFit()
                            cell.label3.text =  ("\(searchedItem[row_current][5])\(searchedItem[row_current][2])")
                            cell.cloneBlock = { [self] in
                                product_name = searchedItem[row_current][0]
                                product_description = desc
                                product_price = Double(searchedItem[row_current][2])!
                                self.performSegue(withIdentifier: "clone_segue", sender: Self.self)
                            }
                        }
                    } else {
                        var row_current = indexPath.row - 1
                        if(itemList.indices.contains(row_current)) {
                            print(itemList)
                            cell.label1.text = itemList[row_current][0]
                            var desc = "-"
                            if(itemList[row_current][4] != "") {
                                desc = itemList[row_current][4]
                            }
                            cell.label2.text = desc
                            //cell.label2.sizeToFit()
                            cell.label3.text = ("\(itemList[row_current][5])\(itemList[row_current][2])")
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
            }
            /*
            if(indexPath.row == 0) {
                if(itemList.count == 1 || searchedItem.count == 1) {
                    //cell.corners = [.topLeft, .topRight, .bottomLeft, .bottomRight]
                    cell.contentView.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10.0)
                } else {
                    //cell.corners = [.topLeft, .topRight]
                    cell.contentView.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
                }
            } else if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
                cell.contentView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 10.0)
            } else {
                //cell.contentView.roundCorners(corners: [.bottomRight], radius: 1.0)
            }
             */
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "item", for: indexPath) as! ItemCell
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        if(expandedIndexSet.contains(indexPath.row)){
            expandedIndexSet.remove(indexPath.row)
        } else {
            expandedIndexSet.insert(indexPath.row)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
        /*
        if(indexPath.row != 0 && indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1) {
            let currentCell = tableView.cellForRow(at: indexPath) as! ItemCell
            product_name = currentCell.label1.text!
            product_description = currentCell.label2.text!
            product_price = Int(currentCell.label3.text!) ?? 0
            product_id = itemList[indexPath.row][1]
            is_edit_click = 1
            //performSegue(withIdentifier: "add_edit_item_segue", sender: Self.self)
        }
        */
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(itemList.count <= 0) {
            return 320
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func getAddButton() -> UIBarButtonItem {
        //create a new button
        let button: UIButton = UIButton(type: UIButton.ButtonType.custom) 
        //set image for button
        button.setImage(UIImage(named: "add_invoice.png"), for: .normal)
        //add function for button
        button.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: -10)
        button.addTarget(self, action: #selector(self.addTapped), for: .touchUpInside)
        //set frame
        let barButton = UIBarButtonItem(customView: button)
        //assign button to navigationbar
        return barButton
    }
}
extension ItemController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.count > 0) {
            searching = true
            searchedItem = itemList.filter { (dataArray:[String]) -> Bool in
                return dataArray.filter({ (string) -> Bool in
                    return string.lowercased().contains(searchText.lowercased())
                }).count > 0
            }
            //print(searchedItem)
            for searchId in searchedItem {
                searchIds.append(searchId[0])
            }
            //SnowplowManager.shared?.track_item_list(search: searchText, itemIds: searchIds)
            SnowplowManager.shared?.track_item_list(search: "", itemIds: searchIds)
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
class NoItemCell: UITableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: Common.table_content_inset)
    }
}
class NoSearchItemCell: UITableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: Common.table_content_inset)
    }
}
class ItemListEmptyCell: UITableViewCell {
    
}
