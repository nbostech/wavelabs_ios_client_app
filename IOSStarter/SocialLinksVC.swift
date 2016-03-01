//
//  SocialLinksVC.swift
//  APIStarters
//
//  Created by afsarunnisa on 6/26/15.
//  Copyright (c) 2015 NBosTech. All rights reserved.
//

import Foundation
import UIKit
import DigitsKit
import StarteriOSClientAPI
import FBSDKCoreKit
import FBSDKLoginKit
import MBProgressHUD

//GPPSignInDelegate

class SocialLinksVC: UIViewController,GIDSignInUIDelegate,GIDSignInDelegate,getUsersApiResponseDelegate,getSocialApiResponseDelegate,getAuthApiResponseDelegate{

    var hud : MBProgressHUD = MBProgressHUD()

    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var mainScrollview: UIScrollView!
    @IBOutlet weak var LinkedAccountsView: UIView!
    @IBOutlet weak var socialLinksView: UIView!
    
    var socialLinkSuccessResponse : NSDictionary =  [:]
    var socialLinkFailureResponse : NSDictionary =  [:]

    @IBOutlet weak var signInButton: GIDSignInButton!

    var numberOfRows : Int = 4
    
    var iconOrigionX : CGFloat = 0
    var iconWidth : CGFloat = 0
    var iconHeight : CGFloat = 0
    var xGap: CGFloat = 0
    var yGap: CGFloat = 0
    var mainScrollViewContentHeight : CGFloat = 0
    var view1Height : CGFloat = 0
    var view2Height : CGFloat = 0
   
    var redirectUrl : String = ""
    var webViewTitle : String = ""

    
    var socialActs: NSMutableArray = []
    
    var linkeAccountsheightConstraint:NSLayoutConstraint!
    var socialLinksheightConstraint:NSLayoutConstraint!

    var socialLinksArray : NSMutableArray = [SOCIAL_FACEBOOK_BTN,SOCIAL_GOOGLE_BTN,SOCIAL_LINKEDIN_BTN,SOCIAL_GITHUB_BTN,SOCIAL_INSTAGRAM_BTN]
    var usersApi = UsersApi()
    var socialApi : SocialApi = SocialApi()
    var authApi : AuthApi = AuthApi()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation bar title
        self.title = "Social Links"
        
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
        
