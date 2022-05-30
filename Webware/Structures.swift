//
//  Structures.swift
//  WebwarePay
//
//  Created by Vedika on 01/12/21.
//

import UIKit

struct CustomerResponse: Decodable{
    var customer : String
}
struct InvoiceItemResponse: Decodable{
    var invoiceitem : String
}
struct CustomerResponseWeb: Decodable{
    var customer : String
}
struct TaxResponse: Decodable{
    var taxrates : String
}
struct ItemResponse: Decodable{
    var product : String
}
struct InvoiceResponse: Decodable{
    var invoice : String
}
struct selected_item: Decodable{
    var name : String
    var description : String
    var quantity : Int
    var price : Int
}
struct ApiResponse: Decodable {
    let status: Int
    let message: String
    let response: [Int]
}
class Login_Status: Decodable {
    var MESSAGE: String
    var TOKEN: String
    var STATUS: Int
    var ID: Int
    var DATA: UserData
    var GROUP: Int
    var NAME: String
    var FAMILYNAME: String
    var ISSUBSCRIBED: Int
    var GENDER: String
    var ORGANIZATIONID: Int
    var PARENTORGANIZATIONID: Int
    var HASINVOICESENABLED: Int?
    var IS_STRIPE_CONNECTED: Int?
    var JSESSIONID: String?

    enum CodingKeys: String, CodingKey {
        case MESSAGE
        case TOKEN
        case STATUS
        case ID
        case DATA
        case GROUP
        case NAME
        case FAMILYNAME
        case ISSUBSCRIBED
        case GENDER
        case ORGANIZATIONID
        case PARENTORGANIZATIONID
        case HASINVOICESENABLED
        case IS_STRIPE_CONNECTED
        case JSESSIONID
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var familyString = ""
        do {
            familyString = try container.decode(String.self, forKey: .FAMILYNAME)
        } catch {
            
        }
        var familyInt = ""
        do {
            familyInt = try container.decode(String.self, forKey: .FAMILYNAME)
        } catch {
            
        }
        self.FAMILYNAME = familyString ?? "\(familyInt)"
        var message = ""
        do {
            message = try container.decode(String.self, forKey: .MESSAGE)
        } catch {
            
        }
        self.MESSAGE = message
        
        var token = ""
        do {
            token = try container.decode(String.self, forKey: .TOKEN)
        } catch {
            
        }
        self.TOKEN = token
        
        var status = 0
        do {
            status = try container.decode(Int.self, forKey: .STATUS)
        } catch {
            
        }
        self.STATUS = status
        var id = 0
        do {
            id = try container.decode(Int.self, forKey: .ID)
        } catch {
            
        }
        self.ID = id
        
        do {
            self.DATA = try! container.decode(UserData.self, forKey: .DATA)
        } catch {
            
        }
        
        var group = 0
        do {
            group = try container.decode(Int.self, forKey: .GROUP)
        } catch {
            
        }
        self.GROUP = group
        var name = ""
        do {
            name = try container.decode(String.self, forKey: .NAME)
        } catch {
            
        }
        self.NAME = name
        var issubscribed = 0
        do {
            issubscribed = try container.decode(Int.self, forKey: .ISSUBSCRIBED)
        } catch {
            
        }
        self.ISSUBSCRIBED = issubscribed
        var gender = ""
        do {
            gender = try container.decode(String.self, forKey: .GENDER)
        } catch {
            
        }
        self.GENDER = gender
        var org_id = 0
        do {
            org_id = try container.decode(Int.self, forKey: .ORGANIZATIONID)
        } catch {
            
        }
        self.ORGANIZATIONID = org_id
        var parent_org_id = 0
        do {
            parent_org_id = try container.decode(Int.self, forKey: .PARENTORGANIZATIONID)
        } catch {
            
        }
        self.PARENTORGANIZATIONID = parent_org_id
        var invoice_enabled = 0
        do {
            invoice_enabled = try container.decode(Int.self, forKey: .HASINVOICESENABLED)
        } catch {
            
        }
        self.HASINVOICESENABLED = invoice_enabled
        
        var stripe_enabled = 0
        do {
            stripe_enabled = try container.decode(Int.self, forKey: .IS_STRIPE_CONNECTED)
        } catch {
            
        }
        self.IS_STRIPE_CONNECTED = stripe_enabled
        
        var jsession_id = ""
        do {
            jsession_id = try container.decode(String.self, forKey: .JSESSIONID)
        } catch {
            
        }
        self.JSESSIONID = jsession_id
    }
}
struct UserData: Codable{
    var name: String?
    var email: String?
    var user_id: Int?
    var site_id: Int?
    var currency: String?
    var signup_date: intmax_t?
    var company: UserCompany?
}
struct UserCompany: Codable{
    var name: String?
    var subdomain: String?
}
struct Status: Codable {
    var MESSAGE: String
    var STATUS: Int
}
struct VersionResponse: Decodable {
    let status: Int
    let message: String
    let response: detailsVersion
}
struct detailsVersion: Decodable {
    let new_version_available: Bool
}
