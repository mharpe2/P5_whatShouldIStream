//
//  TheMovieDB.swift
//  TheMovieDB
//
//
//

import Foundation

class TheMovieDB : NSObject {
    
    typealias CompletionHander = (_ result: AnyObject?, _ error: NSError?) -> Void
    
    var session: URLSession
    
    var config = Config.unarchivedInstance() ?? Config()
    
    override init() {
        session = URLSession.shared
        super.init()        
    }

    
    // MARK: - All purpose task method for data
    
    func taskForResource(resource: String, parameters: [String : AnyObject], completionHandler: @escaping CompletionHander) -> URLSessionDataTask {
        
        var mutableParameters = parameters
        var mutableResource = resource
        
        // Add in the API Key
        mutableParameters["api_key"] = Constants.ApiKey as AnyObject?
        
        // Substitute the id parameter into the resource
        if resource.rangeOfString(":id") != nil {
            assert(parameters[Keys.ID] != nil)
            
            mutableResource = mutableResource.stringByReplacingOccurrencesOfString(":id", withString: "\(parameters[Keys.ID]!)")
            mutableParameters.removeValue(forKey: Keys.ID)
        }
        
        let urlString = Constants.BaseUrlSSL + mutableResource + CoreNetwork.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
     
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in

            if let error = downloadError {
                let newError = CoreNetwork.errorForData(data, response: response, error: error, errorMsg: "taskForResourceError")
                completionHandler(result: nil, error: newError)
            } else {
                
                CoreNetwork.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
        }
        
        task.resume()
        
        return task
    }
    
    func taskForResource(resource: String, completionHandler: @escaping CompletionHander) -> URLSessionDataTask {
        
        var mutableResource = resource
        var mutableParameters = [String:AnyObject]()
        
        // Add in the API Key
        mutableParameters["api_key"] = Constants.ApiKey as AnyObject?
        
        let urlString = Constants.BaseUrlSSL + mutableResource + CoreNetwork.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
       
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                let newError = CoreNetwork.errorForData(data, response: response, error: error, errorMsg: "taskForResourceError")
                    //TheMovieDB.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            } else {
                
                CoreNetwork.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
        }
        task.resume()
        return task
    }

    
    // MARK: - All purpose task method for images
    
    func taskForImageWithSize(size: String, filePath: String, completionHandler: @escaping (_ imageData: NSData?, _ error: NSError?) ->  Void) -> URLSessionTask {
        
        let baseURL = NSURL(string: config.secureBaseImageURLString)!
        let url = baseURL.URLByAppendingPathComponent(size).URLByAppendingPathComponent(filePath)
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                let newError = CoreNetwork.errorForData(data, response: response, error: error, errorMsg: "taskForImageError")
                 completionHandler(imageData: nil, error: newError)
            } else {
                completionHandler(imageData: data, error: nil)
            }
        }
        
        task.resume()
        
        return task
    }
    
    
    // MARK: - Helpers
    
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> TheMovieDB {
        
        struct Singleton {
            static var sharedInstance = TheMovieDB()
        }
        
        return Singleton.sharedInstance
    }
    
    // MARK: - Shared Date Formatter
    
    class var sharedDateFormatter: DateFormatter  {
        
        struct Singleton {
            static let dateFormatter = Singleton.generateDateFormatter()
            
            static func generateDateFormatter() -> DateFormatter {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-M-d"
                
                return formatter
            }
        }
        
        return Singleton.dateFormatter
    }
    
    // MARK: - Shared Image Cache

    struct Caches {
        static let imageCache = ImageCache()
    }
    
    // MARK: - Help with updating the Config
    func updateConfig(completionHandler: @escaping (_ didSucceed: Bool, _ error: NSError?) -> Void) {
        
        let parameters = [String: AnyObject]()
        
        taskForResource(Resources.Config, parameters: parameters) { JSONResult, error in
            
            if let error = error {
                completionHandler(didSucceed: false, error: error)
            } else if let newConfig = Config(dictionary: JSONResult as! [String : AnyObject]) {
                self.config = newConfig
                completionHandler(didSucceed: true, error: nil)
            } else {
                completionHandler(didSucceed: false, error: NSError(domain: "Config", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse config"]))
            }
        }
        
    }
}
