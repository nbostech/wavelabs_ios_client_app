//
//  DigitsSignUpVC.swift
//  IOSStarter
//
//  Created by afsarunnisa on 7/8/15.
//  Copyright (c) 2015 NBosTech. All rights reserved.
//

import Foundation
import UIKit
import StarteriOSClientAPI
import MBProgressHUD

class DigitsSignUpVC: UIViewController,getSocialApiResponseDelegate{

    var hud : MBProgressHUD = MBProgressHUD()

    var textFieldOffset: CGFloat = 0

    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var digitsSignUpScroll: UIScrollView!

    var socialApi : SocialApi = SocialApi()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation bar title
        self.title = "Registration"
        
        utilities.setLeftIcons("user-icon.png", textField: firstName)
        utilities.setLeftIcons("user-icon.png", textField: lastName)
        utilities.setLeftIcons("mail-icon.png", textField: email)

        
        if(utilities.deviceType() as! String == "iPhone 4/4s" || utilities.deviceType() as! String == "iPhone 5/5s"){
            textFieldOffset = 30
        }else if(utilities.deviceType() as! String == "iPhone 6" || utilities.deviceType() as! String == "iPhone 6 Plus"){
            textFieldOffset = 50
        }
        
        socialApi.delegate = self
        
    }
    
    
    
    @IBAction func digitsSignUpBtnClicked(sender: AnyObject) {
        
        var firstNameStr: String = firstName.text
        var emailStr: String = email.text
        var lastNameStr: String = lastName.text

        
        
        if(firstNameStr.isEmpty){
            
            utilities.setPlaceHolder(FIRST_NAME_IN_VALID_PLACEHOLDER, validateText: "Invalid", textField: firstName)
        }else{
            
            let defaults = NSUserDefaults.standardUserDefaults()
            var authorizationHeaders : String = defaults .objectForKey("authorizationHeaders") as! String
            var serviceProvider : String = defaults.objectForKey("serviceProvider") as! String
            defaults.synchronize()
            
            var digitsLoginDict : NSMutableDictionary = NSMutableDictionary()
            digitsLoginDict.setObject(CLIENT_ID, forKey: "clientId")
            digitsLoginDict.setObject(authorizationHeaders, forKey: "authorization")
            digitsLoginDict.setObject(serviceProvider, forKey: "provider")
            digitsLoginDict.setObject(firstNameStr, forKey: "firstName")
            digitsLoginDict.setObject(lastNameStr, forKey: "lastName")
            digitsLoginDict.setObject(emailStr, forKey: "email")
            
            self.addProgreeHud()
            socialApi.digitsLoginUser(digitsLoginDict)
        }
    }
    
    
    
    func textFieldDidBeginEditing(textField: UITextField){
        
        if(utilities.deviceType() as! String != "iPad"){
            if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)){
                digitsSignUpScroll.setContentOffset(CGPointMake(0, textField.frame.origin.y-textFieldOffset), animated: true)
            }
        }else{
            if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)){
                digitsSignUpScroll.setContentOffset(CGPointMake(0, textField.frame.origin.y-140), animated: true)
            }
        }

        if(textField == firstName){
            utilities.setPlaceHolder("First Name", validateText: "Valid", textField: firstName)
        }
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        if(utilities.deviceType() as! String != "iPad"){
            if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)){
                digitsSignUpScroll.setContentOffset(CGPointMake(0, -textFieldOffset), animated: true)
            }
        }else{
            if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)){
                digitsSignUpScroll.setContentOffset(CGPointMake(0, -60), animated: true)
            }
        }
    }


    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        
        if(textField == firstName){
            lastName.becomeFirstResponder()
        }else if(textField == lastName){
            email.becomeFirstResponder()
        }else if(textField == email){
            textField.resignFirstResponder()
        }
        return true
    }

    @IBAction func resignBtnClikced(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    
    
    // MARK: - WebService Delegate Methods
    
    func handleLogin(userEntity: NewMemberApiModel) {
        
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        
        
        if(userEntity.tokenApiModel != nil){
            
            var tokenEty : TokenApiModel = userEntity.tokenApiModel
            var memberEty : MemberApiModel = userEntity.memberApiModel
            let defaults = NSUserDefaults.standardUserDefaults()
            let accessToken = tokenEty.access_token
            
            let date = NSDate()
            
            
            defaults.setObject(memberEty.id, forKey: "user_id")
            defaults.setObject(accessToken, forKey: "access_token")
            defaults.setObject(tokenEty.refresh_token, forKey: "refresh_token")
            defaults.setObject(tokenEty.expires_in, forKey: "expires_in")
            defaults.setObject(date, forKey: "startDate")
            
            defaults.synchronize()
            
            
            self.performSegueWithIdentifier("digitsSignUpToDashboard", sender: self)
        }
    }
    
    
    func handleMessages(messageCodeEntity : MessagesApiModel){
        
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        
        
        let messageStr = messageCodeEntity.message
        var alert = utilities.alertView("Alert", alertMsg: messageStr,actionTitle: "Ok")
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func handleValidationErrors(messageCodeEntityArray: NSArray){
        
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        
        var errorMessage: NSMutableString = ""
        
        for var i = 0; i < messageCodeEntityArray.count; i++ {
            var messageCode : ValidationMessagesApiModel = messageCodeEntityArray.objectAtIndex(i) as! ValidationMessagesApiModel
            let messageStr = messageCode.message
            errorMessage.appendString(messageStr)
        }
        
        var alert = utilities.alertView("Alert", alertMsg: errorMessage as String,actionTitle: "Ok")
        self.presentViewController(alert, animated: true, completion: nil)
    }

    
    func addProgreeHud(){
        hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.mode = .Indeterminate
        hud.labelText = "Loading"
    }

    
}