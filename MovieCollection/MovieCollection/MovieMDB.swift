//
//  MovieMDB.swift
//  MovieCollection
//
//  Created by Wilko Zonnenberg on 15-01-17.
//  Copyright © 2017 Wilko Zonnenberg. All rights reserved.
//

import UIKit
import GRDB
import ObjectMapper

class MovieMDB: Mappable {
    public var poster_path : String?
//    public var adult : String?
    public var overview : String?
    public var release_date : String?
    public var genre_ids : Array<Int>?
    public var id : Int?
    public var original_title : String?
    public var original_language : String?
    public var title : String?
    public var backdrop_path : String?
    public var popularity : Double?
    public var vote_count : Int?
//    public var video : String?
    public var vote_average : Double?
    
    required public init?(dictionary: NSDictionary) {
        poster_path = dictionary["poster_path"] as? String
        if poster_path == nil {
            poster_path = ""
        }
        overview = dictionary["overview"] as? String
        release_date = dictionary["release_date"] as? String
        if (dictionary["genre_ids"] != nil) { genre_ids = dictionary["genre_ids"] as? Array<Int> }
        id = dictionary["id"] as? Int
        original_title = dictionary["original_title"] as? String
        original_language = dictionary["original_language"] as? String
        title = dictionary["title"] as? String
        backdrop_path = dictionary["backdrop_path"] as? String
        popularity = dictionary["popularity"] as? Double
        vote_count = dictionary["vote_count"] as? Int
        vote_average = dictionary["vote_average"] as? Double
    }
    
    required init(row: Row) {
        fatalError("init(row:) has not been implemented")
    }

    public func dictionaryRepresentation() -> NSDictionary {
        
        let dictionary = NSMutableDictionary()
        
        dictionary.setValue(self.poster_path, forKey: "poster_path")
        dictionary.setValue(self.overview, forKey: "overview")
        dictionary.setValue(self.release_date, forKey: "release_date")
        dictionary.setValue(self.id, forKey: "id")
        dictionary.setValue(self.original_title, forKey: "original_title")
        dictionary.setValue(self.original_language, forKey: "original_language")
        dictionary.setValue(self.title, forKey: "title")
        dictionary.setValue(self.genre_ids, forKey: "genre_ids")
        dictionary.setValue(self.backdrop_path, forKey: "backdrop_path")
        dictionary.setValue(self.popularity, forKey: "popularity")
        dictionary.setValue(self.vote_count, forKey: "vote_count")
        dictionary.setValue(self.vote_average, forKey: "vote_average")
        
        return dictionary
    }
    
    required public init?(map: Map){
        
    }

    
    public func getMovieDetailed() -> MovieDetailed {
        return MovieDetailed(dictionary: dictionaryRepresentation())!
    
    }
    
    func mapping(map: Map) {
        self.poster_path <- map["poster_path"]
        if poster_path == nil {
            poster_path = ""
        }
        self.overview <- map["overview"]
        self.release_date <- map["release_date"]
        self.id <- map["id"]
        self.original_title <- map["original_title"]
        self.original_language <- map["original_language"]
        self.title <- map["title"]
        self.genre_ids <- map["genre_ids"]
        self.backdrop_path <- map["backdrop_path"]
        self.popularity <- map["popularity"]
        self.vote_count <- map["vote_count"]
        self.vote_average <- map["vote_average"]
    }

}
