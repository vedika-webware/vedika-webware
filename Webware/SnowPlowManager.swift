//
//  SnowPlowManager.swift
//  WebwareConcierge
//
//  Created by Vedika Bapat on 10/09/20.
//  Copyright © 2020 Webware.io. All rights reserved.
//

import SnowplowTracker

class SnowplowManager: NSObject {
    @objc var tracker: SPTracker?
    static var shared: SnowplowManager? = SnowplowManager.init()
    
    func setTracker() {
        let emitter = SPEmitter.build({ builder in
            builder?.setUrlEndpoint(Common.snowPlowEndPoint)
            builder?.setProtocol(.https) // you can either use http or https
            builder?.setCallback(SPRequestCallback?.init(nilLiteral: (
                //print("here in snowplow callback")
            )))
        
        })
        tracker = SPTracker.build({ builder in
            builder?.setEmitter(emitter) // set the emitter of the tracker
            //builder?.setAppId("webware-ios") // you can track the appId
            builder?.setAppId("WEBWARE-IOS") // you can track the appId
            builder?.setAutotrackScreenViews(true) // these function autotracks all of the screen events with full detail
            builder?.setScreenContext(true) // get screen context like resolutions, width, height
            builder?.setInstallEvent(true) // get events about the first install of the app
            builder?.setApplicationContext(true) // get events about the device, app context
            builder?.setSessionContext(true) // get stats about the current session
            builder?.setLogLevel(.error)
            if let user_id = UserDefaults.standard.string(forKey: "user_id") {
                //print("here in tracker initialise \(user_id)")
                let subject = SPSubject.init(platformContext: true, andGeoContext: true)
                subject?.setUserId(user_id)
                builder?.setSubject(subject) // add subject to the tracker
            }
            builder?.setExceptionEvents(true) // also track exceptional events
            builder?.setLifecycleEvents(true) // these one is tracking the background/foreground stats of the sessions
        })
        
    }
    func trackCustomScreenViewEvent(screenName: String, previousScreenName: String) {
        let event = SPScreenView.build({builder in
            var namespacestr = "WebwarePay"
            builder.setName("\(namespacestr).\(screenName)")
            builder.setScreenId(UUID().uuidString)
            builder.setTopViewControllerClassName("\(namespacestr).\(screenName)")
            builder.setViewControllerClassName("\(namespacestr).\(screenName)")
            builder.setType("Default")
            if(previousScreenName != "") {
                builder.setPreviousScreenName("\(namespacestr).\(previousScreenName)")
            }
        })
        let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? nil
        if accessToken != nil{
            event.contexts.add(self.getSiteEntity())
            event.contexts.add(self.getUserEntity())
            /*
            let json_user = SPSelfDescribingJson(
            schema: "iglu:io.webware/user/jsonschema/1-0-0",
            andData: [
            "id" : UserDefaults.standard.string(forKey: "user_id"),
            "email" : UserDefaults.standard.string(forKey: "user_email"),
            "givenName" : "Rakesh",
            "familyName" : "Kamat",
            "isSubscribed" : true,
            "gender" : "male",
            "groupId" : 2,
            "createdAt" : "2018-11-13T20:20:39+00:00"
            ] as NSObject)
            */
        }
        tracker!.track(event)
    }
    
    func track_pageview(title: String, webpageurl: String) {
        let event = SPPageView.build({ builder in
            builder.setPageTitle(title)
            builder.setPageUrl(webpageurl)
            builder.setContexts([self.getSiteEntity(), self.getUserEntity()])
        })
        
        tracker?.track(event)
    }
    func track_sign_up(phone: String, status: Int, message: String) {
        let signup_data = SPSelfDescribingJson(
        schema: "iglu:io.webware/mobile_signup/jsonschema/1-0-0",
        andData: [
        "phone" : phone,
        "status" : status,
        "message" : message,
            ] as NSObject)
        //print(signup_data)
        let event = SPUnstructured.build({ builder in
            builder.setEventData(signup_data!)
            builder.setContexts([self.getSiteEntity(), self.getUserEntity()])
        })
        tracker!.track(event)
    }
    func track_login(email: String, domain: String, status: Int, message: String) {
        //print("in tracking login")
        let login_data = SPSelfDescribingJson(
        schema: "iglu:io.webware/mobile_login/jsonschema/1-0-0",
        andData: [
        "email" : email,
        "domain" : domain,
        "status" : status,
        "message" : message,
        ] as NSObject)
        let event = SPUnstructured.build({ builder in
            builder.setEventData(login_data!)
            builder.setContexts([self.getSiteEntity(), self.getUserEntity()])
        })
        tracker!.track(event)
    }
    
