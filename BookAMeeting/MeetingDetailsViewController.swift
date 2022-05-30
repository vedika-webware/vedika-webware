//
//  MeetingDetailsController.swift
//  WebwareTest2
//
//  Created by Rakesh Kamat on 26/08/19.
//  Copyright © 2019 Webware.io. All rights reserved.
//

import UIKit

class MeetingDetailsController: MyUIViewController {
    
    var meeting: Meeting!
    var show_logout = true
    @IBOutlet weak var descriptionText: UITextView!
    
    @IBOutlet weak var meetingImage: UIImageView!
    
    @IBOutlet weak var meetingTitle: UILabel!
    @IBAction func backAction(_ sender: Any) {
        performSegue(withIdentifier: "back_to_meetings", sender: self)
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        Common.logout(v: self)
    }
    
    @IBOutlet weak var bookNow: UIButton!
    @IBAction func bookAction(_ sender: Any) {
        performSegue(withIdentifier: "book_meeting_segue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationDefaults()
        meetingTitle.text = meeting.type_of_meeting
        descriptionText.text = meeting.description
        var meeting_info = ""
        if(meeting.type_of_meeting == "Change Requests"){
            meetingImage.image = UIImage(named: "meeting_details1")
            meeting_info = "Other"
        }
        if(meeting.type_of_meeting == "Billing Queries"){
            meetingImage.image = UIImage(named: "meeting_details2")
            meeting_info = "Billing Inquiries"
        }
        if(meeting.type_of_meeting == "Technical Issues"){
            meetingImage.image = UIImage(named: "meeting_details3")
            meeting_info = "Technical Difficulties"
        }
        let logo = UIImage(named: "login-logo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        if(show_logout == true) {
            let logoutButton   = UIBarButtonItem(title: "Logout" ,  style: .plain, target: self, action: #selector(logoutTapped))
            navigationItem.rightBarButtonItems = [logoutButton]
        }
        SnowplowManager.shared?.track_book_a_meeting(reason: meeting_info, details: "\(meeting.type_of_meeting) this type of meeting selected.", date: "", time: 0)
        bookNow.layer.cornerRadius = 8
        //SnowplowManager.shared?.trackCustomScreenViewEvent(screenName:currentViewController() ?? "", previousScreenName: backViewController() ?? "")
    }
    @objc func logoutTapped() {
        Common.logout(v: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "book_meeting_segue" {
            let vc = segue.destination as! BookMeetingViewController
            vc.meeting = self.meeting
            vc.show_logout = show_logout
        }
    }
}
