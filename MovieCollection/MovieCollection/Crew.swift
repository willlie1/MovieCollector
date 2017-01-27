//
//  Crew.swift
//  MovieCollection
//
//  Created by Wilko Zonnenberg on 18-01-17.
//  Copyright © 2017 Wilko Zonnenberg. All rights reserved.
//

import UIKit
import ObjectMapper

class Crew: Person {

    public var department : String?
    public var job : String?
    
    public override func mapping(map: Map) {
        super.mapping(map: map)
        self.department <- map["department"]
        self.job <- map["job"]
    }
    
    required init?(map: Map){
        super.init(map: map)
        
    }
    
    public class func modelsFromDictionaryArray(array:NSArray) -> [Crew]
    {
        var models:[Crew] = []
        for item in array
        {
            models.append(Crew(dictionary: item as! NSDictionary)!)
        }
        return models
    }
    

    required public init?(dictionary: NSDictionary) {
        super.init(dictionary: dictionary)
        department = dictionary["department"] as? String
        job = dictionary["job"] as? String
    }
    
    public override func dictionaryRepresentation() -> NSDictionary {
        
        let dictionary = super.dictionaryRepresentation() as! NSMutableDictionary
        
        dictionary.setValue(self.department, forKey: "department")
        dictionary.setValue(self.job, forKey: "job")
        
        
        return dictionary
    }

}