    func track_project_action(action: String, status: Int, message: String, id: Int, title: String, description: String, reject_reason: String) {
        let project_data = SPSelfDescribingJson(
        schema: "iglu:io.webware/mobile_project/jsonschema/1-0-0",
        andData: [
        "action" : action,
        "status" : status,
        "message" : message,
        ] as NSObject)
        let event = SPUnstructured.build({ builder in
            builder.setEventData(project_data!)
        })
        //print(project_data)
        event.contexts.add(self.getSiteEntity())
        event.contexts.add(self.getUserEntity())
        event.contexts.add(self.getProjectEntity(id: id, title: title, description: description, reject_reason: reject_reason))
        tracker!.track(event)
    }
    
    func track_slot_lookup(reason: String, date: String, slots: [String]) {
        //print(date)
        let slot_data = SPSelfDescribingJson(
        schema: "iglu:io.webware/mobile_lookup_meeting_slots/jsonschema/1-0-0",
        andData: [
        "reason_for_meeting" : reason,
        "date" : date,
        "slots" : slots
        ] as NSObject)
        let event = SPUnstructured.build({ builder in
            builder.setEventData(slot_data!)
        })
        event.contexts.add(self.getSiteEntity())
        event.contexts.add(self.getUserEntity())
        tracker!.track(event)
    }
    
    func track_book_a_meeting(reason: String, details: String, date: String, time: Int) {
        let userId = UserDefaults.standard.string(forKey: "user_id") ?? nil
        if userId != nil{
            let meeting_data = SPSelfDescribingJson(
            schema: "iglu:io.webware/mobile_book_meeting/jsonschema/1-0-0",
            andData: [
                "id" : String(userId!)
            ] as NSObject)
            //print(meeting_data)
            let event = SPUnstructured.build({ builder in
                builder.setEventData(meeting_data!)
            })
            event.contexts.add(self.getSiteEntity())
            event.contexts.add(self.getUserEntity())
            event.contexts.add(self.getMeetingEntity(reason_for_meeting: reason, details: details, date: date, time: time))
            tracker!.track(event)
        }
    }
    
    func track_notification(title: String, details: String) {
        let userId = UserDefaults.standard.string(forKey: "user_id") ?? nil
        if userId != nil{
            let meeting_data = SPSelfDescribingJson(
            schema: "iglu:io.webware/notification_click/jsonschema/1-0-0",
            andData: [
                "title" : title,
                "message" : details
            ] as NSObject)
            //print(meeting_data)
            let event = SPUnstructured.build({ builder in
                builder.setEventData(meeting_data!)
            })
            event.contexts.add(self.getSiteEntity())
            event.contexts.add(self.getUserEntity())
            tracker!.track(event)
        }
    }
    
