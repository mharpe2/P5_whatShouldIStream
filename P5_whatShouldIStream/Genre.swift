//
//  Genre.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 5/28/16.
//  Copyright © 2016 MJH. All rights reserved.
//

import UIKit
import CoreData
import BNRCoreDataStack

class Genre : NSManagedObject, CoreDataModelable {
    
    static let entityName = "Genre"
    
    override var description: String {
        return "Genre \(id)"
    }
    
    struct keys {
       static let id = "id"
        static let name = "name"
    }
    
    @NSManaged var id: NSNumber?
    @NSManaged var name: String?
    @NSManaged var movies: NSMutableSet? // relationship
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super(entity: entity, insertInto: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entity(forEntityName: "Genre", in: context)!
        super(entity: entity, insertInto: context)
        
        // Dictionary
        id = dictionary[keys.id] as? NSNumber
        name = dictionary[keys.name] as? String
        
        
        }
    
    init(id: Int, name: String, context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entity(forEntityName: "Genre", in: context)!
        super(entity: entity, insertInto: context)
        
        // Dictionary
        self.id = id as NSNumber?
        self.name = name
    }
    
    static func genreFromResults(results: [Int : String],  context: NSManagedObjectContext?) -> NSMutableOrderedSet {
        
        let genres = NSMutableOrderedSet()
        
        for (key,value) in results {
            genres.add( Genre(id: key, name: value, context: context!) )
        }
        
        return genres
    }

    
    // Assign movies to genres / movies to genres
    func genreFromMovies( movies: [Movie] ) {
        for movie in movies {
            for genre in movie.genreArray {
                if let genre = Genre.fetchGenreWithId(genre) {
                    genre.movies?.addObject(movies)
                }
                
            } // genre in movie
        } // movie in movies
    }
    
    
    // retrieve genre
    static func fetchGenreWithId(id: NSNumber) -> Genre? {
        
        var genre: Genre? = nil
        
        let context = CoreDataStackManager.sharedInstance().coreDataStack!.mainQueueContext
        let predicate = NSPredicate(format: "id == %@", id)
        
        do {
            if  let g = try Genre.findFirstInContext(context, predicate: predicate) {
                genre = g
            }
        } catch _ {
            
        } // end catch
        
        return genre
    }
    
    class func genreFromDictionary(dictionary: [String: AnyObject], inManagedObjectContext context: NSManagedObjectContext ) -> Genre? {
        
        let log = XCGLogger.defaultInstance()
        
        // Dictionary
        guard let id = dictionary[keys.id] as? NSNumber,
           let name = dictionary[keys.name] as? String else {
                log.error("could not find id or name in dictionary")
                return nil
        }
        
        let request = NSFetchRequest(entityName: Genre.entityName)
        request.predicate = NSPredicate(format: "id = %@", id)
        
        if let genre = (try? context.executeFetchRequest(request))?.first as? Genre {
            return genre
        } else {
            
        let genre = Genre(dictionary: dictionary, context: context)  // NSEntityDescription.insertNewObjectForEntityForName("Genre", inManagedObjectContext: context) as? Genre {
           // genre.id = id
            //genre.name = name
            return genre
        }
        return nil
    }


    
    
    
}
