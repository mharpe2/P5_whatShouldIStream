//
//  BasicNetworking.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 5/4/16.
//  Copyright © 2016 MJH. All rights reserved.


import Foundation

class CoreNetwork {
    
    typealias CompletionHander = (result: AnyObject!, error: NSError?) -> Void

    class func getJsonFromHttp(location: String, completionHandler: CompletionHander) {
        
        let requestURL: NSURL = NSURL(string: location)!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(urlRequest)   {
            (data, response, error) -> Void in
            
            let httpsResponse = response as! NSHTTPURLResponse
            let statusCode = httpsResponse.statusCode
            
            if statusCode == 200 {
                    parseJSONWithCompletionHandler(data!) {
                    (result, error) in
                    
                    if error == nil {
                        completionHandler(result: result, error: nil)
                        print(result)
                    }
                    else {
                        print("error occured \(error?.localizedDescription)")
                        completionHandler(result: nil, error: error)
                    }
                }
            }
        } //end task
        
        task.resume()
    }
    
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: CompletionHander) {
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        }
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
          
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError, errorMsg: String) -> NSError {
        
        if data == nil {
            return error
        }
        
        do {
            let parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
            
            if let parsedResult = parsedResult as? [String : AnyObject], errorMessage = parsedResult[errorMsg] as? String {
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                return NSError(domain: "Error", code: 1, userInfo: userInfo)
            }
            
        } catch _ {}
        
        return error
    }


    
    // URL Encoding a dictionary into a parameter string
    
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            // make sure that it is a string value
            let stringValue = "\(value)"
            
            // Escape it
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            // Append it
            
            if let unwrappedEscapedValue = escapedValue {
                urlVars += [key + "=" + "\(unwrappedEscapedValue)"]
            } else {
                print("Warning: trouble excaping string \"\(stringValue)\"")
            }
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
}




//class HttpDownloader {
//    //http://stackoverflow.com/questions/28219848/download-file-in-swift
//    class func loadFileSync(url: NSURL, saveAs: String, completion:(path:String, error:NSError!) -> Void) {
//        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as NSURL!
//        let destinationUrl = documentsUrl.URLByAppendingPathComponent(saveAs)
//        if NSFileManager().fileExistsAtPath(destinationUrl.path!) {
//            print("file already exists [\(destinationUrl.path!)]")
//            completion(path: destinationUrl.path!, error:nil)
//        } else if let dataFromURL = NSData(contentsOfURL: url){
//            if dataFromURL.writeToURL(destinationUrl, atomically: true) {
//                print("file saved [\(destinationUrl.path!)]")
//                completion(path: destinationUrl.path!, error:nil)
//            } else {
//                print("error saving file")
//                let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
//                completion(path: destinationUrl.path!, error:error)
//            }
//        } else {
//            let error = NSError(domain:"Error downloading file", code:1002, userInfo:nil)
//            completion(path: destinationUrl.path!, error:error)
//        }
//    }
//
//    class func loadFileAsync(url: NSURL, completion:(path:String, error:NSError!) -> Void) {
//        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as NSURL!
//        let destinationUrl = documentsUrl.URLByAppendingPathComponent(url.lastPathComponent!)
//        if NSFileManager().fileExistsAtPath(destinationUrl.path!) {
//            print("file already exists [\(destinationUrl.path!)]")
//            completion(path: destinationUrl.path!, error:nil)
//        } else {
//            let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
//            let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
//            let request = NSMutableURLRequest(URL: url)
//            request.HTTPMethod = "GET"
//            let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
//                if (error == nil) {
//                    if let response = response as? NSHTTPURLResponse {
//                        print("response=\(response)")
//                        let content = response.allHeaderFields
//                        let name = content["Content-Disposition"]
//                        print( "\(name)")
//                        if response.statusCode == 200 {
//                            if data!.writeToURL(destinationUrl, atomically: true) {
//                                print("file saved [\(destinationUrl.path!)]")
//                                completion(path: destinationUrl.path!, error:error)
//                            } else {
//                                print("error saving file")
//                                let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
//                                completion(path: destinationUrl.path!, error:error)
//                            }
//                        }
//                    }
//                }
//                else {
//                    print("Failure: \(error!.localizedDescription)");
//                    completion(path: destinationUrl.path!, error:error)
//                }
//            })
//            task.resume()
//        }
//    }
//}


//class fileUtil {
//
//    // returns list id hosted on TMDB
//    class func parseFile(fileName: String) -> String? {
//
//        let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
//        let path = (documents as NSString).stringByAppendingPathComponent(fileName)
//        do {
//            let content = try String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
//            return content
//        } catch _ as NSError {
//            return nil
//        }
//    }
//
//}


