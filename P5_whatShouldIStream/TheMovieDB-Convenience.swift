//
//  TheMovieDB-Convenience.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 5/12/16.
//  Copyright © 2016 MJH. All rights reserved.
//


import CoreData
import BNRCoreDataStack


extension TheMovieDB {
    
    func getMoviesFromListWithId(id: String, context: NSManagedObjectContext?, completionHandler: @escaping (_ result: NSMutableOrderedSet?, _ error: NSError?) -> Void) {
        
        
        // Query TMDB
        let resource = TheMovieDB.Resources.ListID
        let parameters = [TheMovieDB.Keys.ID : id]
        
        TheMovieDB.sharedInstance().taskForResource(resource, parameters: parameters){ JSONResult, error  in
            if let error = error {
                print(error)
                completionHandler(result: nil, error: error)
            } else {
                
                let domainText = "Creating list"
                guard let listDictionary = JSONResult as? [String: AnyObject] else {
                    let errorText = "Can't create dictionary from result"
                    print("\(errorText)")
                    
                    completionHandler(result: nil, error: NSError(domain: domainText, code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse list"]))

                    return
                }
                
                var newList = List(dictionary: listDictionary, context: context!)
                
                if let results = JSONResult.valueForKey("items") as? [[String : AnyObject]] {
                    
                    let movies = Movie.moviesFromResults(results, listID: id, context: context)
                    newList.movies = movies
                    completionHandler(result: movies, error: nil)
                } // if let
                else {
                    completionHandler(result: nil, error: NSError(domain: "list parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse list"]))
                }
            }
        } // End of task for resource
    }
    
    
    
    func getMoviesFromList(list: List, completionHandler: @escaping (_ result: [[String : AnyObject]]?, _ error: NSError?) -> Void) {
      //removed nsmanaged context from function. -was not used
        
        // Query TMDB
        let resource = TheMovieDB.Resources.ListID
        var parameters = [String:AnyObject]()
        
        parameters[TheMovieDB.Keys.ID] = list.id as AnyObject?
        
        TheMovieDB.sharedInstance().taskForResource(resource, parameters: parameters){ JSONResult, error  in
            if let error = error {
                print(error)
                completionHandler(result: nil, error: error)
            } else {
                
                let domainText = "Creating list"
                guard let listDictionary = JSONResult as? [String: AnyObject] else {
                    let errorText = "Can't create dictionary from result"
                    print("\(errorText)")
                    
                    completionHandler(result: nil, error: NSError(domain: domainText, code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse list"]))
                    
                    return
                }
                              
                if let results = JSONResult.valueForKey("items") as? [[String : AnyObject]] {
                    
                    //let movies = Movie.moviesFromResults(results, listID: list.id!)
                    //list.movies = movies
                    completionHandler(result: results, error: nil)
                
                } // if let
                else {
                    completionHandler(result: nil, error: NSError(domain: "list parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse list"]))
                }
            }
        } // End of task for resource
    }

    func getMoviesFromListId(listId: String, completionHandler: @escaping (_ result: [[String : AnyObject]]?, _ error: NSError?) -> Void) {
        //removed nsmanaged context from function. -was not used
        
        // Query TMDB
        let resource = TheMovieDB.Resources.ListID
        var parameters = [String:AnyObject]()
        
        parameters[TheMovieDB.Keys.ID] = listId as AnyObject?
        
        TheMovieDB.sharedInstance().taskForResource(resource, parameters: parameters){ JSONResult, error  in
            if let error = error {
                print(error)
                completionHandler(result: nil, error: error)
            } else {
                
                let domainText = "Creating list"
                guard (JSONResult as? [String: AnyObject]) != nil else {
                    let errorText = "Can't create dictionary from result"
                    print("\(errorText)")
                    
                    completionHandler(result: nil, error: NSError(domain: domainText, code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse list"]))
                    
                    return
                }
                
                if let results = JSONResult.valueForKey("items") as? [[String : AnyObject]] {
                    
                    //let movies = Movie.moviesFromResults(results, listID: list.id!)
                    //list.movies = movies
                    completionHandler(result: results, error: nil)
                    
                } // if let
                else {
                    completionHandler(result: nil, error: NSError(domain: "list parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse list"]))
                }
            }
        } // End of task for resource
    }

    
    func getGenres(resource: String, completionHandler: @escaping (_ result: [Int: String]?, _ error: NSError?) -> Void ) {
        
        // Query TMDB
        let resource = TheMovieDB.Resources.MovieGenreList
        let mutableParameters = [String:AnyObject]()
        TheMovieDB.sharedInstance().taskForResource(resource, parameters: mutableParameters){ JSONResult, error  in
            
            var genres: [Int: String] = [:]
            
            if let error = error {
                print(error)
                completionHandler(result: nil, error: error)
                
            } else {
               if let results = JSONResult.valueForKey("genres") as? [[String: AnyObject]] {
                    print(results)
                    for i in results {
                        if let id = i["id"] as? Int {
                            if let name = i["name"] as? String {
                                genres[id] = name
                            }
                        }
                    } // loop
                }
                completionHandler(result: genres, error: nil)
            }
        } // End of task for resource
    }
 }
