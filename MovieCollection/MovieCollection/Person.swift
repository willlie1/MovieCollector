//
//  Person.swift
//  MovieCollection
//
//  Created by Wilko Zonnenberg on 16-01-17.
//  Copyright © 2017 Wilko Zonnenberg. All rights reserved.
//

import Foundation
import ObjectMapper

public class Person : Mappable {
    public var profile_path : String?
    public var id : Int?
    public var name : String?
    public var credit_id : String?
    
    public func mapping(map: Map) {
        self.id <- map["id"]
        self.name <- map["name"]
        self.profile_path <- map["profile_path"]
        self.credit_id <- map["credit_id"]
    }
    required public init?(map: Map){

        
    }
    
    required public init?(dictionary: NSDictionary) {
        credit_id = dictionary["credit_id"] as? String
        id = dictionary["id"] as? Int
        name = dictionary["name"] as? String
        profile_path = dictionary["profile_path"] as? String
    }
    
    public func dictionaryRepresentation() -> NSDictionary {
        
        let dictionary = NSMutableDictionary()
        if let creditId = self.credit_id {
            dictionary.setValue(creditId, forKey: "credit_id")
        }
        else {
            dictionary.setValue("", forKey: "credit_id")
        }
        if let path = self.profile_path {
            dictionary.setValue(path, forKey: "profile_path")
        }
        else {
            dictionary.setValue("", forKey: "profile_path")
        }
        dictionary.setValue(self.id, forKey: "id")
        dictionary.setValue(self.name, forKey: "name")
        
        return dictionary
    }
}
