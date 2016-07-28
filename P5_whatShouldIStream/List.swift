//
//  List.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 5/12/16.
//  Copyright © 2016 MJH. All rights reserved.
//

import UIKit
import CoreData
import BNRCoreDataStack
import XCGLogger


class List : NSManagedObject, CoreDataModelable {
    
    static let entityName = "List"
    let log = XCGLogger.defaultInstance()
    
    override var description: String {
        return "Listid \(id), Name \(name), Date \(date)"
    }
    
    struct keys {
        static let date = "date"
        static let id = "id"
        static let name = "name"
        static let type = "type"
        
        static let list = entityName
        
        }
    
    @NSManaged var date: NSDate?
    @NSManaged var id: String?
    @NSManaged var name: String?
    @NSManaged var movies: NSMutableOrderedSet // relationship
    @NSManaged var type: String?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("List", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Dictionary
        id = dictionary[keys.id] as? String
        name = dictionary[keys.name] as? String
        type = dictionary[keys.type] as? String
        if let dateStr = dictionary[keys.date] as? String { // extract date
            date = TheMovieDB.sharedDateFormatter.dateFromString(dateStr)
                if date == nil {
                    date = NSDate()
                    log.verbose("Could not get date of list: \(self.description)")
                    
                }
        }
    }
    
    /* Helper: Given an array of dictionaries, convert them to an array of List objects */
    static func listsFromResults(results: [[String : AnyObject]], context: NSManagedObjectContext?) -> NSMutableOrderedSet {
        
        var lists = NSMutableOrderedSet()
        
        for var result in results {
            
            // prevent list duplicates
            if let listId = result[List.keys.id] as? String {
                let predicate = NSPredicate(format: "id == %@", listId)
                do {
                    let foundIt = try List.findFirstInContext(context!, predicate: predicate)
                    if foundIt == nil {
                        lists.addObject( List(dictionary: result, context: context!) )
                    }
                }
                catch _ {
                }
            }
        }
        return lists
    }

    
} // End of List
