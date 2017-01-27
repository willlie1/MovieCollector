//
//  MovieAPIResponse.swift
//  MovieCollection
//
//  Created by Wilko Zonnenberg on 18-01-17.
//  Copyright © 2017 Wilko Zonnenberg. All rights reserved.
//


import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

class MovieAPIResponse: Mappable {
    public var page: Int?
    public var results: Array<MovieMDB>?
    
    required public init?(map:Map){
        
    }
    
    public func mapping(map:Map){
        self.page <- map["page"]
        self.results <- map["results"]
    }
}
