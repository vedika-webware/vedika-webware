//
//  MeetingController.swift
//  WebwareTest2
//
//  Created by Rakesh Kamat on 26/08/19.
//  Copyright © 2019 Webware.io. All rights reserved.
//

import UIKit
import Intercom
struct ManagerLinks: Decodable {
    let status: Int
    let message: String
    let response: [Meeting]
}

struct Meeting: Decodable {
    let book_a_meeting_link: String
    let type_of_meeting: String
    let description: String
}

class BookAMeetingController: MyUIViewController {
    
    var managerLinks : ManagerLinks?
    var selectedMeetingType = ""
    var show_logout = true
    @IBAction func logoutAction(_ sender: Any) {
        Common.logout(v: self)
    }
    
    @IBAction func backAction(_ sender: Any) {
        performSegue(withIdentifier: "meeting_to_support_segue", sender: self)
    }
    
    @IBAction func meeting11Action(_ sender: Any) {
        self.bookAMeeting(meetingType: "Change Requests")
    }
    
    @IBAction func meeting12Action(_ sender: Any) {
        self.bookAMeeting(meetingType: "Billing Queries")
    }
    
    @IBAction func meeting21Action(_ sender: Any) {
        self.bookAMeeting(meetingType: "Technical Issues")
    }

    @IBAction func meetingTechnical(_ sender: Any) {
        self.bookAMeeting(meetingType: "Technical Issues")
    }
    @IBAction func meeting22Action(_ sender: Any) {
        self.bookAMeeting(meetingType: "Cancel my Account")
    }
    
    func bookAMeeting(meetingType: String){
        if(self.managerLinks == nil){
            self.present(Common.showOkAlert(title: "Error: Possible network issues", content: "Please check your internet connection. Please try again later"), animated: true)
        }else{
            selectedMeetingType = meetingType
            performSegue(withIdentifier: "meeting_detail_segue", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearBadgeserver()
        let logo = UIImage(named: "login-logo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        if(show_logout == true) {
            let logoutButton   = UIBarButtonItem(title: "Logout" ,  style: .plain, target: self, action: #selector(logoutTapped))
            navigationItem.rightBarButtonItems = [logoutButton]
        }
        self.setNavigationDefaults()
        self.getMeetingLinks()
        //SnowplowManager.shared?.trackCustomScreenViewEvent(screenName:currentViewController() ?? "", previousScreenName: backViewController() ?? "")
        
    }
    func clearBadgelocal(){
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    func clearBadgeserver(){
        UIApplication.shared.applicationIconBadgeNumber = 0
        var email =  (UserDefaults.standard.string(forKey: "user_email"))!
        print("/badgeclear/\(email)")
        self.serverDatawareApiCall(route: ("badgeclear/\(email)"), method: "GET", data: "", responseHandler: handleBadgeResponse, errorHandler: handleBadgeError)
    }
    func handleBadgeResponse(data: Data) {
        do{
            print("badge response \(data.prettyPrintedJSONString)")
        }catch let decodingEror as DecodingError {
        }catch{
        }
    }
    func handleBadgeError(error: Error) {

    }
    override func viewDidAppear(_ animated: Bool) {
        clearBadgelocal()
        if(self.tabBarController?.selectedIndex == 1) {
            Intercom.presentMessenger()
        }
        self.navigationController?.navigationBar.tintColor = UIColor(red: 0.95, green: 0.37, blue: 0.15, alpha: 1.00)
        
    }
    @objc func logoutTapped() {
        Common.logout(v: self)
    }
    //func
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "meeting_detail_segue" {
            let vc = segue.destination as! MeetingDetailsController
            vc.show_logout = show_logout
            for meeting in self.managerLinks!.response{
                if(meeting.type_of_meeting == self.selectedMeetingType){
                    vc.meeting = meeting
                    break
                }
            }
            /*vc.meetingDescription = "Meeting description will come here. Meeting description will come here. Meeting description will come here. Meeting description will come here."
            vc.meetingLink = ""*/
        }
    }
    
    func getMeetingLinks(){
        self.serverDatawareApiCall(route: ("todo/meeting_links"), method: "GET", data: "", responseHandler: handleResponse, errorHandler: handleError)
    }
    func handleResponse(data: Data) {
        do{
            self.managerLinks = try JSONDecoder().decode(ManagerLinks.self, from: data)
            //SnowplowManager.shared?.track_invoice_list(type: selectedListType, invoiceids: invoiceIds)
           
        }catch let decodingEror as DecodingError {
            
        }catch{
            
        }
    }
    func handleError(error: Error) {

    }
}
