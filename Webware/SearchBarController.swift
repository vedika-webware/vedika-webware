//
//  SearchBarController.swift
//  WebwarePay
//
//  Created by Vedika on 08/11/21.
//

import UIKit

extension UISearchBar {
    func setDetaults() {
        //self.becomeFirstResponder()
        self.barTintColor = UIColor.init(hex: "#BC214B")
        self.tintColor = UIColor.black
        // Show/Hide Cancel Button
        self.showsCancelButton = false
        // Change TextField Colors
        let searchTextField = self.searchTextField
        //searchTextField.textColor = UIColor.white
        searchTextField.text = ""
        searchTextField.clearButtonMode = .never
        searchTextField.backgroundColor = UIColor(red: 0.46, green: 0.46, blue: 0.50, alpha: 0.12) //UIColor.init(hex: "#3C3C43")
        // Change Glass Icon Color
        let glassIconView = searchTextField.leftView as! UIImageView
        glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
        glassIconView.tintColor = UIColor(red: 0.24, green: 0.24, blue: 0.26, alpha: 0.6)
        self.keyboardAppearance = .dark
    }
    
}

