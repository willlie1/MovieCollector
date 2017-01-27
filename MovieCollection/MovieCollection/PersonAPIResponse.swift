//
//  PersonAPIResponse.swift
//  MovieCollection
//
//  Created by Wilko Zonnenberg on 21-01-17.
//  Copyright © 2017 Wilko Zonnenberg. All rights reserved.
//

import Foundation
import ObjectMapper

public class PersonAPIResponse : Mappable {
    public var page : Int?
    public var results : Array<Person>?
    public var total_results : Int?
    public var total_pages : Int?
    
    
    required public init?(map:Map){
        
    }
    
    public func mapping(map:Map){
        self.page <- map["page"]
        self.results <- map["results"]
        self.total_pages <- map["total_pages"]
        self.total_results <- map["total_results"]
    }
    
}
