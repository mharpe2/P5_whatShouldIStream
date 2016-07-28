//
//  GuideBox.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 5/20/16.
//  Copyright © 2016 MJH. All rights reserved.
//

import Foundation


class GuideBox: NSObject {
    
    typealias CompletionHander = (result: AnyObject!, error: NSError?) -> Void
    
    var session: NSURLSession
    
    //var config = Config.unarchivedInstance() ?? Config()
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    
    // MARK: - All purpose task method for data
    
    func taskForResource(resource: String, parameters: [String : AnyObject], completionHandler: CompletionHander) -> NSURLSessionDataTask {
        
        var mutableParameters = parameters
        var mutableResource = resource
        
                
        // Substitute the id parameter into the resource
        if resource.rangeOfString(":id") != nil {
            //assert(parameters[Keys.ID] != nil)
            
            mutableResource = mutableResource.stringByReplacingOccurrencesOfString(":id", withString: "\(parameters[Keys.ID]!)")
            mutableParameters.removeValueForKey(Keys.ID)
        }
        
        
        // Substitute the id parameter into the resource
        if resource.rangeOfString(":showname") != nil {
            //assert(parameters[":showname"] != nil)
            
            mutableResource = mutableResource.stringByReplacingOccurrencesOfString(":showname", withString: "\(parameters["showname"]!)")
            mutableParameters.removeValueForKey(":showname")
        }

        
        let urlString = Constants.BaseUrlSSL + mutableResource + CoreNetwork.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        print(url)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                let newError = GuideBox.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            } else {
                
                CoreNetwork.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
        }
        
        task.resume()
        
        return task
    }
    
//    // MARK: - All purpose task method for images
//    
//    func taskForImageWithSize(size: String, filePath: String, completionHandler: (imageData: NSData?, error: NSError?) ->  Void) -> NSURLSessionTask {
//        
//        let baseURL = NSURL(string: config.secureBaseImageURLString)!
//        let url = baseURL.URLByAppendingPathComponent(size).URLByAppendingPathComponent(filePath)
//        
//        print(url)
//        
//        let request = NSURLRequest(URL: url)
//        
//        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
//            
//            if let error = downloadError {
//                let newError = GuideBox.errorForData(data, response: response, error: error)
//                completionHandler(imageData: nil, error: newError)
//            } else {
//                completionHandler(imageData: data, error: nil)
//            }
//        }
//        
//        task.resume()
//        
//        return task
//    }
    
    
    // MARK: - Helpers
    
    
    // Try to make a better error, based on the status_message from TheMovieDB. If we cant then return the previous error
    
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        
        if data == nil {
            return error
        }
        
        do {
            let parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
            
            if let parsedResult = parsedResult as? [String : AnyObject], errorMessage = parsedResult[GuideBox.Keys.ErrorStatusMessage] as? String {
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                return NSError(domain: "GuideBox Error", code: 1, userInfo: userInfo)
            }
            
        } catch _ {}
        
        return error
    }
    
       // MARK: - Shared Instance
    
    class func sharedInstance() -> GuideBox {
        
        struct Singleton {
            static var sharedInstance = GuideBox()
        }
        
        return Singleton.sharedInstance
    }
    
}