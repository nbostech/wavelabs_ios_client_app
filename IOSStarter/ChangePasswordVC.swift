//
//  ChangePasswordVC.swift
//  APIStarters
//
//  Created by afsarunnisa on 6/22/15.
//  Copyright (c) 2015 NBosTech. All rights reserved.
//

import Foundation
import UIKit
import StarteriOSClientAPI
import MBProgressHUD

class ChangePasswordVC: UIViewController,getAuthApiResponseDelegate{
    
    @IBOutlet weak var menuButton:UIBarButtonItem!
    @IBOutlet weak var currentPasswordTF: UITextField!
    @IBOutlet weak var newPasswordTF: UITextField!
    @IBOutlet weak var changePasswordBtn: UIButton!
    @IBOutlet weak var resetPasswordByEmailBtn: UIButton!
    var authApi : AuthApi = AuthApi()

    var hud : MBProgressHUD = MBProgressHUD()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation bar title
        self.title = "Change Password"
        
        // navigation bar background and title colors
        var nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.Default
        nav?.tintColor = UIColor.darkGrayColor()
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        nav?.backgroundColor = UIColor.darkGrayColor()

        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        // email paddword left mode images
        
        utilities.setLeftIcons("lock-icon.png", textField: currentPasswordTF)
        utilities.setLeftIcons("lock-icon.png", textField: newPasswordTF)

        // login button corner radius
        changePasswordBtn.layer.cornerRadius = 2
        
        authApi.delegate = self
    }
    
    
    // MARK: - Button Actions

    @IBAction func resetPswdByEmailBtnClicked(sender: AnyObject) {
    }
    
    @IBAction func changePasswordBtnClicked(sender: AnyObject) {
        self.view.endEditing(true)

        var currentPswdStr: String = currentPasswordTF.text
        var newPswdStr: String = newPasswordTF.text
        
        if currentPswdStr.isEmpty {
            var alert = utilities.alertView("Alert", alertMsg: "Please enter current password",actionTitle: "Ok")
            self.presentViewController(alert, animated: true, completion: nil)
        }else if newPswdStr.isEmpty{
            var alert = utilities.alertView("Alert", alertMsg: "Please enter new password",actionTitle: "Ok")
            self.presentViewController(alert, animated: true, completion: nil)
        }else{
            
            var changePswDict : NSMutableDictionary = NSMutableDictionary()
            changePswDict.setObject(currentPswdStr, forKey: "password")
            changePswDict.setObject(newPswdStr, forKey: "newPassword")
            
            self.addProgreeHud()
            authApi.changePassword(changePswDict)
        }
    }
    
    
    @IBAction func resignBtnClikced(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    
    func handleRefreshToken(JSON : AnyObject){
        self.addProgreeHud()
        authApi.refreshToken()
    }
    
    
    func moveToLogin(){
        
        println("Self \(self)")
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        var loginVC: UINavigationController = mainStoryboard.instantiateViewControllerWithIdentifier("mainNavigation") as! UINavigationController
        
        self.presentViewController(loginVC, animated: true, completion: nil)
    }
    
    func handleRefreshTokenResponse(tokenEntity:TokenApiModel){
        println("tokenEntity \(tokenEntity)")

        MBProgressHUD.hideHUDForView(self.view, animated: true)
        let defaults = NSUserDefaults.standardUserDefaults()
        let accessToken = tokenEntity.access_token
        
        let date = NSDate()
        
        defaults.setObject(accessToken, forKey: "access_token")
        defaults.setObject(tokenEntity.refresh_token, forKey: "refresh_token")
        defaults.setObject(tokenEntity.expires_in, forKey: "expires_in")
        defaults.setObject(date, forKey: "startDate")
        
        defaults.synchronize()
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
