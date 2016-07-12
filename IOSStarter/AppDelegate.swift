//
//  AppDelegate.swift
//  IOSStarter
//
//  Created by afsarunnisa on 6/18/15.
//  Copyright (c) 2015 NBosTech. All rights reserved.
//

import UIKit
import Fabric
import TwitterKit
import DigitsKit
import wavelabs_ios_client_api


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,getAuthApiResponseDelegate {
    
    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Fabric.with([Twitter(),Digits()])
        
        // Initialize sign-in
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
      
//        if(NSUserDefaults.standardUserDefaults().objectForKey("access_token") != nil) {
//            var accessToken : String = NSUserDefaults.standardUserDefaults().objectForKey("access_token") as! String
//            var refreshToken : String = NSUserDefaults.standardUserDefaults().objectForKey("refresh_token") as! String
//            var startDate : NSDate = NSUserDefaults.standardUserDefaults().objectForKey("startDate") as! NSDate
//            var expiresIn : Int = NSUserDefaults.standardUserDefaults().objectForKey("expires_in") as! Int
//            
//            let interval = NSDate().timeIntervalSinceDate(startDate)
//            let intervalNum = NSNumber(double: interval)
//
//            
//            if(intervalNum.doubleValue > Double(expiresIn)){
//           
//                var authApi : AuthApi = AuthApi()
//                authApi.delegate = self
//                authApi.refreshToken()
//                
//            }else{
//            
//                self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
//                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                var settingsViewController: SWRevealViewController = mainStoryboard.instantiateViewControllerWithIdentifier("RevealVC") as! SWRevealViewController
//                
//                self.window?.rootViewController = settingsViewController
//                self.window?.makeKeyAndVisible()
//            }
//        }
        return true
    }
    
    
    func application(application: UIApplication,
        openURL url: NSURL,
        sourceApplication: String?,
        annotation: AnyObject?) -> Bool {
            
            var handled: Bool = false
            let isFb = url.scheme.hasPrefix("fb")
            
            if (isFb == true){
                handled = FBSDKApplicationDelegate.sharedInstance().application(
                    application,
                    openURL: url,
                    sourceApplication: sourceApplication,
                    annotation: annotation)
            } else if(url.path!.hasPrefix("/linkedin")){
                return true
            }else {
                return GIDSignIn.sharedInstance().handleURL(url,
                    sourceApplication: sourceApplication,
                    annotation: annotation)
            }
            
            if(LISDKCallbackHandler.shouldHandleUrl(url)){
                return LISDKCallbackHandler.application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
            }
            return handled
    }
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        
        FBSDKAppEvents.activateApp()
        
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func handleRefreshTokenResponse(tokenEntity:TokenApiModel){
    
        let defaults = NSUserDefaults.standardUserDefaults()
        let accessToken = tokenEntity.access_token
        
        let date = NSDate()

        defaults.setObject(accessToken, forKey: "access_token")
        defaults.setObject(tokenEntity.refresh_token, forKey: "refresh_token")
        defaults.setObject(tokenEntity.expires_in, forKey: "expires_in")
        defaults.setObject(date, forKey: "startDate")
        
        defaults.synchronize()
    }
    
    
    func getMessagesResponse(messageCodeEntity : MessagesApiModel){
        
        let messageStr = messageCodeEntity.message
        var alert = utilities.alertView("Alert", alertMsg: messageStr,actionTitle: "Ok")
    
    }
    
    
    func getValidationMessagesResponse(messageCodeEntityArray: NSArray){
        
        var errorMessage: NSMutableString = ""
        
        for var i = 0; i < messageCodeEntityArray.count; i++ {
            var messageCode : ValidationMessagesApiModel = messageCodeEntityArray.objectAtIndex(i) as! ValidationMessagesApiModel
            let messageStr = messageCode.message
            errorMessage.appendString(messageStr)
        }
        
        
        print("messages \(errorMessage)")

        var alert = utilities.alertView("Alert", alertMsg: errorMessage as String,actionTitle: "Ok")
    }

    
}

