//
//  WebViewVC.swift
//  APIStarters
//
//  Created by afsarunnisa on 7/1/15.
//  Copyright (c) 2015 NBosTech. All rights reserved.
//

import Foundation


class WebViewVC: UIViewController,UIWebViewDelegate {
    
    
    var redirectUrl : String = ""
    var headerTitle : String = ""
    var parentView  : String = ""
    
    @IBOutlet weak var redirectWebView: UIWebView!

    var socialLinkSuccess : NSDictionary = [:]
    var socialLinkFailure : NSDictionary = [:]
    var doneButton : UIBarButtonItem = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let cookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        let cookies = cookieStorage.cookies
        
        for cookie in cookies! {
            print("name: \(cookie.name) value: \(cookie.value)")
            NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
        }

        
        self.title = headerTitle
        self.navigationItem.setHidesBackButton(true, animated:true);

        
        doneButton = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.Plain, target: self, action: "rightBtnClicked:")
        self.navigationItem.rightBarButtonItem = doneButton
        redirectWebView.delegate = self
        
        let url = NSURL (string: redirectUrl);
        let requestObj = NSURLRequest(URL: url!);
        redirectWebView.loadRequest(requestObj);
   
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject("", forKey: "webViewFailResponse")
        defaults.synchronize()
    }
    
    
    
    func rightBtnClicked(sender: AnyObject) {
        if let navController = self.navigationController {
            
            if(parentView == "LoginView"){
                
                print("navcontroller \(navController.topViewController)")
                
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject("", forKey: "webViewFailResponse")
                defaults.synchronize()
                navController.popViewControllerAnimated(true)

            }else if(parentView == "SocialLinkView"){
            
                socialLinkSuccess = [:]
                socialLinkFailure = [:]
                
                self.performSegueWithIdentifier("WebviewToSocialLinks", sender: self)
            }
        }
    }

    
    
    func webViewDidStartLoad(webView : UIWebView) {
        let htmlSource : String = redirectWebView.stringByEvaluatingJavaScriptFromString("document.documentElement.outerHTML")!
        print("htmlSource  while starts loading \(htmlSource)")
    }
    
    func webViewDidFinishLoad(webView : UIWebView) {
        print("BB")
        print("urk \(redirectWebView.request?.URL)")
        
        let htmlSource : String = redirectWebView.stringByEvaluatingJavaScriptFromString("document.documentElement.outerHTML")!
        print("htmlSource \(htmlSource)")
        
        var err : NSError?
        let parser     = HTMLParser(html: htmlSource, error: &err)
        if err != nil {
            print(err)
            exit(1)
        }
        
        let bodyNode   = parser.body
        
        if let inputNodes = bodyNode?.findChildTags("b") {
            for node in inputNodes {
                print("node.contents for b \(node.contents)")
            }
        }
        
        if let inputNodes = bodyNode?.findChildTags("pre") {
            for node in inputNodes {
                let temp : String = node.contents
                print("node.getAttributeNamed pre \(temp)")
                
                let data = (temp as NSString).dataUsingEncoding(NSUTF8StringEncoding)

                let myHTMLString:String! = "<h1> </h1>"
                redirectWebView.loadHTMLString(myHTMLString, baseURL: nil)

//                var jsonResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSDictionary

                
                var jsonResult : NSDictionary!
                
                do {
                    jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! [String:AnyObject]
                    // use anyObj here
                } catch {
                    print("json error: \(error)")
                }

                
                print("jsonResult \(jsonResult)")
                
                var tokenDetails : NSDictionary!
                var memberDetails : NSDictionary!
                
                if(jsonResult.objectForKey("token") != nil){
                    tokenDetails = jsonResult.objectForKey("token") as! NSDictionary
                }
                
                if(jsonResult.objectForKey("member") != nil){
                    memberDetails = jsonResult.objectForKey("member") as! NSDictionary
                }
                
                
                print("tokenDetails \(tokenDetails)")
                print("memberDetails \(memberDetails)")
                

                if(tokenDetails != nil && memberDetails != nil){
                   
                    if(parentView == "LoginView"){
                        
                        let defaults = NSUserDefaults.standardUserDefaults()
                        let accessToken = tokenDetails["access_token"]! as! String
                        defaults.setObject(accessToken, forKey: "access_token")
                        defaults.setObject(tokenDetails["refresh_token"]! as! String, forKey: "refresh_token")

                        defaults.setObject(memberDetails["id"]! as! Int, forKey: "user_id")
                        defaults.synchronize()
                        
                        self.performSegueWithIdentifier("WebViewToDashboard", sender: self)
                        
                    }else if(parentView == "SocialLinkView"){
                        socialLinkSuccess = jsonResult
                        self.performSegueWithIdentifier("WebviewToSocialLinks", sender: self)
                    }
                }else{
                    
                    if(jsonResult["message"] != nil){
                        let alert = UIAlertController(title: "Alert", message: jsonResult["message"] as? String, preferredStyle: UIAlertControllerStyle.Alert)
                        let cancelALertAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Default) { action -> Void in
                            self.rightBtnClicked(self.doneButton)
                        }
                        alert.addAction(cancelALertAction)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "WebviewToSocialLinks") {
            // pass data to next view
            
            let destinationNavigationController = segue.destinationViewController as! UINavigationController
            var targetController = destinationNavigationController.topViewController as! SocialLinksVC

            targetController.socialLinkSuccessResponse = socialLinkSuccess
            targetController.socialLinkFailureResponse = socialLinkFailure
                        
        }
    }
}