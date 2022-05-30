//
//  MyUIViewController.swift
//  WebwarePay
//
//  Created by Vedika on 01/11/21.
//

import UIKit

class MyUIViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() 
        let logo = UIImage(named: "login-logo.png")
        let imageView = UIImageView(image:logo)
        //self.navigationItem.titleView = imageView
        // Do any additional setup after loading the view.
    }
    func setNavigationDefaults() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        self.navigationController?.navigationBar.layer.borderColor = Common.navigation_back_color.cgColor
        self.navigationController?.navigationBar.isTranslucent = false
        
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

}
