//
//  MyTableViewController.swift
//  WebwarePay
//
//  Created by Vedika on 01/11/21.
//

import UIKit

class MyTableViewController: UITableViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() 
        let logo = UIImage(named: "login-logo.png")
        let imageView = UIImageView(image:logo)
        //self.navigationItem.titleView = imageView
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var entered_text = textField.text!
        if entered_text.isInt {
            
        } else if(entered_text.count > 2) {
            textField.text = String(entered_text.prefix(2))
        } else {
            textField.text = ""
        }
        let s = NSString(string: textField.text ?? "").replacingCharacters(in: range, with: string)
        guard !s.isEmpty else { return true }
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .none
        return numberFormatter.number(from: s)?.intValue != nil
    }
    
    @objc func valueChanged(_ textField: UITextField){
        var entered_text = textField.text!
        if entered_text.isInt {
            
        } else {
            textField.text = ""
        }
    }
    @objc func valueChangedToNumber(_ textField: UITextField){
        var entered_text = textField.text!
        if entered_text.isInt {
            
        } else if(entered_text.count > 2) {
            textField.text = String(entered_text.prefix(2))
        } else {
            textField.text = ""
        }
    }
    func setNavigationDefaults() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        self.navigationController?.navigationBar.layer.borderColor = Common.navigation_back_color.cgColor
        self.navigationController?.navigationBar.isTranslucent = false
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.shadowImage = UIImage()
            appearance.backgroundImage = UIImage()
            appearance.backgroundColor = Common.navigation_back_color
            self.navigationController?.navigationBar.standardAppearance = appearance;
            self.navigationController?.navigationBar.scrollEdgeAppearance = self.navigationController?.navigationBar.standardAppearance
        } else {
            self.navigationController?.navigationBar.barTintColor = Common.navigation_back_color
        }
        self.navigationController?.setStatusBarColor(backgroundColor: Common.navigation_back_color)
    }
    func setNavigationToWhite() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        self.navigationController?.navigationBar.layer.borderColor = Common.navigation_white_color.cgColor
        self.navigationController?.navigationBar.isTranslucent = false
        
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.shadowImage = UIImage()
            appearance.backgroundImage = UIImage()
            appearance.backgroundColor = Common.navigation_white_color
            self.navigationController?.navigationBar.standardAppearance = appearance;
            self.navigationController?.navigationBar.scrollEdgeAppearance = self.navigationController?.navigationBar.standardAppearance
        } else {
            self.navigationController?.navigationBar.barTintColor = Common.navigation_white_color
        }
        self.navigationController?.setStatusBarColor(backgroundColor: Common.navigation_white_color)
    }
    func addDoneToolBarToKeyboardSearch(textView:UISearchTextField)
    {
        textView.returnKeyType = .default
        let doneToolbar : UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        let flexibelSpaceItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let hideKeyboardItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.dismissKeyboard))
        doneToolbar.items = [flexibelSpaceItem, hideKeyboardItem]
        doneToolbar.sizeToFit()
        textView.inputAccessoryView = doneToolbar
    }

    @objc func dismissKeyboard()
    {
        self.view.endEditing(true)
    }
    
}
