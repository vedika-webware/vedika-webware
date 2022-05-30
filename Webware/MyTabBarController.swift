//
//  MyTabBarController.swift
//  WebwarePay
//
//  Created by Vedika on 29/12/21.
//

import UIKit
import Intercom
class MyTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTabs()
    }
    
    func loadTabs()  {
        var webware_pay_enabled = UserDefaults.standard.bool(forKey: "has_invoice_enabled")
        var is_stripe_connected = UserDefaults.standard.bool(forKey: "is_stripe_connected")
        if(webware_pay_enabled) {
            if(is_stripe_connected == true) {
                guard let vc1 = storyboard?.instantiateViewController(withIdentifier: "invoice"),
                      let vc2 = storyboard?.instantiateViewController(withIdentifier: "customer"),
                      let vc3 = storyboard?.instantiateViewController(withIdentifier: "item"),
                      let vc4 = storyboard?.instantiateViewController(withIdentifier: "more")
                else
                {
                    return
                }
                UITabBar.appearance().barTintColor = UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 0.9)
                
                setViewControllers([vc1, vc2, vc3, vc4], animated: true)
            } else {
                guard let vc1 = storyboard?.instantiateViewController(withIdentifier: "bookameeting"),
                      let vc2 = storyboard?.instantiateViewController(withIdentifier: "chatwithus"),
                      let vc3 = storyboard?.instantiateViewController(withIdentifier: "discover"),
                      let vc4 = storyboard?.instantiateViewController(withIdentifier: "webwarepay")
                else
                {
                    return
                }
                setViewControllers([vc1, vc2, vc3, vc4], animated: true)
                self.selectedViewController = vc4
            }
        } else {
            guard let vc1 = storyboard?.instantiateViewController(withIdentifier: "bookameeting"),
                  let vc2 = storyboard?.instantiateViewController(withIdentifier: "chatwithus"),
                  let vc3 = storyboard?.instantiateViewController(withIdentifier: "discover")
            else
            {
                return
            }

            setViewControllers([vc1, vc2, vc3], animated: true)
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

    // UITabBarDelegate
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        Common.clearSavedValues()
        let myView = self.viewControllers![self.selectedIndex] as! UINavigationController
        myView.popToRootViewController(animated:false)
        //if(self.selectedIndex == 1) {
            //Intercom.presentMessenger()
        //}
    }
}
