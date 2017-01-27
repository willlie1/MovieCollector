//
//  VideosAPIResponse.swift
//  MovieCollection
//
//  Created by Wilko Zonnenberg on 22-01-17.
//  Copyright © 2017 Wilko Zonnenberg. All rights reserved.
//

import Foundation
import ObjectMapper

public class VideosAPIResponse : Mappable {
    public var id : Int?
    public var results : Array<Video>?
    
    public func mapping(map:Map){
        self.id <- map["id"]
        self.results <- map["results"]

    }
    
    required public init?(map:Map){
        
    }
    
}
