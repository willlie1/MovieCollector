//
//  Cast.swift
//  MovieCollection
//
//  Created by Wilko Zonnenberg on 18-01-17.
//  Copyright © 2017 Wilko Zonnenberg. All rights reserved.
//

import UIKit
import ObjectMapper

class Cast: Person {

    public var cast_id : Int?
    public var character : String?
    public var order : Int?
    
    public override func mapping(map: Map) {
        super.mapping(map: map)
        self.cast_id <- map["id"]
        self.character <- map["character"]
        self.order <- map["order"]
    }
    
    required init?(map: Map){
        super.init(map: map)
        
    }
    
    public class func modelsFromDictionaryArray(array:NSArray) -> [Cast]
    {
        var models:[Cast] = []
        for item in array
        {
            models.append(Cast(dictionary: item as! NSDictionary)!)
        }
        return models
    }
    
    required public init?(dictionary: NSDictionary) {
        super.init(dictionary: dictionary)
        cast_id = dictionary["cast_id"] as? Int
        character = dictionary["character"] as? String
        order = dictionary["order"] as? Int
    }
    
    public override func dictionaryRepresentation() -> NSDictionary {
        let dictionary = super.dictionaryRepresentation() as! NSMutableDictionary
        
        dictionary.setValue(self.cast_id, forKey: "cast_id")
        dictionary.setValue(self.character, forKey: "character")
        dictionary.setValue(self.order, forKey: "order")
        
        return dictionary
    }
}
