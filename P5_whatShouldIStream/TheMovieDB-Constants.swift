//
//  TheMovieDB-Constants
//  MovieLists
//
//  Created by Jason on 1/23/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import Foundation

extension TheMovieDB {

    struct Constants {
    
        static let name = "The Movie Database"  
        
        // MARK: - URLs
        static let ApiKey = "3f467ccc69bc232f1c5026a281c8a480"
        static let BaseUrl = "http://api.themoviedb.org/3/"
        static let BaseUrlSSL = "https://api.themoviedb.org/3/"
        static let BaseImageUrl = "http://image.tmdb.org/t/p/"
    }
    
    struct Resources {

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
        
        // MARK: - TV
        static let TvID = "tv/:id";
        static let TvIDAlternativeTitles = "tv/:id/alternative_titles";
        static let TvIDCredits = "tv/:id/credits";
        static let TvIDImages = "tv/:id/images";
        static let TvIDKeywords = "tv/:id/keywords";
        static let TvIDReleases = "tv/:id/releases";
        static let TvIDTranslations = "tv/:id/translations";
                
        static let TvLatest = "tv/latest";
        static let TvUpcoming = "tv/upcoming";
        static let TvTheatres = "tv/now_playing";
        static let TvPopular = "tv/popular";
        static let TvTopRated = "tv/top_rated";
        
        // MARK: - Genres
       static let MovieGenreList = "genre/movie/list";
       static let TVGenreList = "genre/tv/list";
       static let GenreIDMovies = "genre/:id/movies";
        
        // MARK: - Collections
       static let CollectionID = "collection/:id";
       static let CollectionIDImages = "collection/:id/images";
        
        // MARK: - Search
       static let SearchMovie = "search/movie";
       static let SearchPerson = "search/person";
       static let SearchCollection = "search/collection";
       static let SearchList = "search/list";
       static let SearchCompany = "search/company";
       static let SearchKeyword = "search/keyword";
        
        // MARK: - Person
       static let Person = "person/:id";
       static let PersonIDMovieCredits = "person/:id/movie_credits";
       static let PersonIDImages = "person/:id/images";
       static let PersonIDChanges = "person/:id/changes";
       static let PersonPopular = "person/popular";
       static let PersonLatest = "person/latest";
        
        // MARK: - Lists
       static let ListID = "list/:id";
       static let ListIDItemStatus = "list/:id/item_status";
        
        // MARK: - Companies
       static let CompanyID = "company/:id";
       static let CompanyIDMovies = "company/:id/movies";
        
        // MARK: - Keywords
       static let KeywordID = "keyword/:id";
       static let KeywordIDMovies = "keyword/:id/movies";
        
        // MARK: - Discover
       static let Discover = "discover/movie";
        
        // MARK: - Reviews
       static let ReviewID = "review/:id";
        
        // MARK: - Changes
       static let ChangesMovie = "movie/changes";
       static let ChangesPerson = "person/changes";
        
        // MARK: - Jobs
       static let JobList = "job/list";
        
        // MARK: - Config
        static let Config = "configuration"
    }
    
    // MARK: - JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: General
        static let StatusMessage = "status_message"
        static let StatusCode = "status_code"
        
        // MARK: Authorization
        static let RequestToken = "request_token"
        static let SessionID = "session_id"
        
        // MARK: Account
        static let UserID = "id"
        
        // MARK: Config
        static let ConfigBaseImageURL = "base_url"
        static let ConfigSecureBaseImageURL = "secure_base_url"
        static let ConfigImages = "images"
        static let ConfigPosterSizes = "poster_sizes"
        static let ConfigProfileSizes = "profile_sizes"
        
        // MARK: Movies
        static let MovieID = "id"
        static let MovieTitle = "title"
        static let MoviePosterPath = "poster_path"
        static let MovieReleaseDate = "release_date"
        static let MovieReleaseYear = "release_year"
        static let MovieResults = "results"
        
    }
       
    struct Keys {
        static let ID = "id"
        static let ErrorStatusMessage = "status_message"
        static let ConfigBaseImageURL = "base_url"
        static let ConfigSecureBaseImageURL = "secure_base_url"
        static let ConfigImages = "images"
        static let ConfigPosterSizes = "poster_sizes"
        static let ConfigProfileSizes = "profile_sizes"
    }
    
    struct Values {
        static let KevinBaconIDValue = 4724
    }
    
    // MARK: - Poster Sizes
    struct PosterSizes {
        
        static let RowPoster = TheMovieDB.sharedInstance().config.posterSizes[2]
        static let DetailPoster = TheMovieDB.sharedInstance().config.posterSizes[4]
        
    }
}