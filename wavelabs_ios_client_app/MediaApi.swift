//
//  MediaApi.swift
//  IOSStarter
//
//  Created by afsarunnisa on 1/27/16.
//  Copyright (c) 2016 NBosTech. All rights reserved.
//

import Foundation
import Alamofire

@objc public protocol getMediaApiResponseDelegate {
    
    optional func handleMedia(mediaEntity:MediaApiModel)
    
    optional func handleMessages(messageCodeEntity: MessagesApiModel)
    optional func handleValidationErrors(messageCodeEntityArray: NSArray) // multiple MessagesRespApiModel - 404(Validation errors)
    optional func handleRefreshToken(JSON : AnyObject) // multiple MessagesRespApiModel - 404(Validation errors)

}


public class MediaApi {
    
    public var delegate: getMediaApiResponseDelegate?
    var apiUrl : String = "api/media/v0/"

    var mediaUrl : String = "media"
    
    public init() {
        
    }

    
    public func getMedia(){
        
       let defaults = NSUserDefaults.standardUserDefaults()
        let userID = defaults.stringForKey("user_id")
        
        var requestUrl =  "\(WAVELABS_HOST_URL)\(apiUrl)\(mediaUrl)?id=\(userID!)&mediafor=profile"
        let token: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("access_token")!
        
        
        Alamofire.request(.GET, requestUrl, parameters: nil, encoding: .JSON, headers : ["Authorization" : "Bearer \(token)"])
            .responseJSON { request, response, JSON, error in
                
                var statusCode : Int = response!.statusCode
                
                if(JSON != nil){
                    if(response!.statusCode == 200){
                        var mediaApiEntity : MediaApiModel = Communicator.respMediaFromJson(JSON!)
                        self.delegate!.handleMedia!(mediaApiEntity)
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
    
    public func uploadMedia(){
        var requestUrl = "\(WAVELABS_HOST_URL)\(apiUrl)\(mediaUrl)"
        
        let token: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("access_token")!
        
        var dirPath: String = ""
        let nsDocumentDirectory = NSSearchPathDirectory.DocumentDirectory
        let nsUserDomainMask    = NSSearchPathDomainMask.UserDomainMask
        
        if let paths            = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true){
            if paths.count > 0{
                dirPath = (paths[0] as? String)!
            }
        }
        
        var imagesDirectory : String = dirPath.stringByAppendingPathComponent("Images")
        let defaults = NSUserDefaults.standardUserDefaults()
        let userID = defaults.stringForKey("user_id")
        var fileName : String =  NSString(format:"%@.png", userID!) as String
        var storePath : String = imagesDirectory.stringByAppendingPathComponent(fileName)
        
        let imageData = UIImageJPEGRepresentation(UIImage(contentsOfFile: storePath), 1)
        
        
        let key = "id"
        let value = String(format: "%@",userID!)
        
        let key1 = "mediafor"
        let value1 = "profile"
        

        
        let filename = "file"
        
        
        Alamofire.upload(
            .POST,
            URLString: requestUrl, // http://httpbin.org/post
            headers : ["Authorization" : "Bearer \(token)"],
            multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(data: (value.dataUsingEncoding(NSUTF8StringEncoding)!), name: key)
                multipartFormData.appendBodyPart(data: (value1.dataUsingEncoding(NSUTF8StringEncoding)!), name: key1)
                multipartFormData.appendBodyPart(data: imageData!, name: "\(filename)",fileName: "img.png",mimeType: "image/png")
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { request, response, JSON, error in
                        
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
                case .Failure(let encodingError):
                    print(encodingError)
                }
            }
        )
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


