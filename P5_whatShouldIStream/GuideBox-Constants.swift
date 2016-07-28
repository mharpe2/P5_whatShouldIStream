//
//  GuideBox-Constants.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 5/20/16.
//  Copyright © 2016 MJH. All rights reserved.
//

import Foundation

//Notes: netflix is a channel on api, not a source. prime, hbo are sources. not sure why.

extension GuideBox {
    
    // http://api-public.guidebox.com/v1.43/ {region} / {api key}
    struct Constants {
        
        static let name = "Guide Box"
        
        static let region = "US" //usa
        static let ApiKey = "rKxTG8BxefvYwf0SqjsAj5B4kTFnxkx7"
        static let BaseUrl = "http://api-public.guidebox.com/v1.43/" + region + "/" + ApiKey + "/"
        static let BaseUrlSSL = "https://api-public.guidebox.com/v1.43/"   + region + "/" + ApiKey + "/"
        //static let BaseImageUrl = "http://image.tmdb.org/t/p/"
        
           }
    struct Resource {
        
        static let channel = "channel"
        static let movie = "movies"
        static let show = "show"
        static let search = "search"
        static let tvdb = "tvdv"
        static let tmdb = "themoviedb"
        static let imdb = "imdb"
        static let allNetflixShows = "/shows/netflix/:limit1/:limit2/all/all"
        
        // MARK: - Movies
        static let MovieID = "movie/:id";
        static let MovieIDAlternativeTitles = "movie/:id/alternative_titles";
        static let MovieIDCredits = "movie/:id/credits";
        static let MovieIDImages = "movie/:id/images";
        static let MovieIDKeywords = "movie/:id/keywords";
        static let MovieIDReleases = "movie/:id/releases";
        static let MovieIDTrailers = "movie/:id/trailers";
        static let MovieIDTranslations = "movie/:id/translations";
        static let MovieIDSimilarMovies = "movie/:id/similar_movies";
        static let MovieIDReviews = "movie/:id/reviews";
        static let MovieIDLists = "movie/:id/lists";
        static let MovieIDChanges = "movie/:id/changes";
        
        static let MovieLatest = "movie/latest";
        static let MovieUpcoming = "movie/upcoming";
        static let MovieTheatres = "movie/now_playing";
        static let MoviePopular = "movie/popular";
        static let MovieTopRated = "movie/top_rated";
        
        static let searchByTitle = "search/title/:showname/fuzzy"
        static let searchByTMDBId = "search/id/themoviedb"
    }
    
    struct Parameters {
        static let all = "all"
        static let images = "images"
        static let title = "id"
    }
    
    struct Keys {
        static let ID = "id"
        static let ErrorStatusMessage = "error"
    }
}