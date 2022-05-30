//
//  UpgradeController.swift
//  WebwareConcierge
//
//  Created by Vedika Bapat on 30/01/20.
//  Copyright © 2020 Webware.io. All rights reserved.
//

import UIKit

class UpgradeController: MyUIViewController {

    @IBOutlet weak var upgradeText: UITextView!
    var upgradetext:String!
    override func viewDidLoad() {
        //checkUpdate()
        super.viewDidLoad()
        upgradeText.layer.cornerRadius = 10;
        upgradeText.layer.masksToBounds = true;
        //upgradeText.text = upgradetext
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
        self.setNavigationToWhite()
    }
    
    @IBAction func upgradeBtn(_ sender: Any) {
        if let url = URL(string: "itms-apps://itunes.apple.com/app/apple-store/id375380948?mt=8"),
            UIApplication.shared.canOpenURL(url){
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:]) { (opened) in
                    if(opened){
                        //print("App Store Opened")
                    }
                }
            } else {
                // Fallback on earlier versions
            }
        } else {
            //print("Can't Open URL on Simulator")
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
