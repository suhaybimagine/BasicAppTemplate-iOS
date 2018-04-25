//
//  WebApi.swift
//  OffersMatch
//
//  Created by Ali Hajjaj on 3/15/18.
//  Copyright © 2018 Ali Hajjaj. All rights reserved.
//

import Foundation
import Alamofire
import SVProgressHUD
import SwiftyJSON
import CoreLocation

class AppWebApi {
    
    private static let base = "http://localhost:5000"
    
    typealias ApiCallCompletionHandler = (JSON) -> String?
    typealias FailureHandler = (String) -> Void
    
    private static func callApi(loadingComment:String? = nil,
                                   endpoint:String,
                                   method:HTTPMethod = .post,
                                   params:[String:Any],
                                   completion:@escaping ApiCallCompletionHandler,
                                   failure:FailureHandler? = nil) -> Void {
        
        SVProgressHUD.setDefaultMaskType(.gradient)
        
        if let comment = loadingComment {
            SVProgressHUD.show(withStatus: comment)
        } else {
            SVProgressHUD.show()
        }
        
        let request:DataRequest
        if method == .get {
            request = Alamofire.request("\(base)/\(endpoint)", method: .get, parameters: params)
        } else {
            request = Alamofire.request("\(base)/\(endpoint)", method: .post, parameters: params, encoding: JSONEncoding.default)
        }
        
        request.responseSwiftyJSON { (response) in
                
                SVProgressHUD.dismiss()
                
                var errorStr:String?
                if let error = response.error {
                    
                    errorStr = error.localizedDescription
                    
                } else if let json = response.value {
                    
                   errorStr = completion(json)
                    
                } else {
                    
                    errorStr = "Something went wrong"
                }
                
                if let err = errorStr {
                    
                    if let failHandler = failure {
                        
                        failHandler(err)
                    } else {
                        
                        showErrorMessage(err)
                    }
                }
        }
    }
    
    
    typealias LoginSuccessHandler = (String, String, Bool) -> Void
    static func login(email:String, password:String, success:@escaping LoginSuccessHandler) {
        
        callApi(loadingComment: "Logging..",
                endpoint: "login",
                params: ["email": email, "password": password],
                completion: { (json) -> String? in
                    
                    if let status = json["status"].string, status == "success",
                        let userId = json["user_id"].string,
                        let name = json["name"].string,
                        let isConfirmed = json["is_confirmed"].bool {
                        
                        success(userId, name, isConfirmed)
                        return nil
                        
                    } else {
                        
                        return json["message"].string ?? "Something went wrong !"
                    }
        })
    }
    
    
    typealias SignUpSuccessHandler = (String, String?) -> Void
    typealias SignUpProgressHandler = (Progress) -> Void
    static func signUp(name:String, email:String, password:String,
                       birthdate:Date, phone:String, location:CLLocationCoordinate2D,
                       address:String?, gender:Int, photo:UIImage?,
                       success:@escaping SignUpSuccessHandler,
                       progress:SignUpProgressHandler? = nil,
                       failure:FailureHandler? = nil) {
        
        let comment = "Registering..."
        SVProgressHUD.setDefaultMaskType(.gradient)
        SVProgressHUD.show(withStatus: comment)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        
        Alamofire.upload(multipartFormData: { (formData) in
            
            ["name": name,
             "email": email,
             "birthdate": formatter.string(from: birthdate),
             "location": "\(location.latitude),\(location.longitude)",
                "address": address ?? "",
                "gender": "\(gender)",
                "phone": phone,
                "password": password ].forEach({ (key, value) in
                    formData.append(value.data(using: .utf8)!, withName: key)
                })
            
            if let image = photo {
                formData.append(UIImageJPEGRepresentation(image, 1)!,
                                withName: "photo",
                                fileName: "user_photo.jpg", mimeType: "image/jpeg")
            }
            
        }, to: "\(base)/signup") { (result) in
            
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (prog) in
                    SVProgressHUD.showProgress( Float(prog.fractionCompleted) , status: comment)
                    progress?(prog)
                })
                
                upload.responseSwiftyJSON { response in
                    
                    SVProgressHUD.dismiss()
                    if let json = response.result.value {
                        
                        if let status = json["status"].string, status == "success",
                            let userId = json["user_id"].string {
                            
                            success(userId, json["photo_url"].string )
                        } else {
                            
                            failure?(json["message"].string ?? "Something went wrong !")
                        }
                        
                    } else {
                        
                        failure?("Something went wrong !")
                    }
                }
                
            case .failure(let encodingError):
                
                SVProgressHUD.dismiss()
                failure?(encodingError.localizedDescription)
            }
        }
    }
    
    typealias SuccessCompletionHandler = () -> Void
    static func confirmSignup(forUser userId:String, withCode code:String, onSuccess:@escaping SuccessCompletionHandler) {
        
        callApi(endpoint: "confirm", params: ["userID": userId, "code": code], completion: { (json) -> String? in
            
            if let status = json["status"].string, status == "success" {
                onSuccess()
                return nil
            } else {
                
                return json["message"].string ?? "Something went wrong !"
            }
        })
    }
    
    static func sendConfirmationCode(forUser userId:String) {
        
        callApi(endpoint: "sendconfirmcode", params: ["userID": userId], completion: { (json) -> String? in
            
            if let status = json["status"].string, status == "success" {
                return nil
            } else {
                return json["message"].string ?? "Something went wrong !"
            }
        })
    }
    
    static func reportForgotPassword(forEmail email:String, onSuccess:@escaping SuccessCompletionHandler) {
        
        callApi(endpoint: "forgotpassword", params: ["email": email], completion: { (json) -> String? in
            
            if let status = json["status"].string, status == "success" {
                onSuccess()
                return nil
            } else {
                return json["message"].string ?? "Something went wrong !"
            }
        })
    }
}
