//
//  MoreTabViewController.swift
//  WebwarePay
//
//  Created by Vedika on 19/10/21.
//

import UIKit

class MoreTabViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Instantiate the separate storyboard for First section and load it
        let storyboard = UIStoryboard(name: "More", bundle: nil)
        let controller = storyboard.instantiateInitialViewController()!
        addChild(controller)
        view.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
