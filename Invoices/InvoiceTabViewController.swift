//
//  InvoiceTabViewController.swift
//  WebwarePay
//
//  Created by Vedika on 19/10/21.
//

import UIKit

class InvoiceTabViewController: UIViewController {

    //let storyboard = UIStoryboard
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        // Instantiate the separate storyboard for First section and load it
        let storyboard = UIStoryboard(name: "Invoice", bundle: nil)
        let controller = storyboard.instantiateInitialViewController()!
        addChild(controller)
        view.addSubview(controller.view)
        controller.didMove(toParent: self)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: .add, style: .plain, target: self, action: #selector(addTapped))
        // Do any additional setup after loading the view.
        print("in invoice tab")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func addTapped() {
        let storyboard = UIStoryboard(name: "Invoice", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "add_invoice") as! AddInvoiceViewController
        navigationController?.present(vc, animated: true, completion: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "add_invoice" {
            let vc = segue.destination as! AddInvoiceViewController
        }
    }
}
