//
//  AuthAPI.swift
//  IOSStarter
//
//  Created by afsarunnisa on 1/27/16.
//  Copyright (c) 2016 NBosTech. All rights reserved.
//

import Foundation
import Alamofire

@objc public protocol getAuthApiResponseDelegate {
    
    optional func handleLogin(userEntity:NewMemberApiModel)
    optional func handleLogOut(messageCodeEntity: MessagesApiModel)
    
    optional func handleMessages(messageCodeEntity: MessagesApiModel)
    optional func handleValidationErrors(messageCodeEntityArray: NSArray) // multiple MessagesRespApiModel - 404(Validation errors)
    optional func handleRefreshToken(JSON : AnyObject) // multiple MessagesRespApiModel - 404(Validation errors)

    optional func handleRefreshTokenResponse(tokenEntity : TokenApiModel)
    
    optional func handleClientTokenResponse(tokenEntity : TokenApiModel)

    
    optional func moveToLogin()
    
}

public class AuthApi {


    var identityApiUrl : String = "api/identity/v0/auth/"
    
    
    var loginUrl : String = "login"
    var logOutUrl : String = "logout"
    var changePswUrl : String = "changePassword"
    var forgotPswUrl : String = "forgotPassword"
    
    var refreshTokenUrl : String = "oauth/token"
    
    public var delegate: getAuthApiResponseDelegate?

    
    var utilities : Utilities = Utilities()
    
    
    public init() {
        
    }
    
    public func getClientToken(clientTokenDict : NSDictionary){
        
        var requestUrl = "\(WAVELABS_HOST_URL)\(refreshTokenUrl)"

        Alamofire.request(.POST, requestUrl, parameters: utilities.getParams(clientTokenDict))
            .responseJSON { request, response, JSON, error in
                
                if(JSON != nil){
                    if(response!.statusCode == 200){
                        var tokenDetails : TokenApiModel = Communicator.clientDetailsEntity(JSON! as! NSDictionary)
                        self.delegate!.handleClientTokenResponse!(tokenDetails)
                    }else if(response!.statusCode == 400){
                        self.validationErrorsCodes(JSON!)
                    }else {
                        self.messagesErrorsCodes(JSON!)
                    }
                }
            }
        }
    
    public func loginUser(login : NSDictionary) {
        
        var requestUrl = "\(WAVELABS_HOST_URL)\(identityApiUrl)\(loginUrl)"

        let token: AnyObject = utilities.getClientAccessToken()

        Alamofire.request(.POST, requestUrl, parameters: utilities.getParams(login), encoding: .JSON, headers : ["Authorization" : "Bearer \(token)"])
            .responseJSON { request, response, JSON, error in
                
                if(JSON != nil){
                    if(response!.statusCode == 200){
                        var userEntity : NewMemberApiModel = Communicator.userEntityFromJSON(JSON!)
                        self.delegate!.handleLogin!(userEntity)
                    }else if(response!.statusCode == 400){
                        self.validationErrorsCodes(JSON!)
                    }else {
                        self.messagesErrorsCodes(JSON!)
                    }
                }
        }
    }
    
    public func logOut() {
        
        var requestUrl = "\(WAVELABS_HOST_URL)\(identityApiUrl)\(logOutUrl)"
        let token: AnyObject = utilities.getUserAccessToken()
        
        Alamofire.request(.GET, requestUrl, parameters: nil, encoding: .JSON, headers : ["Authorization" : "Bearer \(token)"])
            .responseJSON { request, response, JSON, error in
                var statusCode : Int = response!.statusCode
                
                if(JSON != nil){
                    if(response!.statusCode == 200){
                        var messageCodeEntity : MessagesApiModel = Communicator.respMessageCodesFromJson(JSON!)
                        self.delegate!.handleLogOut!(messageCodeEntity)
                    }else if(response!.statusCode == 400){
                        self.validationErrorsCodes(JSON!)
                    }else if(response!.statusCode == 401){

                    }else {
                        self.messagesErrorsCodes(JSON!)
                    }
                    
                }
        }
    }

    public func changePassword(changePsw : NSDictionary) {
        
        var requestUrl = "\(WAVELABS_HOST_URL)\(identityApiUrl)\(changePswUrl)"

        let token: AnyObject = utilities.getUserAccessToken()
        
        Alamofire.request(.POST, requestUrl, parameters: utilities.getParams(changePsw), encoding: .JSON, headers : ["Authorization" : "Bearer \(token)"])
            .responseJSON { request, response, JSON, error in
                
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
    
    public func forgotPassword(forgotPsw : NSDictionary) {
        
        var requestUrl = "\(WAVELABS_HOST_URL)\(identityApiUrl)\(forgotPswUrl)"
        
        let token: AnyObject = utilities.getClientAccessToken()

        Alamofire.request(.POST, requestUrl, parameters: utilities.getParams(forgotPsw), encoding: .JSON, headers : ["Authorization" : "Bearer \(token)"])
            .responseJSON { request, response, JSON, error in
                var statusCode : Int = response!.statusCode
                
                if(JSON != nil){
                    
                    if(response!.statusCode == 200){
                        var messageCodeEntity : MessagesApiModel = Communicator.respMessageCodesFromJson(JSON!)
                        self.delegate!.handleMessages!(messageCodeEntity)
                    }else if(response!.statusCode == 400){
                        self.validationErrorsCodes(JSON!)
                    }else if(response!.statusCode == 401){
                        
                    }else {
                        self.messagesErrorsCodes(JSON!)
                    }
                }
        }
    }
    
    public func refreshToken() {
        
        let refreshToken: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("refresh_token")!
        
        var requestUrl = "\(WAVELABS_HOST_URL)\(refreshTokenUrl)?grant_type=refresh_token&refresh_token=\(refreshToken)&client_id=\(WAVELABS_CLIENT_ID)&scope=read"
        
        let token: AnyObject = utilities.getUserAccessToken()
        
        Alamofire.request(.POST, requestUrl, parameters: nil, encoding: .JSON,  headers : ["Authorization" : "Bearer \(token)"])
            .responseJSON { request, response, JSON, error in
                
                if(JSON != nil){
                    
                    if(response!.statusCode == 200){
                        
                        var tokenApi : TokenApiModel = Communicator.tokenDetailsEntity(JSON as! NSDictionary)
                        self.delegate!.handleRefreshTokenResponse!(tokenApi)
                        
                    }else if(response!.statusCode == 400){
                        self.validationErrorsCodes(JSON!)
                    }else if(response!.statusCode == 401){
                        self.delegate!.moveToLogin!()
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