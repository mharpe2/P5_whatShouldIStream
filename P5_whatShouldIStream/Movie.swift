//
//  Movie.swift
//  TheMovieDB
//
//  Created by Jason on 1/11/15.
//

import UIKit
import CoreData
import BNRCoreDataStack

class Movie : NSManagedObject, CoreDataModelable {
    
    static let entityName = "Movie"
    
    struct Keys {
        static let title = "title"
        static let posterPath = "poster_path"
        static let releaseDate = "release_date"
        static let listId = "list"
        static let overview = "overview"
        static let voteAverage = "vote_average"
        static let service = "service"
        static let id = "id"
        static let genresId = "genre_ids"
        static let watchlist = "watchlist"
        static let movie = "movie"
        static let tv = "tv"
    }
    
    @NSManaged var title: String?
    @NSManaged var id: NSNumber?
    @NSManaged var guideBoxId: NSNumber?
    @NSManaged var list: List? //relationship
    @NSManaged var posterPath: String?
    @NSManaged var releaseDate: NSDate?
    @NSManaged var actor: Person?
    @NSManaged var voteAverage: NSNumber?
    @NSManaged var overview: String?
    @NSManaged var genres: NSMutableSet? // relationship
    @NSManaged var onWatchlist: NSNumber?
    @NSManaged var type: String? // movie or tv show
    @NSManaged var largestPosterPath: String?
    
    // hold array of genres until they can be mapped 
    // into coredata
    var genreArray: [NSNumber] = [NSNumber]()
    
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super(entity: entity, insertInto: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entity(forEntityName: "Movie", in: context)!
        super(entity: entity, insertInto: context)
        
        // Dictionary
        title = dictionary[Keys.title] as? String
        id = dictionary[Keys.id] as? NSNumber
        posterPath = dictionary[Keys.posterPath] as? String
        voteAverage = dictionary[Keys.voteAverage] as? NSNumber
        overview = dictionary[Keys.overview] as? String
        onWatchlist = dictionary[Keys.watchlist] as? NSNumber
        
        genres = NSMutableSet()
        
        if let array = dictionary[Keys.genresId] as? [NSNumber] {
            genreArray = array
            
            for genreId in genreArray {
                let element = Genre.fetchGenreWithId(genreId)
                print("genere added to movie \(element?.name)")
                genres?.addObject(element!)
            }
            print("\(self.title) has \(self.genres!.count) genres.")
        }
        
        if let dateString = dictionary[Keys.releaseDate] as? String {
            if let date = TheMovieDB.sharedDateFormatter.dateFromString(dateString) {
                releaseDate = date
            }
        }
    }
    
    // returns a movie from the database if the movie already exists.
    // or returns a newly added movie
    class func MovieFromDictionary(dictionary: [String: AnyObject], inManagedObjectContext context: NSManagedObjectContext ) -> Movie? {
        
        let log = XCGLogger.defaultInstance()
        // Dictionary
        guard let id = dictionary[Keys.id] as? NSNumber else {
            log.error("Could not get list id")
            return nil
        }
        

        let request = NSFetchRequest(entityName: Movie.entityName)
        request.predicate = NSPredicate(format: "id == %@", id)
        
        if let movie = (try? context.executeFetchRequest(request))?.first as? Movie {
            return movie
        } else {
            let movie = Movie(dictionary: dictionary, context: context) //NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: context) as? Movie {
           
            return movie
        }
        
    }
    
    var posterImage: UIImage? {
        
        get {
            return TheMovieDB.Caches.imageCache.imageWithIdentifier(posterPath)
        }
        
        set {
            TheMovieDB.Caches.imageCache.storeImage(newValue, withIdentifier: posterPath!)
        }
    }
    
    var largelPosterImage: UIImage? {
        get {
            if var path = posterPath {
                
                path = path.insert("XXL", ind: 1)
                return TheMovieDB.Caches.imageCache.imageWithIdentifier(path)
                print(path)
            }
            
            return nil
        }
        
        set {
            
            if var path = posterPath {
                path = path.insert("XXL", ind: 1)
                TheMovieDB.Caches.imageCache.storeImage(newValue, withIdentifier: path )
                print(path)
            }
            
        }
    }
    
    /* Helper: Given an array of dictionaries, convert them to an array of TMDBMovie objects */
    static func moviesFromResults(results: [[String : AnyObject]], listID: String, context: NSManagedObjectContext?) -> NSMutableOrderedSet {
        
        var movies = NSMutableOrderedSet()
        
        for var result in results {
            result[Keys.listId] = listID as AnyObject?
            //movies.addObject( Movie(dictionary: result, context: context!) )
            movies.addObject( Movie.MovieFromDictionary(result, inManagedObjectContext: context!)! )

        }
        
        return movies
    }
    
    // Helper: Given an array of dictionaries, convert them to an array of TMDBMovie objects 
    static func moviesFromList(results: [[String : AnyObject]], list: List, context: NSManagedObjectContext?) -> NSMutableOrderedSet {
        
        let movies = NSMutableOrderedSet()
        
        for let result in results {
            movies.add( Movie(dictionary: result, context: context!) )
        }
        
        return movies
    }
    
    override func prepareForDeletion() {
        
        guard let path = posterPath else {
            print("prepare for deletion has failed")
            return
        }
        
        // Delete smaller image
        TheMovieDB.Caches.imageCache.storeImage(nil, withIdentifier: path)
        
        // Delete larger image
        if var path = posterPath {
            path = path.insert("XXL", ind: 1)
            TheMovieDB.Caches.imageCache.storeImage(nil, withIdentifier: path )
            print(path)
        }

    }

}



