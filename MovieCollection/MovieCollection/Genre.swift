//
//  Genres.swift
//  MovieCollection
//
//  Created by Wilko Zonnenberg on 15-01-17.
//  Copyright © 2017 Wilko Zonnenberg. All rights reserved.
//

import Foundation
import ObjectMapper
import GRDB
/* For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar */

public class Genre : Record, Mappable {
	public var id : Int? = 0
	public var name : String? =  ""
    
    public func dictionaryRepresentation() -> NSDictionary {
        
        let dictionary = NSMutableDictionary()
        
        dictionary.setValue(self.id!, forKey: "id")
        dictionary.setValue(self.name!, forKey: "name")

        
        return dictionary
    }
    
    required public init?(map: Map){
        super.init()
    }

    
    public func mapping(map: Map) {
        self.id <- map["id"]
        self.name <- map["name"]

    }
    
    public class func modelsFromDictionaryArray(array:NSArray) -> [Genre]
    {
        var models:[Genre] = []
        for item in array
        {
            models.append(Genre(dictionary: item as! NSDictionary)!)
        }
        return models
    }
    
    required public init?(dictionary: NSDictionary) {
        super.init()
        id = dictionary["id"] as? Int
        name = dictionary["name"] as? String
    }
    
    required public init(row: Row) {
        super.init()
        id = row.value(named: "id")
        name = row.value(named: "name")
    }


}
