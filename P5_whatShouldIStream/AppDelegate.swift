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
    
    private let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
    private lazy var loadingVC: UIViewController = {
        return self.mainStoryBoard.instantiateViewController(withIdentifier: "LoadingVC")
    }()
    
    lazy var mainContext = {
        return CoreDataStackManager.sharedInstance().coreDataStack!.mainQueueContext
    }
    
    lazy var workerContext = {
        return CoreDataStackManager.sharedInstance().coreDataStack!.newBackgroundWorkerMOC
    }
    
    private lazy var firstTabBarVC: UITabBarController = {
        return self.mainStoryBoard.instantiateViewController(withIdentifier: "TabBarController")
            as! UITabBarController
    }()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        log.setup(.Debug, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil)
        log.info( "Documents Directory: \(documentsURL)" )
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = loadingVC
        
        CoreDataStack.constructSQLiteStack(withModelName: "Model") { result in
            switch result {
            case .Success(let stack):
                
                CoreDataStackManager.sharedInstance().coreDataStack = stack
                self.seedData()

                self.log.info("CoreData Stack running")
                TheMovieDB.sharedInstance().config.updateTMDB()
                let daysSinceUpdate = TheMovieDB.sharedInstance().config.daysSinceLastUpdate
                self.log.info("Days since last update \(daysSinceUpdate)")
                
                //                if (self.movieDB.config.daysSinceLastUpdate > 1) ||
                //                    (self.movieDB.config.daysSinceLastUpdate == nil){
                //                    self.movieDB.config.updateTMDB()
                //self.performUpdate()
                
                //}
                                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.mainStoryBoard.instantiateViewControllerWithIdentifier("ExploreViewController")
                    self.window?.rootViewController = self.firstTabBarVC
                }
                
            case .Failure(let error):
                print(error)
            }
            self.competion()
            
        }
        
        window?.makeKeyAndVisible()
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
        
        //var updatesMade = 0
        
        log.verbose("resetting Coredata")
        self.mainContext().reset()
        self.mainContext().saveContext()
        
        //Download list stored in json format
        CoreNetwork.getJsonFromHttp(MasterLists.googleDriveLocation) {
            (result, error) in
            if error == nil {
                guard let listsDict = result["lists"] as? [[String:AnyObject]] else
                {
                    self.log.verbose("Error processing list to dictionary")
                    return
                }
                
                //self.mainContext().performBlockAndWait() {
                //let workerContext = CoreDataStackManager.sharedInstance().coreDataStack!.newBackgroundWorkerMOC()
                self.mainContext().performBlock() {
                    for item in listsDict {
                        // generate list from dictionary and insert into context if they
                        // are unique
                        self.log.info("Creating Lists")
                        let currentList = List.ListFromDictionary(item, inManagedObjectContext: self.mainContext() )
                        self.log.info("Created \(currentList)")
                    } // end for list
                    
                    // get all the lists and download movie info where list.movies
                    // is empty
                    var allLists = List.fetchLists(inManagedObjectContext: self.mainContext() )
                    for list in allLists where (list.movies.count == 0)
                    {
                        TheMovieDB.sharedInstance().getMoviesFromList(list) { result, error in
                            if let error = error {
                                self.log.error("\(error.localizedDescription)")
                            } else {
                                // process array of dictionaries into movies
                                // competion returns [[String: AnyObject]]
                                
                                for movie in result! {
                                    var currentMovie = Movie.MovieFromDictionary(movie, inManagedObjectContext: self.mainContext())
                                    
                                    currentMovie?.list = list
                                    
                                    self.mainContext().saveContext()
                                    self.log.info("Added \(currentMovie!.title) to list \(list.name)")
                                }
                                
                            } // End of else
                        } // End of TheMovieDB.getMoviesFromList
                    } // End of for list in allLists
                    self.mainContext().saveContext()
                } // End of self.mainContext().performBlockAndWait()
                
            }
            else {
                self.log.error("Error updating getJsonFromHttp")
            }
        }
        
        // updateGeneresInBackround()
        return 0
    }
    
    private func competion() {
        log.verbose("Completion Handler")
        
        //TODO: whatever you want! Gosh!
    }
    
    
    private func updateGeneresInBackround() {
        //update genres in backround
        let workerContext = CoreDataStackManager.sharedInstance().coreDataStack!.newBackgroundWorkerMOC()
        workerContext.performBlock() {
            TheMovieDB.sharedInstance().getGenres("") {
                result, error in
                if error != nil {
                    self.log.verbose("\(error!.localizedDescription)")
                }
                self.log.info("there are \(result!.count) in results")
                Genre.genreFromResults(result!, context: self.mainContext())
            }
            workerContext.saveContext()
        }
    }
    
    private func updateGeneresInForeground() {
        //update genres in backround
        //let workerContext = CoreDataStackManager.sharedInstance().coreDataStack!.newBackgroundWorkerMOC()
        mainContext().performBlockAndWait() {
            TheMovieDB.sharedInstance().getGenres("") {
                result, error in
                if error != nil {
                    self.log.verbose("\(error!.localizedDescription)")
                }
                self.log.info("there are \(result!.count) in results")
                Genre.genreFromResults(result!, context: self.mainContext())
            }
            self.mainContext().saveContext()
        }
    }
    
    private func seedData() {
        
        // Grab path for seed files in Supporting Files folder
        guard let listData = fileToNSData("lists", ofType: "json") else {
            log.error("could not find seed data")
            return
        }
        
        CoreNetwork.parseJSONWithCompletionHandler(listData) {
            result, error in
            if error == nil {
                guard let listsDict = result["lists"] as? [[String:AnyObject]] else
                {
                    self.log.verbose("Error processing list to dictionary")
                    return
                }
                
                self.mainContext().performBlockAndWait() {
                    for item in listsDict {
                        // generate list from dictionary and insert into context if they
                        // are unique
                        self.log.info("Creating Lists")
                        let currentList = List.ListFromDictionary(item, inManagedObjectContext: self.mainContext() )
                        self.mainContext().saveContext()
                        self.log.info("Created \(currentList)")
                    } // end for list
                    
                    // convert files to json
                    guard let movieGenreData = self.fileToNSData("movieGenres", ofType: "json"),
                        let tvGenreData = self.fileToNSData("tvGenres", ofType: "json") else {
                            self.log.error("could not find seed data")
                            return
                    }
                    
                    //try to add convert nsdata to json and add to coredata
                    self.jsonGenreToCoreData(movieGenreData)
                    self.jsonGenreToCoreData(tvGenreData)
                    
                    //Download all movies from list
                    self.log.info("download movies from list")
                    self.downloadMoviesFromLists()
                    
                } // End performBlock
            } // End parseWithJson
        } // end parseJson with listData
        
    }
    
    
    private func fileToNSData(name: String, ofType:String) -> NSData? {
        
        guard let filePath = Bundle.main.path(forResource: name, ofType: ofType) else {
            log.error("could not find seed data file \(name).\(ofType)")
            return nil
        }
        
        var data: NSData
        do {
            data = try NSData(contentsOfFile: filePath, options: .mappedIfSafe)
        }   catch _ {
            log.error("Could not convert seed data to json")
            return nil
        }
        return data
    }
    
    
    private func jsonGenreToCoreData(json: NSData?) {
        guard let data = json else
        {
            log.error("Json not valid NSData")
            return
        }
        
        // interate Movie Genre data and add to core data
        CoreNetwork.parseJSONWithCompletionHandler(data) {
            result, error in
            if error != nil  {
                self.log.error("parseJson: \(error?.localizedDescription)")
                return
            }
            guard let results = result.valueForKey("genres") as? [[String:AnyObject]] else {
                self.log.error("error converting json results to [[string:anyobjec]]")
                return
            }
            
            // add unique genres to coredata async
            self.mainContext().performBlockAndWait() {
                for genre in results {
                    var g = Genre.genreFromDictionary(genre, inManagedObjectContext: self.mainContext() )
                    self.log.info("added genre \(g!.name)")
                    self.mainContext().saveContext()
                }
                self.mainContext().saveContext()
            }
            
        }
        
    }
    
    private func downloadMoviesFromLists() {
        
        self.mainContext().performBlockAndWait() {
            var lists = self.fetchLists()
            for list in lists {
                // if list.movies.count == 0 {
                    TheMovieDB.sharedInstance().getMoviesFromList(list) {
                        result, error in
                        if error != nil {
                            self.log.error("Could not download movies on list")
                            return
                        }
                            
                        else {
                            
                            // TMDB returned a movie dictionary
                            // insert it into coredata
                            self.mainContext().performBlockAndWait() {
                                if let movieResults  = result {
                                    let movies = Movie.moviesFromResults(movieResults, listID: list.id!, context: self.mainContext())
                                    list.movies = movies
                                    self.log.info("found \(movies.count)")
                                    self.mainContext().saveContext()
                                }
                            }
                        } // End of else
                        
                    } // End of getMoviesFromList
                    
               // } // End if list movie count == 0
                    
            }
            self.mainContext().saveContext()
        }
        
    }
    
    func fetchLists() -> [List] {
        let error: NSError? = nil
        
        var results: [AnyObject]?
        
        let fetchRequest = NSFetchRequest(entityName: List.entityName)
        do {
            results = try self.mainContext().executeFetchRequest(fetchRequest)
        } catch error! as NSError {
            results = nil
        } catch _ {
            results = nil
        }
        
        if error != nil {
            log.error("Could not fetch lists: \(error?.localizedDescription)" )
        }
        
        return results as! [List]
    }
    
    
} // AppDelegate





