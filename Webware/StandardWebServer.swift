//
//  StandardWebServer.swift
//  WebwareTest2
//
//  Created by Vedika Bapat on 01/11/19.
//  Copyright © 2019 Webware.io. All rights reserved.
//

import UIKit
import WebKit
//import Crashlytics
import MobileCoreServices
import AVFoundation
import Photos
import CoreData
var vSpinner : UIView?
import Foundation
extension SecTrust {
    var isSelfSigned: Bool? {
            guard SecTrustGetCertificateCount(self) == 1 else {
                return false
            }
            guard let cert = SecTrustGetCertificateAtIndex(self, 0) else {
                return nil
            }
            return cert.isSelfSigned
        }
}
extension SecCertificate {

    var isSelfSigned: Bool? {
        guard
            let subject = SecCertificateCopyNormalizedSubjectSequence(self),
            let issuer = SecCertificateCopyNormalizedIssuerSequence(self)
        else {
            return nil
        }
        return subject == issuer
    }
}
extension UIViewController {
    //private static let webwareEndpoint = "https://www.webware.io/api/"
    //private static var webwareEndpoint = "https://www.powerstorez.com/api/"
    func showSpinner(onView : UIView) {
        if(vSpinner == nil) {
            var frame = UIScreen.main.bounds
            var screenwidth = frame.size.width
            var screenheight = frame.size.height
            if let navhidden = self.navigationController?.navigationBar.isHidden {
                if(navhidden == false) {
                    screenheight = screenheight - 150
                }
            }
            let spinnerView = UIView.init(frame: CGRect(x: 0,y: 0,width: screenwidth,height: screenheight))
            //spinnerView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0.6, alpha: 1)
            let ai = UIActivityIndicatorView.init(style: .whiteLarge)
            ai.startAnimating()
            ai.center = spinnerView.center
            ai.color = UIColor.black
            DispatchQueue.main.async {
                spinnerView.addSubview(ai)
                onView.addSubview(spinnerView)
            }
            vSpinner = spinnerView
        }
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
    
    public static let loader = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
    public static var endpoint = ""
    public static var datawareEndPoint = ""
    public static var token =  ""
    public static var webwareEndpoint = ""
    enum ApiError: Error {
        case invalidOperation
    }
    typealias Func = (_ sampleParameter : Data)  -> Void
    typealias DecodingErrorFunction = (_ sampleParameter : Error)  -> Void
    typealias ErrorFunction = (_ sampleParameter : Error)  -> Void
    
    func serverApiCall(route: String, method: String ,data: [String : Any], responseHandler: @escaping Func, errorHandler: @escaping DecodingErrorFunction, showSpiner : Bool = true) {
        setconfigvars()
        if(showSpiner == true) {
            self.showSpinner(onView: self.view)
        }
        let organizationId = UserDefaults.standard.string(forKey: "organizationId") ?? nil
        var jsession_id = UserDefaults.standard.string(forKey: "jsession_id") ?? ""
        let headers = [
          "content-type": "application/json",
          "Cookie" : "JSESSIONID=\(jsession_id); \(organizationId!)-JSESSIONID=\(jsession_id);",
          "Authorization" : jsession_id,
        ]
        print(headers)
        do{
            print(route)
            let request = NSMutableURLRequest(url: NSURL(string: route)! as URL,
                                                    cachePolicy: .useProtocolCachePolicy,
                                                    timeoutInterval: 50.0)
            request.httpMethod = method
            request.allHTTPHeaderFields = headers
            if(method == "POST" || method == "PUT" || method == "DELETE") {
                let postData = try JSONSerialization.data(withJSONObject: data, options: [])
                request.httpBody = postData as Data
            }
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                //print("data \(data?.prettyPrintedJSONString)")
                //print("error \(error)")
                //print("response \(response)")
                var isValidResponse = true
                if let httpResponse = response as? HTTPURLResponse {
                    print("response code \(httpResponse.statusCode)")
                    
                    if(httpResponse.statusCode == 403) {
                        DispatchQueue.main.async { [unowned self] in
                            Common.logout(v: self)
                        }
                    } else if(httpResponse.statusCode == 401) {
                        isValidResponse = false
                    } else {
                        //print(httpResponse)
                    }
              }
              if (error != nil) {
                DispatchQueue.main.async { [unowned self] in
                    self.removeSpinner()
                    errorHandler(error as! Error)
                }
              } else if(isValidResponse == false) {
                DispatchQueue.main.async { [unowned self] in
                    self.removeSpinner()
                    self.present(Common.showOkAlert(title: Common.server_error_Title, content: Common.server_error_Text), animated: true)
                }
              } else {
                DispatchQueue.main.async { [unowned self] in
                    sleep(1)
                    let httpResponse = response as? HTTPURLResponse
                    self.removeSpinner()
                    responseHandler(data!)
                }
              }
            })
            dataTask.resume()
        }catch{
            self.removeSpinner()
        }
    }
    
    func serverDatawareApiCall(route: String, method: String = "GET", data: String = "", responseHandler: @escaping Func, errorHandler: @escaping DecodingErrorFunction) {
        setconfigvars()
        if (!route.contains("version") && !route.contains("badgeclear") && !route.contains("create_customer")) {
            //Common.startActivityIndicator(indicator: UIViewController.loader, view: self.view)
            self.showSpinner(onView: self.view)
        }
        guard let url = URL(string: UIViewController.datawareEndPoint + route) else {
            //throw ApiError.invalidOperation
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(UIViewController.token, forHTTPHeaderField: "Authorization")
        if(data != ""){
            request.httpBody = data.data(using: .utf8)
        }
        print("data \(data)")
        self.performRequest(req: request, responseHandler: responseHandler, errorHandler: errorHandler)
        
    }
    
    func performRequest(req : URLRequest, responseHandler: @escaping Func, errorHandler: @escaping DecodingErrorFunction) {
        var session = URLSession(configuration: URLSessionConfiguration.default, delegate: RequestDelegate(), delegateQueue: nil)
        let task = session.dataTask(with: req) {
            (data: Data?, response: URLResponse?, error: Error?) in
            if(error != nil){
                DispatchQueue.main.async { [unowned self] in
                    if(error as! URLError).code == URLError.notConnectedToInternet {
                        self.present(Common.showOkAlert(title: Common.network_error_Title, content: Common.network_error_Text), animated: true)
                    } else {
                        self.present(Common.showOkAlert(title: Common.invalid_request_Title, content: Common.invalid_request_Text), animated: true)
                    }
                    self.removeSpinner()
                    errorHandler(error!)
                }
            }else{
                guard let data = data else {return}
                do{
                    DispatchQueue.main.async { [unowned self] in
                        responseHandler(data)
                        self.removeSpinner()
                    }
                }catch let decodingEror as DecodingError {
                    DispatchQueue.main.async { [unowned self] in
                        errorHandler(decodingEror)
                        self.removeSpinner()
                    }
                }catch{
                    self.removeSpinner()
                }
            }
        }
        task.resume()
    }
    
    func showAlertAndGoBack(title: String,message: String, segueIdentifier: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            self.performSegue(withIdentifier: segueIdentifier, sender: self)
        }
        OKAction.setValue(UIColor.init(red: 239, green: 96, blue: 51, alpha: 1), forKey: "titleTextColor")
        alert.addAction(OKAction)
        self.present(alert,animated: true)
    }
    func showAlertAndGoBackMeeting(title: String,message: String, segueIdentifier: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            //self.performSegue(withIdentifier: segueIdentifier, sender: self)
            self.navigationController?.popViewController(animated: true)
        }
        OKAction.setValue(UIColor.init(red: 239, green: 96, blue: 51, alpha: 1), forKey: "titleTextColor")
        alert.addAction(OKAction)
        self.present(alert,animated: true)
    }
    
    func setconfigvars() {
        enum Environment {
            case development
            case staging
            case production
        }
        let environment: Environment = .development
        switch environment {
        case .development:
            //UIViewController.endpoint = "https://devwebware.powerstorez.com/admin/"
            UIViewController.datawareEndPoint = "https://dataware.webware.io/api/"
            UIViewController.token = "Bearer  eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6IjU5OWFlNzZjZTUxOTUwYTBmZWM5NWNlOGIwNjRkNzk3YTQyYTI1MzFlYjA2YTcyYWYzNmQxNjNiNDBkNDkzM2FiMDQ4YWFmMTllMmM3YjFmIn0.eyJhdWQiOiIyIiwianRpIjoiNTk5YWU3NmNlNTE5NTBhMGZlYzk1Y2U4YjA2NGQ3OTdhNDJhMjUzMWViMDZhNzJhZjM2ZDE2M2I0MGQ0OTMzYWIwNDhhYWYxOWUyYzdiMWYiLCJpYXQiOjE1NjA4NzM4NzcsIm5iZiI6MTU2MDg3Mzg3NywiZXhwIjoxNTkyNDk2Mjc3LCJzdWIiOiIyIiwic2NvcGVzIjpbXX0.X812aMSojr5mit5OuJo9Xn8VYbM5ckbwTANetQa6nidQEQk67KwuqNmZR7tsfcltyWVUIoLvtPsf4hF_0herW5anRP9C2PBHiQBHd0v2QCtDy2IyS9H5I1KNaysgD71vVtpXni7loMxerVNiBp5L_c_o8uRY20AK0d4i4o5TyD9nBV6yVaXvklAAsRQmQg-FrT-K8m1yE4hE61nJKrYw6l-rC6zVx3HOTGPMHylKvjxX3xVayS_-w98UjRh_1vEG5OqZzWDIB0OBHXFlS3u5OvvuaPcDattPlac9ztd5CUIc-STd7sfDVzl3b-A_8hEjJpfcoRVmP-W7uVFZk3XbnyAfsANW653pth-ln4z3EHKAq9HPx_8qKHYVCvhMfuTRy8wlj1cXVJn4qfvX5t4jxJiPFUn4J--J27soo0uGRTk9KajYt8eWQbuyyWj2L_6ezIq3LjxZyCbNlwHaWfcIvDh8CHkl3aHGdDHgZ4jJKen_HLHXscSX0P6BBBDAc-m7mDjLkabPoZGvu3QHIoAWhQFcDdjPN5AZ790jpVHu4n0Mth4EnW7d8HWiQbtZuUmwwdn3mMRRiZso14rstRzN7ac61Lxc9L06YFczokzk1IP92pD17SEEsaAOJb9vJHybc7H6T0vbC8AZx9IiYye4LiQF9lcfT7aL7mxb9tYYfaE"
            //UIViewController.webwareEndpoint = "https://dev.powerstorez.com/api/"
        case .staging:
            //UIViewController.endpoint = ""
            UIViewController.token = ""
        case .production:
            //UIViewController.endpoint = ""
            UIViewController.token = ""
        }
    }
    func externalApiCall(route: String, method: String = "GET", data: String = "", responseHandler: @escaping Func, errorHandler: @escaping DecodingErrorFunction) {
        setconfigvars()
        print("in external \(route)")
        //guard let url = URL(string: UIViewController.webwareEndpoint + route) else {
        guard let url = URL(string: route) else {
            //throw ApiError.invalidOperation
            return
        }
        print(url.absoluteString)
        var request = URLRequest(url: url)
        request.httpMethod = method
        if(data != ""){
            request.httpBody = data.data(using: .utf8)
        }
        self.performRequest(req: request, responseHandler: responseHandler, errorHandler: errorHandler)
    }
    
}
class RequestDelegate: NSObject, URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}
