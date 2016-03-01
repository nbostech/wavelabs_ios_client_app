//
//  SocialApi.swift
//  IOSStarter
//
//  Created by afsarunnisa on 1/29/16.
//  Copyright (c) 2016 NBosTech. All rights reserved.
//

import Foundation
import Alamofire


@objc public protocol getSocialApiResponseDelegate {
    
    optional func handleLogin(userEntity:NewMemberApiModel)
    optional func handleWebLinkLoginResponse(response:NSDictionary)
    
    
    optional func handleMessages(messageCodeEntity: MessagesApiModel)
    optional func handleValidationErrors(messageCodeEntityArray: NSArray) // multiple MessagesRespApiModel - 404(Validation errors)
    optional func handleRefreshToken(JSON : AnyObject) // multiple MessagesRespApiModel - 404(Validation errors)

}


public class SocialApi {
    
    
    
    public init() {
        
    }
    
    
    var socialIdentityApiUrl : String = "api/identity/v0/auth/social/"
    
    var fbConnectUrl : String = "facebook/connect"
    var googleConnectUrl : String = "googlePlus/connect"
    var digitsLoginUrl : String = "digits/connect"

    var gitLoginUrl : String = "gitHub/login"
    var linkedInLoginUrl : String = "linkedIn/login"
    var instagramLoginUrl : String = "instagram/login"

    var utilities : Utilities = Utilities()

    
    public var delegate: getSocialApiResponseDelegate?
    
    public func socialLogin(socialLoginDetails : NSDictionary, socialType : String){
        var socialConnectUrl : String = "\(socialType)/connect"
        
        var requestUrl = "\(WAVELABS_HOST_URL)\(socialIdentityApiUrl)\(socialConnectUrl)"
        let token: AnyObject = utilities.getClientAccessToken()

        Alamofire.request(.POST, requestUrl, parameters: utilities.getParams(socialLoginDetails), encoding: .JSON, headers : ["Authorization" : "Bearer \(token)"])
            .responseJSON { request, response, JSON, error in

                var statusCode : Int = response!.statusCode
                
                if(JSON != nil){
                    if(response!.statusCode == 200){
                        var userEntity : NewMemberApiModel = Communicator.userEntityFromJSON(JSON!)
                        self.delegate!.handleLogin!(userEntity)
                    }else if(response!.statusCode == 400){
                        
                        self.validationErrorsCodes(JSON!)
                        
                    }else if(response!.statusCode == 401){
                        
                    }else {
                        self.messagesErrorsCodes(JSON!)
                    }
                }
        }
    }
    
    public func socialWebLogin(socialType : String) {
        

        var socialwebLinkUrl : String = "\(socialType)/login"

        var requestUrl = "\(WAVELABS_HOST_URL)\(socialIdentityApiUrl)\(socialwebLinkUrl)"
        let token: AnyObject = utilities.getClientAccessToken()
        
        Alamofire.request(.GET, requestUrl, parameters: nil, encoding: .JSON, headers : ["Authorization" : "Bearer \(token)"])
            .responseJSON { request, response, JSON, error in
                print(response)
                print(JSON)
                print(error)
                println(response?.statusCode)
                
                var statusCode : Int = response!.statusCode
                
                if(JSON != nil){
                    
                    if(response!.statusCode == 200){
                        var respDict : NSDictionary = Communicator.webLinkLoginFromJSON(JSON!)
                        self.delegate!.handleWebLinkLoginResponse!(respDict)
                    }else if(response!.statusCode == 400){
                        
                        self.validationErrorsCodes(JSON!)
                        
                    }else if(response!.statusCode == 401){
                        
                    }else {
                        self.messagesErrorsCodes(JSON!)
                    }
                }
        }
    }
    
    public func digitsLoginUser(digitsLogin : NSDictionary) {
        

        var requestUrl = "\(WAVELABS_HOST_URL)\(socialIdentityApiUrl)\(digitsLoginUrl)"
        let token: AnyObject = utilities.getClientAccessToken()

        Alamofire.request(.POST, requestUrl, parameters: utilities.getParams(digitsLogin), encoding: .JSON, headers : ["Authorization" : "Bearer \(token)"])
            .responseJSON { request, response, JSON, error in
                print(response)
                print(JSON)
                print(error)
                println(response?.statusCode)
                
                var statusCode : Int = response!.statusCode
                
                if(JSON != nil){
                    if(response!.statusCode == 200){
                        var userEntity : NewMemberApiModel = Communicator.userEntityFromJSON(JSON!)
                        self.delegate!.handleLogin!(userEntity)
                    }else if(response!.statusCode == 400){
                        self.validationErrorsCodes(JSON!)
                    }else if(response!.statusCode == 401){
                        
                    }else {
                        self.messagesErrorsCodes(JSON!)
                    }
                }
        }
    }
    
    public func socialConnect(socialLoginDetails : NSDictionary, socialType : String){
    
    
        var socialConnectUrl : String = "\(socialType)/connect"
        var requestUrl = "\(WAVELABS_HOST_URL)\(socialIdentityApiUrl)\(socialConnectUrl)"
        
        let token: AnyObject = utilities.getUserAccessToken()
    
        Alamofire.request(.POST, requestUrl, parameters: utilities.getParams(socialLoginDetails), encoding: .JSON, headers : ["Authorization" : "Bearer \(token)"])
            .responseJSON { request, response, JSON, error in
                print(response)
                print(JSON)
                print(error)
                println(response?.statusCode)
                
                var statusCode : Int = response!.statusCode
                
                if(JSON != nil){
                    
                    
                    if(response!.statusCode == 200){
                        var messageCodeEntity : MessagesApiModel = Communicator.respMessageCodesFromJson(JSON!)
                        self.delegate!.handleMessages!(messageCodeEntity)
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
    
    public func socialWebConnect(socialType : String){
        
        var socialwebLinkUrl : String = "\(socialType)/login"
        var requestUrl = "\(WAVELABS_HOST_URL)\(socialIdentityApiUrl)\(socialwebLinkUrl)"

        let token: AnyObject = utilities.getUserAccessToken()

        Alamofire.request(.GET, requestUrl, parameters: nil, encoding: .JSON, headers : ["Authorization" : "Bearer \(token)"])
            .responseJSON { request, response, JSON, error in
                print(response)
                print(JSON)
                print(error)
                println(response?.statusCode)
                
                var statusCode : Int = response!.statusCode
                
                if(JSON != nil){
                    
                    if(response!.statusCode == 200){
                        var respDict : NSDictionary = Communicator.webLinkLoginFromJSON(JSON!)
                        self.delegate!.handleWebLinkLoginResponse!(respDict)
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