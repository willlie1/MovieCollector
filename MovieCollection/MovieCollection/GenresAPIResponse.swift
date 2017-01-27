//
//  GenresAPIResponse.swift
//  MovieCollection
//
//  Created by Wilko Zonnenberg on 17-01-17.
//  Copyright © 2017 Wilko Zonnenberg. All rights reserved.
//

import Foundation
import ObjectMapper

class GenresAPIResponse : Mappable {
    public var genres : Array<Genre>?
    
    required public init?(map: Map){
//        do{
//            self.genres = try map.value("genres")
//        }
//        catch{
//            debugPrint("map failed ")
//        }
    }
    
    
    public func mapping(map: Map) {
        self.genres <- map["genres"]
        
    }
}
