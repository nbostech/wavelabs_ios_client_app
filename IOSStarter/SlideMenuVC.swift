//
//  SlideMenuVC.swift
//  APIStarters
//
//  Created by afsarunnisa on 6/19/15.
//  Copyright (c) 2015 NBosTech. All rights reserved.
//

import Foundation
import UIKit
import DigitsKit
import wavelabs_ios_client_api
import MBProgressHUD

class SlideMenuVC: UIViewController,UITableViewDelegate,getAuthApiResponseDelegate{

    
    var hud : MBProgressHUD = MBProgressHUD()

    @IBOutlet weak var sliderTableView: UITableView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    let menuArray: NSArray = [USER_SETTINGS_STR, USER_CHANGE_PASSWORD_STR, USER_SOCIAL_LINKS_STR, USER_LOGOUT_STR]
    
    var authApi : AuthApi = AuthApi()

    override func viewDidLoad() {
        super.viewDidLoad()
        authApi.delegate = self
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return menuArray.count
    }

    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!  {
        //variable type is inferred
//        var cell = tableView.dequeueReusableCellWithIdentifier("CELL", forIndexPath: indexPath) as UITableViewCell
//        var cell = tableView.dequeueReusableCellWithIdentifier("CELL") as? UITableViewCell

        let cell = tableView.dequeueReusableCellWithIdentifier("CELL", forIndexPath: indexPath)

//        if cell == nil {
//            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "CELL")
//        }
        
        //we know that cell is not empty now so we use ! to force unwrapping
        
        cell.textLabel!.text = menuArray.objectAtIndex(indexPath.row) as? String
        return cell
    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cellText: String = menuArray.objectAtIndex(indexPath.row) as! String
        
        if(cellText == USER_LOGOUT_STR){
            self.addProgreeHud()
            authApi.logOut()
            
        }else if(cellText == USER_SETTINGS_STR){
            performSegueWithIdentifier("menuToSettings", sender: self)
        }else if(cellText == USER_CHANGE_PASSWORD_STR){
            performSegueWithIdentifier("menuToChangepassword", sender: self)
        }else if(cellText == USER_SOCIAL_LINKS_STR){
            performSegueWithIdentifier("menuToSocialLinks", sender: self)
        }
    }

    
    // MARK: - API call response delegate
    
    
    func handleRefreshTokenResponse(tokenEntity:TokenApiModel){
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
        let alert = utilities.alertView("Alert", alertMsg: messageStr,actionTitle: "Ok")
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func handleValidationErrors(messageCodeEntityArray: NSArray){
        MBProgressHUD.hideHUDForView(self.view, animated: true)

        let errorMessage: NSMutableString = ""
        
        for var i = 0; i < messageCodeEntityArray.count; i++ {
            let messageCode : ValidationMessagesApiModel = messageCodeEntityArray.objectAtIndex(i) as! ValidationMessagesApiModel
            let messageStr = messageCode.message
            errorMessage.appendString(messageStr)
        }
        
        let alert = utilities.alertView("Alert", alertMsg: errorMessage as String,actionTitle: "Ok")
        self.presentViewController(alert, animated: true, completion: nil)
    }

    
    func handleLogOut(messageCodeEntity : MessagesApiModel){
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        self.performSegueWithIdentifier("menuToLogin", sender: self)
        Digits.sharedInstance().logOut()
    }

    func addProgreeHud(){
        hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.mode = .Indeterminate
        hud.labelText = "Loading"
    }

}