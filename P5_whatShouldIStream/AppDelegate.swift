//
//  AppDelegate.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 4/11/16.
//  Copyright © 2016 MJH. All rights reserved.
//

import UIKit
import CoreData
import BNRCoreDataStack
import XCGLogger


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let log = XCGLogger.defaultInstance()
    var movieDB = TheMovieDB.sharedInstance()
    
    lazy var mainContext = {
        return CoreDataStackManager.sharedInstance().coreDataStack!.mainQueueContext
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        log.setup(.Debug, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil)
        log.info( "Documents Directory: \(documentsURL)" )
        
        CoreDataStack.constructSQLiteStack(withModelName: "Model") { result in
            switch result {
            case .Success(let stack):
                
                CoreDataStackManager.sharedInstance().coreDataStack = stack
                self.log.info("CoreData Stack running")
                
                if (self.movieDB.config.daysSinceLastUpdate > 1) ||
                    (self.movieDB.config.daysSinceLastUpdate == nil){
                    self.movieDB.config.updateTMDB()
                    self.performUpdate()
                }
                
            case .Failure(let error):
                print(error)
            }
            self.competion()
            
        }
        
        
        
        // Delay execution of my block for 10 seconds.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.log.verbose("Proceeding")
        }
        sleep(2)
        
        return true
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
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func performUpdate() -> Int {
        
        
        var updatesMade = 0
        
        log.verbose("resetting Coredata")
        self.mainContext().reset()
        var lists = NSMutableOrderedSet()
        
        CoreNetwork.getJsonFromHttp(MasterLists.googleDriveLocation) {
            (result, error) in
            if error == nil {
                guard let listsDict = result["lists"] as? [[String:AnyObject]] else
                {
                    self.log.verbose("Error processing list to dictionary")
                    return
                }
                lists = List.listsFromResults(listsDict, context: self.mainContext() )
            }
            else {
                self.log.verbose("Error updating")
            }
        }
        return lists.count
    }
    
    func competion() {
        log.verbose("Completion Handler")
        
        //TODO: whatever you want! Gosh!
    }
    
    
} // AppDelegate