        if (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad){
        
            iconOrigionX = 21
            iconWidth = 60
            iconHeight = 60
            
            xGap = 15
            yGap = 4

            if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)){
                numberOfRows = 12
            }else {
                numberOfRows = 9
            }
            
        }else{
            if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)){
                numberOfRows = 8
            }else{
                numberOfRows = 5
            }
            
            iconOrigionX = 21
            iconWidth = 48
            iconHeight = 48
            
            xGap = 15
            yGap = 4
        }
        
        LinkedAccountsView.setNeedsDisplay()
        
        self.refreshSocailViews()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self

        socialApi.delegate = self
        usersApi.delegate = self
        authApi.delegate = self

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.getSocialAccountsDetails()
    }
    
    override func viewDidLayoutSubviews() {
    }

    func getSocialAccountsDetails(){
        
        self.addProgreeHud()
        usersApi.getProfile()
        
    }

    func refreshSocailViews(){
        socialActs = USER_SOCIAL_CONNECTS
        var socialActCount : Int = socialActs.count
        
        
        if(socialActCount > 0){
            self.addUserSocialAccounts(socialActs, view: LinkedAccountsView, isLinkedAccount: true)
            for var i = 0; i < socialActs.count; i++ {
                
                var socialActEntity : SocialApiModel = socialActs.objectAtIndex(i) as! SocialApiModel
                var linkedSocialStr: String = socialActEntity.socialType
                
                for var j = 0; j < socialLinksArray.count; j++ {
                    var socailTypeStr: String = socialLinksArray.objectAtIndex(j) as! String
                    if(socailTypeStr == linkedSocialStr){
                        socialLinksArray.removeObject(socailTypeStr)
                        break
                    }else{
                        continue
                    }
                }
            }
            self.adjustSocialLinksArray()
        }else{
            
            linkeAccountsheightConstraint = NSLayoutConstraint(
                item:LinkedAccountsView, attribute:NSLayoutAttribute.Height,
                relatedBy:NSLayoutRelation.Equal,
                toItem:nil, attribute:NSLayoutAttribute.NotAnAttribute,
                multiplier:0, constant:0)
            
            mainScrollview.addConstraint(linkeAccountsheightConstraint)
            self.addUserSocialAccounts(socialLinksArray, view: socialLinksView, isLinkedAccount: false)
        }
    }
    
    

    func rotated(){
        
        if (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad){
            if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)){
                numberOfRows = 12
            }else{
                numberOfRows = 9
            }
            
            self.addUserSocialAccounts(socialActs, view: LinkedAccountsView, isLinkedAccount: true)
            self.addUserSocialAccounts(socialLinksArray, view: socialLinksView, isLinkedAccount: false)

        }else{
            if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)){
                println("landscape")
                numberOfRows = 8
            }else{
                numberOfRows = 4
            }
            
            self.addUserSocialAccounts(socialActs, view: LinkedAccountsView, isLinkedAccount: true)
            self.addUserSocialAccounts(socialLinksArray, view: socialLinksView, isLinkedAccount: false)
        }
    }
    

    
    func createIcons(Btnframe:CGRect, value:String,index: Int,buttonAction : Bool,parentView: UIView){

        let button   = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        button.frame = Btnframe
        button.tag = index
        
        var socialTypeImgName : String = ""
        
        if(value == SOCIAL_FACEBOOK_BTN){
            socialTypeImgName = "facebook.png"
        }else if(value == "Twitter"){
            socialTypeImgName = "twitter.png"
        }else if(value == SOCIAL_LINKEDIN_BTN){
            socialTypeImgName = "linkedin.png"
        }else if(value == SOCIAL_GITHUB_BTN){
            socialTypeImgName = "github.png"
        }else if(value == SOCIAL_INSTAGRAM_BTN){
            socialTypeImgName = "instagram.png"
        }
        
        let image = UIImage(named: socialTypeImgName) as UIImage?
        button.setImage(image, forState: .Normal)

        if(buttonAction == true){
            button.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        }

        
        if(value == SOCIAL_GOOGLE_BTN){
            
            var googleBtn = GIDSignInButton(frame: Btnframe)
            googleBtn.style = GIDSignInButtonStyle.IconOnly
            googleBtn.colorScheme = GIDSignInButtonColorScheme.Dark
            parentView.addSubview(googleBtn)
        
        }else{
            parentView.addSubview(button)
        }
    }
    

    
    // MARK: - Social connect button Methods
    
    
    func buttonAction(sender:UIButton!){
        
        var socialStrVal: String = socialLinksArray.objectAtIndex(sender.tag) as! String
        println("socialStrVal \(socialStrVal)")

        if(socialStrVal == SOCIAL_FACEBOOK_BTN){
            self.fbLogin()
        }else if(socialStrVal == SOCIAL_LINKEDIN_BTN){
            self.linkedInLogin()
        }else if(socialStrVal == SOCIAL_INSTAGRAM_BTN){
            self.instagramLogin()
        }else if(socialStrVal == SOCIAL_GITHUB_BTN){
            self.gitHubLogin()
        }
    }
    
    
    
    // MARK: - Google Plus Delegate Methods
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
        withError error: NSError!) {
            if (error == nil) {
                // Perform any operations on signed in user here.
                let userId = user.userID                  // For client-side use only!
                let idToken = user.authentication.idToken // Safe to send to the server
                let name = user.profile.name
                let email = user.profile.email
                
                let expiry = user.authentication // Safe to send to the server
                let accessToken = user.authentication.accessToken // Safe to send to the server
                
                var client_ID = NSBundle.mainBundle().infoDictionary?["WavelabsAPISettings"]!.objectForKey("WAVELABS_CLIENT_ID") as! String
                
                
                var socialLoginDict : NSMutableDictionary = NSMutableDictionary()
                socialLoginDict.setObject(accessToken, forKey: "accessToken")
                socialLoginDict.setObject("", forKey: "expiresIn")
                socialLoginDict.setObject(CLIENT_ID, forKey: "clientId")
                
                self.addProgreeHud()
                socialApi.socialConnect(socialLoginDict, socialType: "googlePlus")
                
            } else {
                print("\(error.localizedDescription)")
            }
    }

    // MARK: - Facebook Delegate Methods

    func fbLogin() {
        var fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logInWithReadPermissions(["email"], fromViewController: self, handler: { (result, error) -> Void in
            if (error == nil){
                var fbloginresult : FBSDKLoginManagerLoginResult = result
                
                if(fbloginresult.grantedPermissions != nil){
                    if(fbloginresult.grantedPermissions.contains("email")){
                        self.getFBUserData()
                        fbLoginManager.logOut()
                    }
                }
            }
        })
    }
    
    func getFBUserData(){
    
        let fbAccessToken = FBSDKAccessToken.currentAccessToken().tokenString

        var socialLoginDict : NSMutableDictionary = NSMutableDictionary()
        socialLoginDict.setObject(fbAccessToken, forKey: "accessToken")
        socialLoginDict.setObject("", forKey: "expiresIn")
        socialLoginDict.setObject(CLIENT_ID, forKey: "clientId")
        
        self.addProgreeHud()
        socialApi.socialConnect(socialLoginDict, socialType: "facebook")
    }
    
    
    func linkedInLogin(){
        self.webViewTitle = SOCIAL_LINKEDIN_BTN
        self.addProgreeHud()
        socialApi.socialWebConnect("linkedIn")
    }
    
    func instagramLogin(){
        self.webViewTitle = SOCIAL_INSTAGRAM_BTN
        self.addProgreeHud()
        socialApi.socialWebConnect("instagram")
    }
    
    func gitHubLogin(){
        self.webViewTitle = SOCIAL_GITHUB_BTN
        self.addProgreeHud()
        socialApi.socialWebConnect("gitHub")
    }
    
    
    func addUserSocialAccounts(socialArrays: NSMutableArray,view:UIView,isLinkedAccount:Bool){
        for subView in view.subviews {
            subView.removeFromSuperview()
        }

        var viewHeight : CGFloat = 60
        
        var originX : CGFloat = iconOrigionX
        var origioY : CGFloat = 0
        var width : CGFloat = iconWidth
        var height : CGFloat = iconHeight
        
        for var index = 0; index < socialArrays.count; index++ {
            var socialActType : String = ""
            var isButtonAction : Bool
            
            if(isLinkedAccount == true){
                var socailActDict : SocialApiModel = socialActs.objectAtIndex(index
                    ) as! SocialApiModel
                socialActType = socailActDict.socialType
                isButtonAction = false
            }else{
                socialActType = socialArrays.objectAtIndex(index) as! String
                isButtonAction = true
            }
            
            let rect = CGRect(x: originX, y: origioY, width: width, height: height)
            
            self.createIcons(rect,value: socialActType,index: index,buttonAction: isButtonAction,parentView:view)
            
            if(view == socialLinksView){
                if(socialLinksheightConstraint != nil){
                    mainScrollview.removeConstraint(socialLinksheightConstraint)
                }
                
                socialLinksheightConstraint  = (NSLayoutConstraint(
                    item:view, attribute:NSLayoutAttribute.Height,
                    relatedBy:NSLayoutRelation.Equal,
                    toItem:nil, attribute:NSLayoutAttribute.NotAnAttribute,
                    multiplier:0, constant:viewHeight))
                
                mainScrollview.addConstraint(socialLinksheightConstraint)
                
            }else if(view == LinkedAccountsView){
                if(linkeAccountsheightConstraint != nil){
                    mainScrollview.removeConstraint(linkeAccountsheightConstraint)
                }
                linkeAccountsheightConstraint  = (NSLayoutConstraint(
                    item:view, attribute:NSLayoutAttribute.Height,
                    relatedBy:NSLayoutRelation.Equal,
                    toItem:nil, attribute:NSLayoutAttribute.NotAnAttribute,
                    multiplier:0, constant:viewHeight))
                
                mainScrollview.addConstraint(linkeAccountsheightConstraint)
            }
            
            var val: Int = index+1
            var value : Int = val%numberOfRows
            
            if(val%numberOfRows != 0){
                //                  icons views
                originX += xGap+width
                
            }else{
                //                    increase height
                
                originX = iconOrigionX
                origioY += 4+height
                viewHeight += iconHeight + yGap
            }
        }
        
        if(view == socialLinksView){
            view1Height = viewHeight
            
        }else{
            view2Height = viewHeight
        }
        
        mainScrollViewContentHeight = view1Height + view2Height
        self.mainScrollview.contentSize = CGSize(width:mainScrollview.frame.size.width, height: mainScrollViewContentHeight)
    }
    
    
    
    func adjustSocialLinksArray(){
        
        for var i = 0; i < socialActs.count; i++ {
            var socailActDict : SocialApiModel = socialActs.objectAtIndex(i) as! SocialApiModel
            var linkedSocialStr: String = socailActDict.socialType

            for var j = 0; j < socialLinksArray.count; j++ {
                var socailTypeStr: String = socialLinksArray.objectAtIndex(j) as! String
                if(socailTypeStr == linkedSocialStr){
                    socialLinksArray.removeObject(socailTypeStr)
                    break
                }else{
                    continue
                }
            }
        }
        self.addUserSocialAccounts(socialLinksArray, view: socialLinksView, isLinkedAccount: false)
    }
    
    
    
    // MARK: - Response Delegate Methods

    
    func handleProfile(memberEntity: MemberApiModel) {
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        USER_SOCIAL_CONNECTS = memberEntity.socialAccounts as! NSMutableArray
        self.refreshSocailViews()
    }

    func getSocialConnectResponse(messageCodeEntity : MessagesApiModel){
        MBProgressHUD.hideHUDForView(self.view, animated: true)

        let messageStr = messageCodeEntity.message
        var alert = utilities.alertView("Alert", alertMsg: messageStr,actionTitle: "Ok")
        self.presentViewController(alert, animated: true, completion: nil)
    }

    
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

        
    func handleWebLinkLoginResponse(responseDict : NSDictionary){
        MBProgressHUD.hideHUDForView(self.view, animated: true)

        if(responseDict["url"] != nil){
            self.redirectUrl = responseDict.objectForKey("url") as! String
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            var webViewVC: WebViewVC = mainStoryboard.instantiateViewControllerWithIdentifier("WebViewVC") as! WebViewVC
            webViewVC.redirectUrl = redirectUrl
            webViewVC.headerTitle = webViewTitle
            webViewVC.parentView  = "SocialLinkView"
            self.navigationController?.pushViewController(webViewVC, animated: true)
            
        }else{
            if(responseDict["message"] != nil){
                var alert = utilities.alertView("Alert", alertMsg: responseDict["message"] as! String, actionTitle: "Ok")
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
        
    func handleRefreshToken(JSON : AnyObject){
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        println("Refresh token")
        println("JSON \(JSON)")
        
        self.addProgreeHud()
        authApi.refreshToken()
    }
    
    
    func moveToLogin(){
        
        println("Self \(self)")
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        var loginVC: UINavigationController = mainStoryboard.instantiateViewControllerWithIdentifier("mainNavigation") as! UINavigationController
        
        self.presentViewController(loginVC, animated: true, completion: nil)
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


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "SocialLinkToWebView") {
            // pass data to next view
            
            if let destinationVC = segue.destinationViewController as? WebViewVC{
                destinationVC.redirectUrl = redirectUrl
                destinationVC.headerTitle = webViewTitle
                destinationVC.parentView  = "SocialLinkView"
            }
        }
    }
}