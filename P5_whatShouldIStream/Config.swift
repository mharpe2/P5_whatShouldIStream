//
//  Config.swift
//  MyFavoriteMovies
//
//  Created by Jason on 1/23/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import Foundation
import XCGLogger

/**
 * The config struct stores information that is used to build image
 * URL's for TheMovieDB. The constant values below were taken from 
 * the site on 1/23/15. Invoking the updateConfig convenience method
 * will download the latest using the failable initializer below to
 * parse the dictionary.
 */

// MARK: - Files Support
private let _documentsDirectoryURL: NSURL = FileManager.defaultManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
private let _fileURL: NSURL = _documentsDirectoryURL.appendingPathComponent("TheMovieDB-Context")


class Config: NSObject, NSCoding {
    
    // Default values from 1/12/15
    var baseImageURLString = "http://image.tmdb.org/t/p/"
    var secureBaseImageURLString =  "https://image.tmdb.org/t/p/"
    var posterSizes = ["w92", "w154", "w185", "w342", "w500", "w780", "original"]
    var profileSizes = ["w45", "w185", "h632", "original"]
    var dateUpdated: NSDate? = nil
    var genres: [Int: String]?
    
    override init() {
        
    }
    
    convenience init?(dictionary: [String : AnyObject]) {
    
        self.init()
        
        if let imageDictionary = dictionary[TheMovieDB.Keys.ConfigImages] as? [String : AnyObject] {
            
            if let urlString = imageDictionary[TheMovieDB.Keys.ConfigBaseImageURL] as? String {
                baseImageURLString = urlString
            } else {return nil}
            
            if let secureUrlString = imageDictionary[TheMovieDB.Keys.ConfigSecureBaseImageURL] as? String {
                secureBaseImageURLString = secureUrlString
            } else {return nil}
            
            if let posterSizesArray = imageDictionary[TheMovieDB.Keys.ConfigPosterSizes] as? [String] {
                posterSizes = posterSizesArray
            } else {return nil}
            
            if let profileSizesArray = imageDictionary[TheMovieDB.Keys.ConfigProfileSizes] as? [String] {
                profileSizes = profileSizesArray
            } else {return nil}
            
            dateUpdated = NSDate()
            
        } else {
            return nil
        }
    }
    
    
    // Returns the number days since the config was last updated.
    
    var daysSinceLastUpdate: Int? {
        
        if let lastUpdate = dateUpdated {
            return Int(NSDate().timeIntervalSince(lastUpdate as Date)) / 60*60*24
        } else {
            return nil
        }
    }
    
    func updateIfDaysSinceUpdateExceeds(days: Int) {

        // If the config is up to date then return
        if let daysSinceLastUpdate = daysSinceLastUpdate {
            if (daysSinceLastUpdate <= days) {
                return
            }
        }
    
        // Otherwise, update
        updateTMDB()
        
    }
    
    func updateTMDB() {
        TheMovieDB.sharedInstance().updateConfig() { didSucceed, error in
            
            if let error = error {
                print("Error updating config: \(error.localizedDescription)")
                
            } else {
                print("Updated Config: \(didSucceed)")
                TheMovieDB.sharedInstance().config.save()
            }
        }
    }
    
    // MARK: - NSCoding
    
    let BaseImageURLStringKey = "config.base_image_url_string_key"
    let SecureBaseImageURLStringKey =  "config.secure_base_image_url_key"
    let PosterSizesKey = "config.poster_size_key"
    let ProfileSizesKey = "config.profile_size_key"
    let DateUpdatedKey = "config.date_update_key"
    let genreKey = "config.genre_key"
    
    required init?(coder aDecoder: NSCoder) {
        baseImageURLString = aDecoder.decodeObject(forKey: BaseImageURLStringKey) as! String
        secureBaseImageURLString = aDecoder.decodeObject(forKey: SecureBaseImageURLStringKey) as! String
        posterSizes = aDecoder.decodeObject(forKey: PosterSizesKey) as! [String]
        profileSizes = aDecoder.decodeObject(forKey: ProfileSizesKey) as! [String]
        dateUpdated = aDecoder.decodeObject(forKey: DateUpdatedKey) as? NSDate
        genres = aDecoder.decodeObject(forKey: genreKey) as? [Int: String]
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encode(baseImageURLString, forKey: BaseImageURLStringKey)
        aCoder.encode(secureBaseImageURLString, forKey: SecureBaseImageURLStringKey)
        aCoder.encode(posterSizes, forKey: PosterSizesKey)
        aCoder.encode(profileSizes, forKey: ProfileSizesKey)
        aCoder.encode(dateUpdated, forKey: DateUpdatedKey)
        aCoder.encode(genres, forKey: genreKey)
    }
    
    func save() {
        NSKeyedArchiver.archiveRootObject(self, toFile: _fileURL.path!)
    }
    
    class func unarchivedInstance() -> Config? {
        
        if FileManager.default.fileExists(atPath: _fileURL.path!) {
            return NSKeyedUnarchiver.unarchiveObject(withFile: _fileURL.path!) as? Config
        } else {
            return nil
        }
    }
}














