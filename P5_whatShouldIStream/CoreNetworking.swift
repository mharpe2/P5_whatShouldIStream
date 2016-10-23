//
//  BasicNetworking.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 5/4/16.
//  Copyright © 2016 MJH. All rights reserved.
//  
//  isConnectedToNetwork from
//  http://stackoverflow.com/questions/30743408/check-for-internet-connection-in-swift-2-ios-9


import Foundation
import SystemConfiguration
import CoreData
import BNRCoreDataStack

class CoreNetwork {
    
    typealias CompletionHander = (_ result: AnyObject?, _ error: NSError?) -> Void
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, UnsafePointer($0))
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        let isReachable = flags == .reachable
        let needsConnection = flags == .connectionRequired
        
        return isReachable && !needsConnection
        
    }


    class func getJsonFromHttp(location: String, completionHandler: @escaping CompletionHander) {
        
        let requestURL: NSURL = NSURL(string: location)!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL as URL)
        let session = URLSession.shared
        
        let task = session.dataTask(with: urlRequest as URLRequest)   {
            (data, response, error) -> Void in
            
            let httpsResponse = response as! HTTPURLResponse
            let statusCode = httpsResponse.statusCode
            
            if statusCode == 200 {
                    parseJSONWithCompletionHandler(data!) {
                    (result, error) in
                    
                    if error == nil {
                        completionHandler(result: result, error: nil)
                        //print(result)
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
            parsedResult = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.AllowFragments)
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        }
        
        if let error = parsingError {
            completionHandler(nil, error)
        } else {
          
            completionHandler(parsedResult, nil)
        }
    }
    
    class func errorForData(data: NSData?, response: URLResponse?, error: NSError, errorMsg: String) -> NSError {
        
        if data == nil {
            return error
        }
        
        do {
            let parsedResult = try JSONSerialization.jsonObject(with: data! as Data, options: JSONSerialization.ReadingOptions.allowFragments)
            
            if let parsedResult = parsedResult as? [String : AnyObject], let errorMessage = parsedResult[errorMsg] as? String {
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
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
    }
    
    
   
    // downloadListFromNetwork 
    //      getjsonfromHTTP -> jsson dictionary
    
    
    static func performUpdateInBackround(context: NSManagedObjectContext) -> Int {
        
        //var updatesMade = 0
        let log = XCGLogger.defaultInstance()
        
        //Download list stored in json format
        CoreNetwork.getJsonFromHttp(MasterLists.googleDriveLocation) {
            (result, error) in
            if error == nil {
                guard let listsDict = result["lists"] as? [[String:AnyObject]] else
                {
                    log.verbose("Error processing list to dictionary")
                    return
                }
                
                //self.mainContext().performBlockAndWait() {
                //let workerContext = context.per
                    //CoreDataStackManager.sharedInstance().coreDataStack!.newBackgroundWorkerMOC()
                
                  //context.performBlock() {
                    for item in listsDict {
                        
                        // generate list from dictionary and insert into context if they
                        // are unique
                        log.info("Creating Lists")
                        
                        let currentList = List.ListFromDictionary(item, inManagedObjectContext: context )
                        log.info("Created \(currentList)")
                    } // end for list
                    
                    // get all the lists and download movie info where list.movies
                    // is empty
                    let allLists = List.fetchLists(inManagedObjectContext: context )
                    for list in allLists where (list.movies.count == 0)
                    {
                        TheMovieDB.sharedInstance().getMoviesFromList(list) { result, error in
                            if let error = error {
                                log.error("\(error.localizedDescription)")
                            } else {
                                // process array of dictionaries into movies
                                // competion returns [[String: AnyObject]]
                                
                                for movie in result! {
                                    let currentMovie = Movie.MovieFromDictionary(movie, inManagedObjectContext: context)
                                    
                                    currentMovie?.list = list
                                    
                                   // context.saveContext()
                                    log.info("Added \(currentMovie!.title) to list \(list.name)")
                                }
                                
                            } // End of else
                        } // End of TheMovieDB.getMoviesFromList
                    } // End of for list in allLists
                   // context.saveContext()
                //} // End of self.mainContext().performBlockAndWait()
                
                
            }
            else {
            log.error("Error updating getJsonFromHttp")
            }
        }
            return 0
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


