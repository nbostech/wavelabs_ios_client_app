//
//  UsersApi.swift
//  IOSStarter
//
//  Created by afsarunnisa on 1/27/16.
//  Copyright (c) 2016 NBosTech. All rights reserved.
//

import Foundation
import Alamofire

@objc public protocol getUsersApiResponseDelegate {
    
    optional func handleRegister(userEntity:NewMemberApiModel)
    optional func handleProfile(memberEntity:MemberApiModel)
    optional func handleUpdateProfile(memberEntity:MemberApiModel)
    
    optional func handleMessages(messageCodeEntity: MessagesApiModel)
    optional func handleValidationErrors(messageCodeEntityArray: NSArray) // multiple MessagesRespApiModel - 404(Validation errors)
    optional func handleRefreshToken(JSON : AnyObject) // multiple MessagesRespApiModel - 404(Validation errors)

    
}

public class UsersApi {
    
    var identityApiUrl : String = "api/identity/v0/users/"
    var rigistrationUrl : String = "signup"
    
    public var delegate: getUsersApiResponseDelegate?
    
    var utilities : Utilities = Utilities()

    
    public init() {
        
    }
    
    public func registerUser(userRegister : NSDictionary) {
        
        var requestUrl = "\(WAVELABS_HOST_URL)\(identityApiUrl)\(rigistrationUrl)"
        let token: AnyObject = utilities.getClientAccessToken()
        
        Alamofire.request(.POST, requestUrl, parameters: utilities.getParams(userRegister), encoding: .JSON, headers : ["Authorization" : "Bearer \(token)"])
            .responseJSON { request, response, JSON, error in
                
                var statusCode : Int = response!.statusCode
                
                if(JSON != nil){
                    if(response!.statusCode == 200){
                        var newMemberApi : NewMemberApiModel = Communicator.userEntityFromJSON(JSON!)
                        self.delegate!.handleRegister!(newMemberApi)
                    }else if(response!.statusCode == 400){
                        self.validationErrorsCodes(JSON!)
                    }else if(response!.statusCode == 401){
                        
                    }else {
                        self.messagesErrorsCodes(JSON!)
                    }
                    
                }
        }
    }

    public func getProfile() {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        var userID : String
        
        if(Utilities.nullToNil(defaults.stringForKey("user_id")) == nil){ // checking for null
            userID = ""
        }else{
            userID = defaults.stringForKey("user_id")!
        }
        
        var requestUrl = "\(WAVELABS_HOST_URL)\(identityApiUrl)\(userID)"
        let token: AnyObject = utilities.getUserAccessToken()
        
        
        Alamofire.request(.GET, requestUrl, parameters: nil, encoding: .JSON, headers : ["Authorization" : "Bearer \(token)"])
            .responseJSON { request, response, JSON, error in
                
                var statusCode : Int = response!.statusCode
                
                if(JSON != nil){
                    
                    if(response!.statusCode == 200){
                        var memberDetails : MemberApiModel = Communicator.ProfileFromJson(JSON!)
                        self.delegate!.handleProfile!(memberDetails)
                    }else if(response!.statusCode == 400){
                        self.validationErrorsCodes(JSON!)
                    }else if(response!.statusCode == 401){
                        self.delegate!.handleRefreshToken!(JSON!)
                    }else {
                        self.messagesErrorsCodes(JSON!)
                    }
                }
        }
    }
    
    public func updateProfile(profile : NSDictionary) {
        
        
        var utilities : Utilities = Utilities()
        let defaults = NSUserDefaults.standardUserDefaults()
        var userID : String
        
        if(Utilities.nullToNil(defaults.stringForKey("user_id")) == nil){ // checking for null
            userID = ""
        }else{
            userID = defaults.stringForKey("user_id")!
        }
        
        
        var requestUrl = "\(WAVELABS_HOST_URL)\(identityApiUrl)\(userID)"
        let token: AnyObject = utilities.getUserAccessToken()
        
        
        Alamofire.request(.PUT, requestUrl, parameters: utilities.getParams(profile), encoding: .JSON, headers : ["Authorization" : "Bearer \(token)"])
            .responseJSON { request, response, JSON, error in
                print(response)
                print(JSON)
                print(error)
                println(response?.statusCode)
                
                var statusCode : Int = response!.statusCode
                
                if(JSON != nil){
                    if(response!.statusCode == 200){
                        var memberDetails : MemberApiModel = Communicator.ProfileFromJson(JSON!)
                        self.delegate!.handleUpdateProfile!(memberDetails)
                    }else if(response!.statusCode == 400){
                        self.validationErrorsCodes(JSON!)
                    }else if(response!.statusCode == 401){
                        self.delegate!.handleRefreshToken!(JSON!)
                    }else {
                        self.messagesErrorsCodes(JSON!)
                    }
                }
        }
    }
    
    public func validationErrorsCodes(JSON : AnyObject){
        var validationErrors : NSArray = Communicator.respValidationMessageCodesFromJson(JSON)
        self.delegate!.handleValidationErrors!(validationErrors)
    }
    
    public func messagesErrorsCodes(JSON : AnyObject){
        var messageCodeEntity : MessagesApiModel = Communicator.respMessageCodesFromJson(JSON)
        self.delegate!.handleMessages!(messageCodeEntity)
    }


    
}