    func track_invoice_list(type: String, invoiceids: [String]) {
        if let userId = UserDefaults.standard.string(forKey: "user_id") {
            //print("\(userId) in track invoice list \(type)")
            let invoice_data = SPSelfDescribingJson(
            schema: "iglu:io.webware/mobile_invoice_list/jsonschema/1-0-0",
            andData: [
                "status" : type,
                "invoices" : invoiceids
            ] as NSObject)
            //print(invoice_data!)
            let event = SPUnstructured.build({ builder in
                builder.setEventData(invoice_data!)
            })
            //print(self.getSiteEntity())
            //print(self.getUserEntity())
            
            event.contexts.add(self.getSiteEntity())
            event.contexts.add(self.getUserEntity())
            tracker!.track(event)
            //print(resp)
        }
    }
    func track_invoice_details(name: String, poNumber: String) {
        let userId = UserDefaults.standard.string(forKey: "user_id") ?? nil
        if userId != nil{
            //print("in track_invoice_details \(name) and \(poNumber)")
            let invoice_data = SPSelfDescribingJson(
            schema: "iglu:io.webware/mobile_invoice_details_added/jsonschema/1-0-0",
            andData: [
                "name" : name,
                "poNumber" : poNumber
            ] as NSObject)
            //print(meeting_data)
            let event = SPUnstructured.build({ builder in
                builder.setEventData(invoice_data!)
            })
            event.contexts.add(self.getSiteEntity())
            event.contexts.add(self.getUserEntity())
            tracker!.track(event)
        }
    }
    func track_customer_details(customerId: String) {
        let userId = UserDefaults.standard.string(forKey: "user_id") ?? nil
        if userId != nil{
            //print("in track_customer_details \(customerId)")
            let customer_data = SPSelfDescribingJson(
            schema: "iglu:io.webware/mobile_customer_added_to_invoice/jsonschema/1-0-0",
            andData: [
                "customerId" : customerId
            ] as NSObject)
            //print(meeting_data)
            let event = SPUnstructured.build({ builder in
                builder.setEventData(customer_data!)
            })
            event.contexts.add(self.getSiteEntity())
            event.contexts.add(self.getUserEntity())
            tracker!.track(event)
        }
    }
    func track_item_details(itemId: String, quantity: Int) {
        let userId = UserDefaults.standard.string(forKey: "user_id") ?? nil
        if userId != nil{
            //print("in track_item_details \(itemId) and \(quantity)")
            let item_data = SPSelfDescribingJson(
            schema: "iglu:io.webware/mobile_item_added_to_invoice/jsonschema/1-0-0",
            andData: [
                "itemId" : itemId,
                "quantity" : quantity
            ] as NSObject)
            //print(meeting_data)
            let event = SPUnstructured.build({ builder in
                builder.setEventData(item_data!)
            })
            event.contexts.add(self.getSiteEntity())
            event.contexts.add(self.getUserEntity())
            tracker!.track(event)
        }
    }
    func track_tax_details(taxId: String, taxAmount: String) {
        let userId = UserDefaults.standard.string(forKey: "user_id") ?? nil
        if userId != nil{
            //print("in track_tax_details \(taxId) and \(taxAmount)")
            let tax_data = SPSelfDescribingJson(
            schema: "iglu:io.webware/mobile_tax_added_to_invoice/jsonschema/1-0-0",
            andData: [
                "taxId" : taxId,
                "taxAmount" : taxAmount
            ] as NSObject)
            //print(meeting_data)
            let event = SPUnstructured.build({ builder in
                builder.setEventData(tax_data!)
            })
            event.contexts.add(self.getSiteEntity())
            event.contexts.add(self.getUserEntity())
            tracker!.track(event)
        }
    }
    func track_invoice_action(id: String, action: String, status: String, purchaseOrder: String, invoiceDate: String, dueDate: String, subTotal: String, totalTax: String, total: String) {
        let userId = UserDefaults.standard.string(forKey: "user_id") ?? nil
        if userId != nil{
            //print("in track_invoice_action \(id) and \(action)")
            let invoice_data = SPSelfDescribingJson(
            schema: "iglu:io.webware/mobile_invoice_action/jsonschema/1-0-0",
            andData: [
                "id" : id,
                "action" : action
            ] as NSObject)
            //print(invoice_data)
            let event = SPUnstructured.build({ builder in
                builder.setEventData(invoice_data!)
            })
            //print(self.getSiteEntity())
            //print(self.getUserEntity())
            //print(self.getInvoiceEntity(id: id, status: status, purchaseOrder: purchaseOrder, invoiceDate: invoiceDate, dueDate: dueDate, subTotal: subTotal, totalTax: totalTax, total: total))
            event.contexts.add(self.getSiteEntity())
            event.contexts.add(self.getUserEntity())
            event.contexts.add(self.getInvoiceEntity(id: id, status: status, purchaseOrder: purchaseOrder, invoiceDate: invoiceDate, dueDate: dueDate, subTotal: subTotal, totalTax: totalTax, total: total))
            tracker!.track(event)
        }
    }
    func track_tax_list(search: String, taxids: [String]) {
        let userId = UserDefaults.standard.string(forKey: "user_id") ?? nil
        if userId != nil{
            //print("in track_tax_list \(search) and \(taxids)")
            let tax_data = SPSelfDescribingJson(
            schema: "iglu:io.webware/mobile_taxes_list/jsonschema/1-0-1",
            andData: [
                "search" : search,
                "taxIds" : taxids
            ] as NSObject)
            
            let event = SPUnstructured.build({ builder in
                builder.setEventData(tax_data!)
            })
            event.contexts.add(self.getSiteEntity())
            event.contexts.add(self.getUserEntity())
            tracker!.track(event)
        }
    }
    func track_tax_actions(id : String, action : String, name : String, rate : String) {
        let userId = UserDefaults.standard.string(forKey: "user_id") ?? nil
        if userId != nil{
            //print("in track_tax_actions \(id) and \(action)")
            let tax_data = SPSelfDescribingJson(
            schema: "iglu:io.webware/mobile_tax_action/jsonschema/1-0-0",
            andData: [
                "id" : id,
                "action" : action
            ] as NSObject)
            
            let event = SPUnstructured.build({ builder in
                builder.setEventData(tax_data!)
            })
            //event.contexts.add(self.getTaxEntity(id: id, name: name, rate: rate))
            //event.contexts.add(self.getSiteEntity())
            //event.contexts.add(self.getUserEntity())
            tracker!.track(event)
        }
    }
    func track_item_list(search: String, itemIds: [String]) {
        let userId = UserDefaults.standard.string(forKey: "user_id") ?? nil
        if userId != nil{
            //print("in track_item_list \(search) and \(itemIds)")
            let item_data = SPSelfDescribingJson(
            schema: "iglu:io.webware/mobile_items_list/jsonschema/1-0-1",
            andData: [
                "itemIds" : itemIds,
                "search" : "\"null\"",
            ] as NSObject)
            //print(item_data)
            let event = SPUnstructured.build({ builder in
                builder.setEventData(item_data!)
            })
            //event.contexts.add(self.getSiteEntity())
            //event.contexts.add(self.getUserEntity())
            tracker!.track(event)
        }
    }
    func track_item_actions(id : String, action : String, name : String, description : String, price : String) {
        let userId = UserDefaults.standard.string(forKey: "user_id") ?? nil
        if userId != nil{
            //print("in track_item_actions \(id) and \(action)")
            let item_data = SPSelfDescribingJson(
            schema: "iglu:io.webware/mobile_items_action/jsonschema/1-0-0",
            /*andData: [
                "id" : id,
                "action" : action
            ] as NSObject)*/
            andData: [
                "id" : "'\(id)'",
                "action" : "'\(action)'"
            ] as NSObject)

            let event = SPUnstructured.build({ builder in
                builder.setEventData(item_data!)
            })
            //print(self.getItemEntity(id: id, name: name, description: description, price: price))
            event.contexts.add(self.getItemEntity(id: id, name: name, description: description, price: price))
            event.contexts.add(self.getSiteEntity())
            event.contexts.add(self.getUserEntity())
            tracker!.track(event)
        }
    }
    func track_customer_list(search: String, customerIds: [String]) {
        let userId = UserDefaults.standard.string(forKey: "user_id") ?? nil
        if userId != nil{
            //print("in track_customer_list \(search) and \(customerIds)")
            let customer_data = SPSelfDescribingJson(
            schema: "iglu:io..webware/mobile_customer_list/jsonschema/1-0-0",
            andData: [
                "customerIds" : customerIds,
                "search" : search
            ] as NSObject)
            //print(customer_data)
            let event = SPUnstructured.build({ builder in
                builder.setEventData(customer_data!)
            })
            //event.contexts.add(self.getSiteEntity())
            //event.contexts.add(self.getUserEntity())
            tracker!.track(event)
        }
    }
    func track_customer_actions(id : String, action : String, phone : String, email : String, name : String, firstName: String, lastName: String, line1: String, line2: String, city: String, state: String, country: String, postCode: String ) {
        let userId = UserDefaults.standard.string(forKey: "user_id") ?? nil
        if userId != nil{
            //print("in track_customer_actions \(id) and \(action)")
            let customer_data = SPSelfDescribingJson(
            schema: "iglu:io.webware/mobile_customer_action/jsonschema/1-0-0",
            /*andData: [
                "id" : id,
                "action" : "'\(action)'"
            ] as NSObject)*/
                andData: [
                    "id" : "test",
                    "action" : "add"
                ] as NSObject)
            let event = SPUnstructured.build({ builder in
                builder.setEventData(customer_data!)
            })
            //print(self.getCustomerEntity(id: id, phone: phone, email: email, name: name, firstName: firstName, lastName: lastName, line1: line1, line2: line2, city: city, state: state, country: country, postCode: postCode))
            //event.contexts.add(self.getCustomerEntity(id: id, phone: phone, email: email, name: name, firstName: firstName, lastName: lastName, line1: line1, line2: line2, city: city, state: state, country: country, postCode: postCode))
            //event.contexts.add(self.getSiteEntity())
            //event.contexts.add(self.getUserEntity())
            tracker!.track(event)
        }
    }
    
    
    func getTodayString() -> String{

        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)

