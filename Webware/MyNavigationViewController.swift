//
//  MyNavigationViewController.swift
//  WebwarePay
//
//  Created by Vedika on 21/10/21.
//

import UIKit

class MyNavigationViewController: UINavigationController {

    var versionResponse: VersionResponse!
    override func viewDidLoad() {
        super.viewDidLoad()
        var isUpdateChecked = UserDefaults.standard.bool(forKey: "isUpdateChecked") ?? false
        if(!isUpdateChecked) {
            isUpdateAvailable()
        }
    }
    
    func isUpdateAvailable() {
        self.serverDatawareApiCall(route: "todo/version/\(Common.minor_version)", method: "GET", data: "", responseHandler: handleUpdate, errorHandler: errorUpdate)
    }
    func handleUpdate(data: Data) {
        UserDefaults.standard.set(true, forKey: "isUpdateChecked")
        DispatchQueue.global().async {
            do {
                print("upgrade response \(data.prettyPrintedJSONString)")
                self.versionResponse = try JSONDecoder().decode(VersionResponse.self, from: data)
                var update = false
                if(self.versionResponse.response.new_version_available == true) {
                    update = true
                }
                DispatchQueue.main.async {
                    if update{
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let chatVC = storyboard.instantiateViewController(withIdentifier: "upgrade_controller") as! UIViewController
                        self.pushViewController(chatVC, animated: true)
                    } else {
                        
                    }
                }
            } catch {
                print(error)
            }
        }
    }
    func errorUpdate(error: Error) {
        UserDefaults.standard.set(true, forKey: "isUpdateChecked")
    }

}
