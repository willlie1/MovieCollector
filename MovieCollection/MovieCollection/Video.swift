//
//  Video.swift
//  MovieCollection
//
//  Created by Wilko Zonnenberg on 22-01-17.
//  Copyright © 2017 Wilko Zonnenberg. All rights reserved.
//

import Foundation
import ObjectMapper

public class Video : Mappable {
    public var id : String?
    public var key : String?
    public var site : String?

    
    public func mapping(map: Map) {
        self.id <- map["id"]
        self.key <- map["key"]
        self.site <- map["site"]

    }
    
    required public init?(map: Map){
        
    }
}