        let year = components.year
        let month = components.month
        let day = components.day
        let hour = components.hour
        let minute = components.minute
        let second = components.second

        let today_string = String(year!) + "-" + String(month!) + "-" + String(day!) + " " + String(hour!)  + ":" + String(minute!) + ":" +  String(second!)

        return today_string

    }
    
    func getFormatedDateFromTimestamp() -> String {
        var epocTime = TimeInterval(Int(UserDefaults.standard.string(forKey: "createdAt")!)!)

        let myDate = NSDate(timeIntervalSince1970: epocTime)
        
        //var dateToConvert = NSDate(timeIntervalSinceReferenceDate: epocTime)
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let myString = formatter.string(from: myDate as Date) // string purpose I add here
        // convert your string to date
        let yourDate = formatter.date(from: myString)
        //then again set the date format whhich type of output you need
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        // again convert your date to string
        let myStringafd = formatter.string(from: yourDate!)
        return myStringafd
    }
    
    func getSiteEntity() -> SPSelfDescribingJson{
        let siteId = UserDefaults.standard.string(forKey: "site_id") ?? nil
        let organizationId = UserDefaults.standard.string(forKey: "organizationId") ?? nil
        let parentOrganizationId = UserDefaults.standard.string(forKey: "parentOrganizationId") ?? nil
        //print("siteId \(siteId)")
        //print("organizationId \(organizationId)")
        //print("parentOrganizationId \(parentOrganizationId)")
        if siteId != nil && organizationId != nil && parentOrganizationId != nil{
            let json_site = SPSelfDescribingJson(
            schema: "iglu:io.webware/site/jsonschema/1-0-0",
            andData: [
                "organizationId" : Int(UserDefaults.standard.string(forKey: "organizationId")!),
                "parentOrganizationId" : Int(UserDefaults.standard.string(forKey: "parentOrganizationId")!),
                "name" : UserDefaults.standard.string(forKey: "site_name"),
                
                ] as NSObject)
            return json_site!
        } else {
            let json_site = SPSelfDescribingJson(
            schema: "iglu:io.webware/site/jsonschema/1-0-0",
            andData: [
                "organizationId" : Int(0),
                "parentOrganizationId" : Int(0),
                "name" : "test before login",
                
                ] as NSObject)
            return json_site!
        }
    }
    
    
    func getUserEntity() -> SPSelfDescribingJson {
        let userId = UserDefaults.standard.string(forKey: "user_id") ?? nil
        let user_email = UserDefaults.standard.string(forKey: "user_email") ?? nil
        let name = UserDefaults.standard.string(forKey: "name") ?? nil
        let familyName = UserDefaults.standard.string(forKey: "familyName") ?? nil
        var isSubscribed = false
        if(UserDefaults.standard.string(forKey: "isSubscribed") == "true"){
            isSubscribed = true
        }
        let gender = UserDefaults.standard.string(forKey: "gender") ?? nil
        let group = UserDefaults.standard.string(forKey: "group") ?? nil
        let createdAt = UserDefaults.standard.string(forKey: "createdAt") ?? nil
        if userId != nil && user_email != nil && name != nil && familyName != nil && isSubscribed != nil && gender != nil && group != nil && createdAt != nil {
            let json_user = SPSelfDescribingJson(
                schema: "iglu:io.webware/user/jsonschema/1-0-0",
                andData: [
                    "id" : UserDefaults.standard.string(forKey: "user_id")!,
                    "email" : UserDefaults.standard.string(forKey: "user_email")!,
                    "givenName" : UserDefaults.standard.string(forKey: "name")!,
                    "familyName" : UserDefaults.standard.string(forKey: "familyName")!,
                    "isSubscribed" : isSubscribed,
                    "gender" : UserDefaults.standard.string(forKey: "gender")!,
                    "groupId" : Int(UserDefaults.standard.string(forKey: "group")!)!,
                "createdAt" : self.getFormatedDateFromTimestamp()
                ] as NSObject)
            return json_user!
        } else {
            let json_user = SPSelfDescribingJson(
                schema: "iglu:io.webware/user/jsonschema/1-0-0",
                andData: [
                "id" : 0,
                ] as NSObject)
            return json_user!
        }
    }
    func getProjectEntity(id: Int, title: String, description: String, reject_reason: String) -> SPSelfDescribingJson {
        if(reject_reason != "") {
            let json_project = SPSelfDescribingJson(
                schema: "iglu:io.webware/project/jsonschema/1-0-0",
                andData: [
                "id" : id,
                "title" : title,
                "description" : description,
                "reject_reason" : reject_reason
                ] as NSObject)
            return json_project!
        } else {
            let json_project = SPSelfDescribingJson(
                schema: "iglu:io.webware/project/jsonschema/1-0-0",
                andData: [
                "id" : id,
                "title" : title,
                "description" : description
                ] as NSObject)
            //print(json_project!)
            return json_project!
        }
    }
    
    func getMeetingEntity(reason_for_meeting: String, details: String, date: String, time: Int) -> SPSelfDescribingJson {
        let json_meeting = SPSelfDescribingJson(
            schema: "iglu:io.webware/meeting/jsonschema/1-0-0",
            andData: [
            "reason_for_meeting" : reason_for_meeting,
            "details" : details,
            "date" : date,
            "time" : time
            ] as NSObject)
        return json_meeting!
        
    }
    func getInvoiceEntity(id: String, status: String, purchaseOrder: String, invoiceDate: String, dueDate: String, subTotal: String, totalTax: String, total: String) -> SPSelfDescribingJson{
        
        if status != nil && subTotal != nil && total != nil{
            let json_site = SPSelfDescribingJson(
            schema: "iglu:io.webware/mobile_invoice/jsonschema/1-0-0",
            andData: [
                "id" : id,
                "status" : "'\(status)'",
                "purchaseOrder" : "'\(purchaseOrder)'",
                "invoiceDate" : invoiceDate,
                "dueDate" : dueDate,
                "subTotal" : subTotal,
                "totalTax" : totalTax,
                "total" : total,
                ] as NSObject)
            return json_site!
        } else {
            let json_site = SPSelfDescribingJson(
                schema: "iglu:io.webware/mobile_invoice/jsonschema/1-0-0", andData: nil
            )
            return json_site!
        }
    }
    func getTaxEntity(id: String, name: String, rate: String) -> SPSelfDescribingJson{
        
        if id != nil && name != nil && rate != nil{
            let json_site = SPSelfDescribingJson(
            schema: "iglu:io.webware/tax/jsonschema/1-0-0",
            andData: [
                "id" : id,
                "name" : "'\(name)'",
                "rate" : "'\(rate)'"
                ] as NSObject)
            return json_site!
        } else {
            let json_site = SPSelfDescribingJson(
                schema: "iglu:io.webware/tax/jsonschema/1-0-0", andData: nil
            )
            return json_site!
        }
    }
    func getItemEntity(id: String, name: String, description: String, price: String) -> SPSelfDescribingJson{
        if id != nil && name != nil && price != nil{
            let json_site = SPSelfDescribingJson(
            schema: "iglu:io.webware/item/jsonschema/1-0-0",
            andData: [
                "id" : id,
                "name" : "'\(name)'",
                "description" : "'\(description)'",
                "price" : "'\(price)'",
                ] as NSObject)
            return json_site!
        } else {
            let json_site = SPSelfDescribingJson(
                schema: "iglu:io.webware/item/jsonschema/1-0-0", andData: nil
            )
            return json_site!
        }
    }
    func getCustomerEntity(id : String, phone : String, email : String, name : String, firstName: String, lastName: String, line1: String, line2: String, city: String, state: String, country: String, postCode: String) -> SPSelfDescribingJson{
        if name != nil {
            let json_site = SPSelfDescribingJson(
            schema: "iglu:io.webware/customer/jsonschema/1-0-0",
            andData: [
                "id" : id,
                "phone" : "'\(phone)'",
                "email" : "'\(email)'",
                "name" : "'\(name)'",
                "frstName" : "'\(firstName)'",
                "lastName" : "'\(lastName)'",
                "line1" : "'\(line1)'",
                "line2" : "'\(line2)'",
                "city" : "'\(city)'" ,
                "state" : "'\(state)'",
                "country" : "'\(country)'",
                "postCode" : "'\(postCode)'"
                ] as NSObject)
            return json_site!
        } else {
            let json_site = SPSelfDescribingJson(
                schema: "iglu:io.webware/customer/jsonschema/1-0-0", andData: nil
            )
            return json_site!
        }
    }
    func trackCustomEvent(screendata: [String: Any]) {
        let sdj = SPSelfDescribingJson(
            schema: Common.snowPlowSchemaUrl,
            andData: screendata as NSObject)

        let event = SPUnstructured.build({ builder in
            builder.setEventData(sdj!)
        })
        tracker!.track(event)
    }
    
    func track_consent_withdrawn(docname: String, docdescription: String) {
        /*let event = SPConsentWithdrawn.build({ builder in
            builder.setName(docname)
            builder.setDescription(docdescription)
        })
        tracker!.track(event)
         */
    }
    func track_consent_granted(docname: String, docdescription: String) {
        //print("in granted")
        //let event = SPConsentGranted.build({ builder in
          //  builder.setName(docname)
            //builder.setDescription(docdescription)
        //})
        //tracker!.track(event)
    }
    func track_timing(label: String) {
        let todayDate = Date()
        let timeInterval = todayDate.timeIntervalSince1970
        let currentTime = Int(timeInterval)
        let event = SPTiming.build({ builder in
            builder.setTiming(currentTime)
            builder.setLabel(self.getTodayString())
            builder.setVariable(label)
        })
        tracker!.track(event)
    }
    func track_notification(notify_badge: NSNumber, notify_body: String, notify_title: String) {
        let event = SPNotificationContent.build({ builder in
            builder.setBadge(notify_badge)
            builder.setBody(notify_body)
            builder.setTitle(notify_title)
        })
        //tracker!.track(event)
    }
}
