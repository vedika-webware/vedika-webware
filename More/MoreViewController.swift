//
//  MoreViewController.swift
//  WebwarePay
//
//  Created by Vedika on 01/12/21.
//

import UIKit
import Intercom
class MoreViewController: MyTableViewController {
    @IBOutlet weak var table_header: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableHeaderView = table_header
        tableView.tableFooterView = UIView()
        //self.tableView.layer.cornerRadius = 10.0
        //self.title = "More"
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        tableView.separatorColor = Common.separatorColor
        tableView.separatorInset = Common.separatorInsetMore
        self.setNavigationDefaults()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    override func viewDidAppear(_ animated: Bool) {
        self.setNavigationDefaults()
        tableView.reloadData()
        let indexPath = IndexPath(item: 4, section: 0)
        tableView.scrollToRow(at: indexPath, at: .none, animated: false)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "title_more_info", for: indexPath) as! TitleMoreCell
        if(indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "title_more_info", for: indexPath) as! TitleMoreCell
            cell.label_link.text = "WHAT CAN WE HELP YOU WITH"
            cell.label_link.font = UIFont.systemFont(ofSize: 12.0)
            cell.container_view.backgroundColor = UIColor.white
            cell.contentView.backgroundColor = UIColor.white
            cell.arrow.isHidden = true
            cell.separatorInset = UIEdgeInsets(top: 0.0, left: tableView.bounds.size.width, bottom: 0.0, right: 0.0);
            return cell
        } else if(indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "more_info", for: indexPath) as! MoreCell
            cell.label_link.addTextWithImageForMore(text: " Logout",image: UIImage(named: "logout")!,imageBehindText: false,keepPreviousText: false)
            cell.contentView.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
            cell.arrow.isHidden = true
            cell.separatorInset = Common.separatorInsetMore
            return cell
        } else if(indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "more_info", for: indexPath) as! MoreCell
            cell.label_link.addTextWithImageForMore(text: " Book A Meeting",image: UIImage(named: "more_meeting")!,imageBehindText: false,keepPreviousText: false)
            cell.separatorInset = Common.separatorInsetMore
            cell.arrow.isHidden = false
            return cell
        } else if(indexPath.row == 3) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "more_info", for: indexPath) as! MoreCell
            cell.label_link.addTextWithImageForMore(text: " Chat With Us",image: UIImage(named: "more_chat")!,imageBehindText: false,keepPreviousText: false)
            cell.separatorInset = Common.separatorInsetMore
            cell.arrow.isHidden = false
            return cell
        } else if(indexPath.row == 4) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "more_info", for: indexPath) as! MoreCell
            cell.label_link.addTextWithImageForMore(text: " Discover",image: UIImage(named: "more_discover")!,imageBehindText: false,keepPreviousText: false)
            cell.contentView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 10.0)
            cell.separatorInset = UIEdgeInsets(top: 0.0, left: tableView.bounds.size.width, bottom: 0.0, right: 0.0);
            cell.arrow.isHidden = false
            return cell
        } else if(indexPath.row == 5) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "title_more_info", for: indexPath) as! TitleMoreCell
            cell.label_link.text = ""
            cell.container_view.backgroundColor = UIColor.white
            cell.contentView.backgroundColor = UIColor.white
            cell.arrow.isHidden = true
            cell.separatorInset = UIEdgeInsets(top: 0.0, left: tableView.bounds.size.width, bottom: 0.0, right: 0.0);
            return cell
        }
        
        
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 1) {
            Common.logout(v: self)
        } else if(indexPath.row == 2) {
            performSegue(withIdentifier: "book_a_meeting", sender: self)
        } else if(indexPath.row == 3) {
            Intercom.presentMessenger()
        } else if(indexPath.row == 4) {
            performSegue(withIdentifier: "discover", sender: self)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "book_a_meeting" {
            let destViewController = segue.destination as! BookAMeetingController
            destViewController.show_logout = false
        }
        if segue.identifier == "discover" {
            let destViewController = segue.destination as! DiscoverController
            destViewController.show_logout = false
        }
        
        
    }

}
class MoreCell: UITableViewCell {
    @IBOutlet weak var label_link: UILabel!
    @IBOutlet weak var container_view: UIView!
    private lazy var maskLayer = CAShapeLayer()
    //override func layoutSubviews() {
        //super.layoutSubviews()
        //contentView.frame = contentView.frame.inset(by: Common.table_content_inset)
    //}
    var corners: UIRectCorner = [] {
        didSet {
            setNeedsLayout()
            updatePath(with: corners)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: Common.table_content_inset)
        //updatePath(with: corners)
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
    @IBOutlet weak var arrow: UIImageView!
    

}
class TitleMoreCell: UITableViewCell {
    @IBOutlet weak var label_link: UILabel!
    @IBOutlet weak var container_view: UIView!
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: Common.table_content_inset)
    }
    
    @IBOutlet weak var arrow: UIImageView!
    

}
